#include <QApplication>
#include <QMenu>
#include <QSystemTrayIcon>

#include <glib.h>
#include <memory>
#include <stdio.h>

template<typename T>
using AutoPtr = std::unique_ptr<T, void (*)(T *)>;

struct CharPtr : public std::unique_ptr<char, void (*)(void *)>
{
    CharPtr(char * val) : unique_ptr(val, g_free) {}
};

class CommandAction : public QAction
{
public:
    CommandAction(const char * name, CharPtr && command, QObject * parent)
        : QAction(name, parent), command(std::move(command))
    {
        connect(this, &QAction::triggered, this, &CommandAction::run);
    }

private:
    CharPtr command;
    void run() { system(command.get()); }
};

class QuickSettingsIcon : public QSystemTrayIcon
{
public:
    QuickSettingsIcon(AutoPtr<GKeyFile> && inifile)
        : QSystemTrayIcon(QIcon::fromTheme("preferences-system")),
          inifile(std::move(inifile))
    {
        connect(this, &QSystemTrayIcon::activated, this,
                &QuickSettingsIcon::activate);
    }

private:
    AutoPtr<GKeyFile> inifile;
    void activate(QSystemTrayIcon::ActivationReason reason);
};

void QuickSettingsIcon::activate(QSystemTrayIcon::ActivationReason reason)
{
    if (reason != QSystemTrayIcon::Trigger)
        return;

    auto menu = new QMenu();
    auto items = AutoPtr<char *>(g_key_file_get_groups(inifile.get(), nullptr),
                                 g_strfreev);

    for (char ** i = items.get(); *i != nullptr; i++)
    {
        const char * item = *i;
        auto query = CharPtr(
            g_key_file_get_value(inifile.get(), item, "query", nullptr));
        auto enable = CharPtr(
            g_key_file_get_value(inifile.get(), item, "enable", nullptr));
        auto disable = CharPtr(
            g_key_file_get_value(inifile.get(), item, "disable", nullptr));
        auto command = CharPtr(
            g_key_file_get_value(inifile.get(), item, "command", nullptr));

        if (query && enable && disable)
        {
            bool enabled = (system(query.get()) == 0);
            auto action = new CommandAction(
                item, enabled ? std::move(disable) : std::move(enable), menu);

            action->setCheckable(true);
            action->setChecked(enabled);
            menu->addAction(action);
        }
        else if (command)
        {
            menu->addAction(new CommandAction(item, std::move(command), menu));
        }
        else
        {
            fprintf(stderr, "Item \'%s\' does not contain required keys!\n",
                    item);
        }
    }

    menu->setAttribute(Qt::WA_DeleteOnClose);
    menu->popup(geometry().topLeft());
}

int main(int argc, char ** argv)
{
    QApplication app(argc, argv);

    auto inifile = AutoPtr<GKeyFile>(g_key_file_new(), g_key_file_unref);
    auto inipath = CharPtr(g_build_filename(g_get_user_config_dir(),
                                            "quick-settings.ini", nullptr));

    if (!g_key_file_load_from_file(inifile.get(), inipath.get(),
                                   G_KEY_FILE_NONE, nullptr))
    {
        fprintf(stderr, "Unable to load %s!\n", inipath.get());
        return 1;
    }

    QuickSettingsIcon icon(std::move(inifile));
    icon.show();

    return app.exec();
}
