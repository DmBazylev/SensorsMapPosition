#include "custommagnetometer.h"

CustomMagnetometer::CustomMagnetometer()
{
    magnetometer=new QMagnetometer(this);
    x=0;
    y=0;
    switchOn=false;

    magnetometer->setReturnGeoValues(false);//obtaining the initial magnetic flux density
    magnetometer->setSkipDuplicates(true);//skipping duplicates to save resources and energy

}

qreal CustomMagnetometer::getX()
{
    return x;
}

qreal CustomMagnetometer::getY()
{
    return y;
}

void CustomMagnetometer::setSwitchOn()
{
    switchOn=(switchOn==true)?false:true;

    if (switchOn)
    {
         magnetometer->setActive(true);
        connect(magnetometer,&QMagnetometer::readingChanged,[&](){

            x=magnetometer->reading()->x()*1000000;//obtaining the magnetic field along the x-axis in tesla (be sure to multiply by 1000000) otherwise the value is very small rounded to 0
            y=magnetometer->reading()->y()*1000000;//obtaining the magnetic field along the y-axis in tesla (be sure to multiply by 1000000) otherwise the value is very small rounded to 0

            //send signals to QML
            emit xChanged();
            emit yChanged();
        });

        magnetometer->start();

    }
    else if (!switchOn)
    {
        magnetometer->stop();
        magnetometer->setActive(false);
    }



}
