#ifndef CUSTOMPOSITION_H
#define CUSTOMPOSITION_H
#include <QGeoPositionInfoSource>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>

#include <QDateTime>
#include <QDebug>

class CustomPosition : public QObject
{
    Q_OBJECT
public:
    explicit CustomPosition(QObject *parent = nullptr);

public:
    //the Q_INVOKABLE macro provides access to methods from QML
    Q_INVOKABLE double getLatitude();
    Q_INVOKABLE  double getLongitude();
    Q_INVOKABLE double getQueryLatitude();
    Q_INVOKABLE  double getQueryLongitude();
    Q_INVOKABLE  QString getQueryTime();

    Q_INVOKABLE double getLastTakenLatitude();
    Q_INVOKABLE  double getLastTakenLongitude();
    Q_INVOKABLE  QString getLastTakenTime();

    Q_INVOKABLE void cleanBeforeCertainDate();//clear database earlier certain date

    Q_INVOKABLE  void selectLastApproxPosInTime(QString timeToFind);//select the last suitable value close to the parameter
    Q_INVOKABLE  void selectLastPosInTime();//select the last captured coordinates

    Q_INVOKABLE QVariantList getCoordToDrawWayFromBD(QString startMomentToDrawWay, QString finishMomentToDrawWay);// create a path for MapPolyline in QML from the database and returning it (passes the path to QML)

private:
    //prescribe the corresponding class members through the Q_PROPERTY macro so that they are accessible from the QML file
    Q_PROPERTY(double latitude READ getLatitude)
    Q_PROPERTY(double longitude READ getLongitude)

    QGeoPositionInfoSource* positionInfoSource;//object of the coordinate recipient class
    double latitude;
    double longitude;

    double queryLatitude;//latitude requested from the database
    double queryLongitude;//longitude requested from the database
    QString queryTime;//time requested from the database

    double lastTakenLatitude;// latitude which last put in database
    double lastTakenLongitude;//longitude which last put in database
    QString lastTakenTime;//time which last put in database

    QSqlDatabase db;//creating a database class object
    QSqlQuery* query;//creating a class object for queries (work) with the database

    QVector<QGeoCoordinate>vecAverageCoordinate;

   public slots:
    void positionUpdated(const QGeoPositionInfo &info);//slot to get coordinate

signals:
    void positionChanged();//position change signal (sent to QML)

};

#endif // CUSTOMPOSITION_H
