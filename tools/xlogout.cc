#include <QApplication>
#include <QIcon>
#include <QMessageBox>
#include <QPushButton>
#include <QStyle>

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>

static int atoi_nullsafe(const char *a) { return a ? atoi(a) : 0; }

static void try_kill(int pid)
{
    if (kill(pid, SIGTERM) < 0) {
        fprintf(stderr, "Could not sent SIGTERM to PID %d: %s\n", pid,
                strerror(errno));
    }
}

static void try_run(const char *cmd)
{
    int ret = system(cmd);
    if (ret == -1)
        fprintf(stderr, "Could not execute \"%s\": %s\n", cmd, strerror(errno));
    else if (!WIFEXITED(ret))
        fprintf(stderr, "Could not execute \"%s\": error %d\n", cmd, ret);
    else {
        int status = WEXITSTATUS(ret);
        if (status != 0)
            fprintf(stderr, "Command \"%s\" exited with status %d", cmd,
                    status);
    }
}

int main(int argc, char **argv)
{
    int pid;
    if (!(pid = atoi_nullsafe(getenv("XSESSION_PID"))) &&
        !(pid = atoi_nullsafe(getenv("LABWC_PID")))) {

        fprintf(stderr, "Neither XSESSION_PID nor LABWC_PID is set\n");
        exit(EXIT_FAILURE);
    }

    QApplication app(argc, argv);

    auto icon = QIcon::fromTheme("system-log-out");
    app.setWindowIcon(icon);

    auto msgbox = new QMessageBox();
    msgbox->setAttribute(Qt::WA_DeleteOnClose);
    msgbox->setWindowTitle("Log Out");
    msgbox->setText("What do you want to do?");

    auto logout = msgbox->addButton("&Log Out", QMessageBox::AcceptRole);
    auto shutdown = msgbox->addButton("&Shut Down", QMessageBox::AcceptRole);
    auto reboot = msgbox->addButton("&Reboot", QMessageBox::AcceptRole);
    msgbox->addButton("Cancel", QMessageBox::RejectRole);

    int iconsize = app.style()->pixelMetric(QStyle::PM_MessageBoxIconSize);
    msgbox->setIconPixmap(icon.pixmap(iconsize));
    msgbox->show();

    QObject::connect(logout, &QPushButton::clicked, [pid]() { try_kill(pid); });
    QObject::connect(shutdown, &QPushButton::clicked,
                     []() { try_run("poweroff"); });
    QObject::connect(reboot, &QPushButton::clicked,
                     []() { try_run("reboot"); });
    QObject::connect(msgbox, &QObject::destroyed, QApplication::quit);

    return app.exec();
}
