#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtPlugin>
#include <iostream>

/* Load toolchain Epaper Plugin */
Q_IMPORT_PLUGIN(QsgEpaperPlugin)


int main(int argc, char *argv[])
{
    qputenv("QMLSCENE_DEVICE", "epaper");
    qputenv("QT_QPA_PLATFORM", "epaper:enable_fonts");
    qputenv("QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS", "rotate=180");

    if (argc > 3) {
        std::cerr << "Usage: " << argv[0] << " [title] [subtitle]" << std::endl;
    }

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));


    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    auto rootObjects = engine.rootObjects();
    if (rootObjects.length() != 1) {
        std::cerr << "unexpected number of root objects: " << rootObjects.length() << std::endl;

        return -1;
    }

    if (argc > 1) {
        auto title = rootObjects.first()->findChild<QObject*>("title");
        if (title == NULL) {
            std::cerr << "cannot find title" << std::endl;

            return -1;
        }

        title->setProperty("text", argv[1]);
    }

    if (argc > 2) {
        auto subtitle = rootObjects.first()->findChild<QObject*>("subtitle");
        if (subtitle == NULL) {
            std::cerr << "cannot find subtitle" << std::endl;

            return -1;
        }

        subtitle->setProperty("text", argv[2]);
    }

    auto retval = app.exec();
    if (retval != 0 ) {
        return retval;
    }

    return 0;
}
