#include <iostream>
#include <QApplication>
#include <QLabel>

int main(int argc, char** argv)
{
    if (!std::getenv("DISPLAY") && !std::getenv("WAYLAND_DISPLAY"))
    {
        std::cerr << "Error: No graphical display detected.\n"
                  << "If running headless, use: -platform offscreen\n";
        return 1;
    }

    QApplication app(argc, argv);
    QWidget w;

    w.show();

    return app.exec();
}