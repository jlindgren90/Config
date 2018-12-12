#include <stdio.h>
#include <stdlib.h>
#include <gtk/gtk.h>

#define KEYFILE_NAME ".quick-settings.ini"

static GKeyFile * keyfile = NULL;
static GtkWidget * menu = NULL;

static gboolean load_keyfile (void)
{
    keyfile = g_key_file_new ();

    const char * home = g_get_home_dir ();
    char * filepath = g_build_filename (home, KEYFILE_NAME, NULL);
    GError * error = NULL;

    if (! g_key_file_load_from_file (keyfile, filepath, 0, & error))
    {
        if (error)
        {
            fprintf (stderr, "Error loading %s: %s\n", filepath, error->message);
            g_error_free (error);
        }

        g_key_file_free (keyfile);
        keyfile = NULL;
    }

    g_free (filepath);
    return (keyfile != NULL);
}

static void menu_item_cb (GtkMenuItem * menu_item)
{
    const char * cmd;

    if (GTK_IS_CHECK_MENU_ITEM (menu_item))
    {
        if (gtk_check_menu_item_get_active ((GtkCheckMenuItem *) menu_item))
            cmd = g_object_get_data ((GObject *) menu_item, "enable_cmd");
        else
            cmd = g_object_get_data ((GObject *) menu_item, "disable_cmd");
    }
    else
    {
        cmd = g_object_get_data ((GObject *) menu_item, "command");
    }

    int exit_code = system (cmd);

    if (exit_code != 0)
    {
        GtkWidget * message =
            gtk_message_dialog_new (
                NULL, 0, GTK_MESSAGE_ERROR, GTK_BUTTONS_CLOSE,
                "Command '%s' returned exit code %d.\n", cmd, exit_code
            );

        g_signal_connect (message, "response", (GCallback) gtk_widget_destroy, NULL);

        gtk_widget_show (message);
    }
}

static gboolean button_press_cb (GtkStatusIcon * icon, GdkEventButton * event)
{
    if (menu)
        gtk_widget_destroy (menu);

    menu = gtk_menu_new ();

    char * * groups = g_key_file_get_groups (keyfile, NULL);

    for (int g = 0; groups[g] != NULL; g ++)
    {
        char * query_cmd = g_key_file_get_value (keyfile, groups[g], "query", NULL);
        char * enable_cmd = g_key_file_get_value (keyfile, groups[g], "enable", NULL);
        char * disable_cmd = g_key_file_get_value (keyfile, groups[g], "disable", NULL);
        char * simple_cmd = g_key_file_get_value (keyfile, groups[g], "command", NULL);

        if (query_cmd != NULL && enable_cmd != NULL && disable_cmd != NULL)
        {
            int exit_code = system (query_cmd);

            GtkWidget * menu_item = gtk_check_menu_item_new_with_label (groups[g]);
            gtk_check_menu_item_set_active ((GtkCheckMenuItem *) menu_item, (exit_code == 0));

            g_object_set_data_full ((GObject *) menu_item, "enable_cmd", enable_cmd, g_free);
            g_object_set_data_full ((GObject *) menu_item, "disable_cmd", disable_cmd, g_free);
            g_signal_connect (menu_item, "toggled", (GCallback) menu_item_cb, NULL);

            gtk_widget_show (menu_item);
            gtk_menu_shell_append ((GtkMenuShell *) menu, menu_item);

            g_free (simple_cmd);
        }
        else if (simple_cmd != NULL)
        {
            GtkWidget * menu_item = gtk_menu_item_new_with_label (groups[g]);

            g_object_set_data_full ((GObject *) menu_item, "command", simple_cmd, g_free);
            g_signal_connect (menu_item, "activate", (GCallback) menu_item_cb, NULL);

            gtk_widget_show (menu_item);
            gtk_menu_shell_append ((GtkMenuShell *) menu, menu_item);

            g_free (query_cmd);
            g_free (enable_cmd);
            g_free (disable_cmd);
        }
        else
        {
            fprintf (stderr, "Warning: Setting \'%s\' does not contain required keys.\n", groups[g]);

            g_free (enable_cmd);
            g_free (disable_cmd);
            g_free (simple_cmd);
        }

        g_free (query_cmd);
    }

    gtk_menu_popup ((GtkMenu *) menu, NULL, NULL, gtk_status_icon_position_menu,
                    icon, event->button, event->time);

    g_strfreev (groups);
    return TRUE;
}

int main (void)
{
    if (! load_keyfile ())
        return 1;

    gtk_init (NULL, NULL);

    GtkStatusIcon * icon = gtk_status_icon_new_from_icon_name ("preferences-system");

    g_signal_connect (icon, "button-press-event", (GCallback) button_press_cb, NULL);

    gtk_main ();  /* does not return */

    return 0;
}
