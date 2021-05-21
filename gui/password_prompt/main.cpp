#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtPlugin>
#include <iostream>
#include <cstring>

/* Load toolchain Epaper Plugin */
Q_IMPORT_PLUGIN(QsgEpaperPlugin)


int main(int argc, char *argv[])
{
    qputenv("QMLSCENE_DEVICE", "epaper");
    qputenv("QT_QPA_PLATFORM", "epaper:enable_fonts");
    qputenv("QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS", "rotate=180");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));


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

    auto passphraseInput = rootObjects.first()->findChild<QObject*>("passphraseField");
    if (passphraseInput == NULL) {
        std::cerr << "cannot find password field" << std::endl;

        return -1;
    }

    if ((argc > 1) && strcmp(argv[1], "incorrect") == 0) {

        auto incorrectNotification = rootObjects.first()->findChild<QObject*>("incorrectNotification");
        if (incorrectNotification == NULL) {
            std::cerr << "cannot find incorrect notification" << std::endl;

            return -1;
        }

        incorrectNotification->setProperty("visible", true);
    }

    auto retval = app.exec();
    if (retval != 0 ) {
        return retval;
    }

    std::cout << passphraseInput->property("text").toString().toStdString() << std::endl;

    return 0;
}
