#include <QApplication>
#include <QIcon>
#include <QMessageBox>
#include <QStyle>

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

static int atoi_nullsafe(const char * a) { return a ? atoi(a) : 0; }

static void try_kill(int pid)
{
    if (kill(pid, SIGTERM) < 0)
    {
        fprintf(stderr, "Could not sent SIGTERM to PID %d: %s\n", pid,
                strerror(errno));
    }
}

int main(int argc, char ** argv)
{
    int pid;
    if (!(pid = atoi_nullsafe(getenv("XSESSION_PID"))) &&
        !(pid = atoi_nullsafe(getenv("LABWC_PID"))))
    {
        fprintf(stderr, "Neither XSESSION_PID nor LABWC_PID is set\n");
        exit(EXIT_FAILURE);
    }

    QApplication app(argc, argv);

    auto icon = QIcon::fromTheme("system-log-out");
    app.setWindowIcon(icon);

    auto msgbox = new QMessageBox();
    msgbox->setAttribute(Qt::WA_DeleteOnClose);
    msgbox->setWindowTitle("Log Out");
    msgbox->setText("Do you want to log out?");
    msgbox->addButton("Log Out", QMessageBox::AcceptRole);
    msgbox->addButton("Cancel", QMessageBox::RejectRole);

    int iconsize = app.style()->pixelMetric(QStyle::PM_MessageBoxIconSize);
    msgbox->setIconPixmap(icon.pixmap(iconsize));
    msgbox->show();

    QObject::connect(msgbox, &QDialog::accepted, [pid]() { try_kill(pid); });
    QObject::connect(msgbox, &QObject::destroyed, QApplication::quit);

    return app.exec();
}
