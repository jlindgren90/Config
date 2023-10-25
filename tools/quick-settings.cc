#include <QApplication>
#include <QMenu>
#include <QPointer>
#include <QScreen>
#include <QSystemTrayIcon>

#include <functional>
#include <glib.h>
#include <memory>
#include <stdio.h>

template<typename T, typename D>
static std::shared_ptr<T> to_shared(T * ptr, D deleter)
{
    return std::shared_ptr<T>(ptr, deleter);
}

static void initMenu(QMenu * menu, GKeyFile * inifile)
{
    auto items = to_shared(g_key_file_get_groups(inifile, nullptr), g_strfreev);
    auto updates = std::make_shared<QList<std::function<void()>>>();

    for (char ** i = items.get(); *i; i++)
    {
        const char * item = *i;
        auto query = to_shared(
            g_key_file_get_value(inifile, item, "query", nullptr), g_free);
        auto enable = to_shared(
            g_key_file_get_value(inifile, item, "enable", nullptr), g_free);
        auto disable = to_shared(
            g_key_file_get_value(inifile, item, "disable", nullptr), g_free);
        auto command = to_shared(
            g_key_file_get_value(inifile, item, "command", nullptr), g_free);

        if (query && enable && disable)
        {
            auto action = new QAction(item, menu);
            action->setCheckable(true);

            auto update = [action, query]() {
                action->setChecked((system(query.get()) == 0));
            };
            updates->append(update);
            update();

            QObject::connect(action, &QAction::triggered,
                             [enable, disable, updates](bool checked) {
                                 if (checked)
                                     system(enable.get());
                                 else
                                     system(disable.get());
                                 /* update other toggles */
                                 for (auto & update : *updates)
                                     update();
                             });

            menu->addAction(action);
        }
        else if (command)
        {
            auto action = new QAction(item, menu);
            QObject::connect(action, &QAction::triggered,
                             [command]() { system(command.get()); });

            menu->addAction(action);
        }
        else
        {
            fprintf(stderr, "Item \'%s\' does not contain required keys!\n",
                    item);
        }
    }
}

int main(int argc, char ** argv)
{
    QApplication app(argc, argv);

    auto inifile = to_shared(g_key_file_new(), g_key_file_unref);
    auto inipath = to_shared(g_build_filename(g_get_user_config_dir(),
                                              "quick-settings.ini", nullptr),
                             g_free);

    if (!g_key_file_load_from_file(inifile.get(), inipath.get(),
                                   G_KEY_FILE_NONE, nullptr))
    {
        fprintf(stderr, "Unable to load %s!\n", inipath.get());
        return 1;
    }

    QMenu menu;
    initMenu(&menu, inifile.get());

    QSystemTrayIcon icon(QIcon::fromTheme("preferences-system"));
    icon.setContextMenu(&menu);
    icon.show();

    return app.exec();
}
