#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "custommagnetometer.h"
#include "customposition.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);//adjust the dimensions according to the phone screen - scaling to the system

    QGuiApplication app(argc, argv);

    qmlRegisterType<CustomMagnetometer>("com.myinc.CustomMagnetometer",1,0,"CustomMagnetometer");//register class CustomMagnetometer in QML
    qmlRegisterType<CustomPosition>("com.myinc.CustomPosition",1,0,"CustomPosition");//register class CustomPosition in QML

    QQmlApplicationEngine engine;//create object of class QQmlApplicationEngine

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
