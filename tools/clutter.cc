/* clutter.cc - Arch Linux + Debian version
   John Lindgren */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <dirent.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

#include <fstream>
#include <map>
#include <set>
#include <string>
#include <vector>

#define USE_DPKG

using list_t = std::set<std::string>;
using tree_t = std::map<std::string, list_t>;

void fail(const char *func, const char *param)
{
    fprintf(stderr, "%s failed for %s: %s\n", func, param, strerror(errno));
    exit(1);
}

std::vector<char> run(const char *command)
{
    std::vector<char> all;
    std::vector<char> buf(4096);

    FILE *stream = popen(command, "r");
    if (!stream)
        fail("popen", command);

    int len;
    while ((len = fread(buf.data(), 1, 4096, stream)))
        all.insert(all.end(), buf.begin(), buf.begin() + len);

    if (ferror(stream))
        fail("fread", command);

    int ret = pclose(stream);
    if (ret == -1)
        fail("pclose", command);
    else if (ret != 0) {
        fprintf(stderr, "%s returned exit code %d\n", command, ret);
        exit(1);
    }

    all.push_back(0);
    return all;
}

list_t get_packages(void)
{
    list_t packages;

#ifdef USE_DPKG
    auto data = run("dpkg --get-selections");
    char *parse = data.data();
    while (*parse) {
        char *end = strchr(parse, '\n');
        char *div = strchr(parse, '\t');
#else
    auto data = run("pacman -Qq");
    char *parse = data.data();
    while (*parse) {
        char *end = strchr(parse, '\n');
        char *div = end;
#endif
        if (!end || !div || div > end) {
            fprintf(stderr, "package list invalid\n");
            exit(1);
        }

        *div = 0;
        packages.insert(parse);
        parse = end + 1;
    }

    return packages;
}

std::string merge_usr(const char *name)
{
    bool moved = !strncmp(name, "/bin/", 5) || !strncmp(name, "/lib/", 5) ||
                 !strncmp(name, "/sbin/", 6);

    return moved ? std::string("/usr") + name : name;
}

void add_package_files(const char *package, list_t &installed, list_t &shared)
{
#ifdef USE_DPKG
    auto cmd = std::string("dpkg -L \"") + package + "\"";
    auto data = run(cmd.c_str());
    char *parse = data.data();
    while (*parse) {
        char *end = strchr(parse, '\n');
        char *div = parse - 1;
#else
    auto cmd = std::string("pacman -Ql \"") + package + "\"";
    auto data = run(cmd.c_str());
    char *parse = data.data();
    while (*parse) {
        char *end = strchr(parse, '\n');
        char *div = strchr(parse, ' ');
#endif
        if (!div || !end || div > end) {
            fprintf(stderr, "file list invalid\n");
            exit(1);
        }

        *end = 0;
        if (end > div + 1 && end[-1] == '/')
            end[-1] = 0;

        auto name = merge_usr(div + 1);
        if (!installed.insert(name).second)
            shared.insert(name);

        parse = end + 1;
    }
}

void get_installed(const list_t &packages, list_t &installed, list_t &shared)
{
    shared.insert("/");

    int total = packages.size();
    int count = 0;

    for (auto &package : packages) {
        fprintf(stderr, "Listing installed files: %d%%\r", 100 * count / total);
        add_package_files(package.c_str(), installed, shared);
        count++;
    }
    fprintf(stderr, "\n");
}

std::string build_path(const char *folder, const char *name)
{
    if (!strcmp(folder, "/"))
        return std::string("/") + name;
    return std::string(folder) + "/" + name;
}

struct stat get_info(const char *name)
{
    struct stat info;
    if (lstat(name, &info))
        fail("lstat", name);
    return info;
}

bool is_folder_on(const char *name, dev_t dev)
{
    auto info = get_info(name);
    return S_ISDIR(info.st_mode) && info.st_dev == dev;
}

template<class func_t>
void for_each_entry(const char *folder, func_t func)
{
    DIR *handle = opendir(folder);
    if (!handle)
        fail("opendir", folder);

    while (1) {
        errno = 0;
        auto entry = readdir(handle);
        if (!entry) {
            if (errno)
                fail("readdir", folder);
            break;
        }

        if (strcmp(entry->d_name, ".") && strcmp(entry->d_name, ".."))
            func(build_path(folder, entry->d_name));
    }

    closedir(handle);
}

int count_in(const char *folder, dev_t dev)
{
    int count = 0;
    for_each_entry(folder, [&](std::string name) {
        count++;
        if (is_folder_on(name.c_str(), dev))
            count += count_in(name.c_str(), dev);
    });
    return count;
}

struct search_t {
    list_t installed, shared;
    int expected = 0, found = 0;
    list_t clutter;
    tree_t messy;
};

void search_in(const char *folder, dev_t dev, search_t &search)
{
    fprintf(stderr, "Searching: %d%%\r", 100 * search.found / search.expected);
    bool is_shared = (search.shared.find(folder) != search.shared.end());

    for_each_entry(folder, [&](std::string name) {
        if (search.installed.erase(name)) {
            search.found++;
            if (is_folder_on(name.c_str(), dev))
                search_in(name.c_str(), dev, search);
        } else {
            int children = is_folder_on(name.c_str(), dev)
                               ? count_in(name.c_str(), dev)
                               : 0;
            if (children)
                name.append(" (+" + std::to_string(children) + ")");

            if (is_shared)
                search.clutter.insert(name);
            else
                search.messy.try_emplace(folder).first->second.insert(name);
        }
    });
}

void search_all(search_t &search)
{
    auto info = get_info("/");
    search.expected = search.installed.size();
    search_in("/", info.st_dev, search);
    fprintf(stderr, "\n");
}

void dump_list_to_file(list_t &list, const char *name)
{
    std::ofstream ofs(name);
    for (auto &item : list)
        ofs << item << "\n";
}

void dump_tree_to_file(tree_t &tree, const char *name)
{
    std::ofstream ofs(name);
    for (auto &pair : tree) {
        ofs << "\n" << pair.first << ":\n";
        for (auto &item : pair.second)
            ofs << "  " << item << "\n";
    }
}

int main(void)
{
    list_t packages = get_packages();
    printf("%d packages installed\n", (int)packages.size());

    search_t search;
    get_installed(packages, search.installed, search.shared);
    printf("%d files installed.\n", (int)search.installed.size());

    search_all(search);

    dump_list_to_file(search.installed, "missing.txt");
    dump_list_to_file(search.clutter, "clutter.txt");
    dump_tree_to_file(search.messy, "messy.txt");

    return 0;
}
