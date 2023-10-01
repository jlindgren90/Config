#include <QApplication>
#include <QMenu>
#include <QPointer>
#include <QSystemTrayIcon>

#include <glib.h>
#include <memory>
#include <stdio.h>

template<typename T, typename D>
static std::shared_ptr<T> to_shared(T * ptr, D deleter)
{
    return std::shared_ptr<T>(ptr, deleter);
}

static QPointer<QMenu> s_menu;

static void showMenu(GKeyFile * inifile, const QPoint & pos)
{
    auto menu = new QMenu();
    auto items = to_shared(g_key_file_get_groups(inifile, nullptr), g_strfreev);

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
            bool enabled = (system(query.get()) == 0);
            auto toggle = enabled ? disable : enable;
            auto action = new QAction(item, menu);

            action->setCheckable(true);
            action->setChecked(enabled);
            QObject::connect(action, &QAction::triggered,
                             [toggle]() { system(toggle.get()); });

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

    menu->setAttribute(Qt::WA_DeleteOnClose);
    menu->popup(pos);
    s_menu = menu;
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

    QSystemTrayIcon icon(QIcon::fromTheme("preferences-system"));

    QObject::connect(
        &icon, &QSystemTrayIcon::activated,
        [&icon, inifile](QSystemTrayIcon::ActivationReason reason) {
            if (reason == QSystemTrayIcon::Trigger)
            {
                if (s_menu.isNull())
                {
                    QPoint pos = icon.geometry().topLeft();
                    if (pos.isNull()) /* happens with QDBusTrayIcon */
                        pos = QCursor::pos();
                    showMenu(inifile.get(), pos);
                }
                else
                {
                    s_menu->deleteLater();
                }
            }
        });

    icon.show();

    return app.exec();
}
