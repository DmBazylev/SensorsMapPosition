#ifndef CUSTOMMAGNETOMETER_H
#define CUSTOMMAGNETOMETER_H

#include <QMagnetometer>

class CustomMagnetometer: public QObject
{
    Q_OBJECT
public:
    CustomMagnetometer();
    //the Q_INVOKABLE macro makes the method accessible from QML
    Q_INVOKABLE  qreal getX();
    Q_INVOKABLE qreal getY();
    Q_INVOKABLE void setSwitchOn();

private:
    Q_PROPERTY(qreal x READ getX)//the Q_PROPERTY macro makes a member of class x accessible from QML to the right of READ is the name of the method that reads (and passes) the value of x (getter)
    Q_PROPERTY(qreal y READ getY)

    QMagnetometer *magnetometer;//create Magnetometer object class
    qreal x;//the value of the magnetic field along the x axis
    qreal y;//the value of the magnetic field along the y axis
    bool switchOn;// switch on magnetometer from QML

signals:
    void xChanged();//signal when receiving the value of the magnetic field along the x axis
    void yChanged();//signal when receiving the value of the magnetic field along the y axis

};

#endif // CUSTOMMAGNETOMETER_H
