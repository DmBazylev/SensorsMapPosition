#include "customposition.h"

CustomPosition::CustomPosition(QObject *parent) : QObject(parent)
{

    positionInfoSource= QGeoPositionInfoSource::createDefaultSource(this);//создание объекта класса Позиционирования через статический метод с параметром в виде родителя (класса)

    //if the source was created then
    if (positionInfoSource) {
        //connection is created for reading coordinates into the slot when a coordinate change signal is received
        connect(positionInfoSource, SIGNAL(positionUpdated(QGeoPositionInfo)),
                this, SLOT(positionUpdated(QGeoPositionInfo)));

        positionInfoSource->startUpdates();//start source
    }

    db=QSqlDatabase::addDatabase("QSQLITE");//the class object is created by a static method to which the database driver is passed, in this case "QSQLITE"
 //   db.setDatabaseName("D:/QtDataBases/PositionInTimeDB.db");//creating a database file by specifying its location in the computer (DESKTOP)

    db.setDatabaseName("./PositionInTimeDB.db");//create a database file by specifying its location in the build folder (this is also suitable for ANDROID)

    if (db.open())
    {
        qDebug()<<"open";
    }
    else
    {
        qDebug()<<"no open";
    }

    query=new QSqlQuery(db);//creating an object of the database class (for queries to it), we pass an object of the database class to it, but you can also not transfer it, it will take it by default

    /*the string inside the query->exec() is the language of SQL, he has a different syntax for different databases, in this case, the syntax for "QSQLITE"
specifically, this line creates a table called Positioning In Time with three columns time (the type of the variable QString),latitude (type double variable),longitude (variable type - double)
types of variables in SQL if not strict then to insert the variable is not of this type, it will not result in an error, the database converts it to the desired type
    */
    query->exec("CREATE TABLE  IF NOT EXISTS PositioningInTime(time QString,latitude double,longitude double);");//creating a table, in "SQLITE" when creating a table, the query must be whole, i.e. one whole row and not several

}

double CustomPosition::getLatitude()
{

    return latitude;
}

double CustomPosition::getLongitude()
{
    return longitude;
}

double CustomPosition::getQueryLatitude()
{
    return queryLatitude;
}

double CustomPosition::getQueryLongitude()
{
    return queryLongitude;
}

QString CustomPosition::getQueryTime()
{
    return queryTime;
}

double CustomPosition::getLastTakenLatitude()
{
    return lastTakenLatitude;
}

double CustomPosition::getLastTakenLongitude()
{
    return lastTakenLongitude;
}

QString CustomPosition::getLastTakenTime()
{
    return lastTakenTime;
}


void CustomPosition::cleanBeforeCertainDate()
{
    QString date= QDate::currentDate().addDays(-10).toString("yyyy.MM.dd");//subtract a certain number of days from the current date

    query->exec("DELETE FROM PositioningInTime WHERE time<'"+date+"';");//delete all records where the time is earlier than this date
}

void CustomPosition::selectLastApproxPosInTime(QString timeToFind)
{

    query->exec("SELECT time,latitude,longitude FROM PositioningInTime WHERE time<='"+timeToFind+"';");//if the value is entered by the user during the execution of the program

    QSqlRecord rec=query->record();//the selected values (records) of the table are accessed via the query->record() method; which returns an object of the QSqlRecord class

    while(query->next())//assignment of selected records is VERY IMPORTANT when selecting records, the first selected record is indicated via the query->next() method, etc. i.e. if you simply specify the rec of the current record, nothing will come out
    {
        //assign the selected records to the class parameters for from transfer to QML
        queryTime=query->value(rec.indexOf("time")).toString();
        queryLatitude=query->value(rec.indexOf("latitude")).toDouble();
        queryLongitude=query->value(rec.indexOf("longitude")).toDouble();
    }

}

void CustomPosition::selectLastPosInTime()
{

    query->exec("SELECT * FROM PositioningInTime order by rowid desc LIMIT 1;");//select the last record from the database
    QSqlRecord rec=query->record();

    while(query->next())//and output it
    {
        lastTakenTime=query->value(rec.indexOf("time")).toString();
        lastTakenLatitude=query->value(rec.indexOf("latitude")).toDouble();
        lastTakenLongitude=query->value(rec.indexOf("longitude")).toDouble();
    }
}


 QVariantList CustomPosition::getCoordToDrawWayFromBD(QString startMomentToDrawWay, QString finishMomentToDrawWay)
{

     QList<QVariant> listVariantGeoCoordinateToDrawWay;
     QVariant var;//creating an object of the QVariant class to fill the path listVariantGeoCoordinateToDrawWay

    //select all coordinates from the database in a given time interval from start Moment To Draw Way to finishMomentToDrawWay
     query->exec("SELECT time,latitude,longitude FROM PositioningInTime WHERE time<'"+finishMomentToDrawWay+"' AND time>'"+startMomentToDrawWay+"';");//если значение вводится пользователем в ходе исполнения программы

    QSqlRecord rec=query->record();//the selected values (records) of the table are accessed via the query->record() method; which returns an object of the QSqlRecord class

    while(query->next())//assignment of selected records is VERY IMPORTANT when selecting records, the first selected record is indicated via the query->next() method, etc. i.e. if you simply specify the rec of the current record, nothing will come out
    {
        //assign a temporary object of the QVariant class the value of the next coordinate of the path from the database
        var.setValue(QGeoCoordinate(query->value(rec.indexOf("latitude")).toDouble(),query->value(rec.indexOf("longitude")).toDouble()));

        listVariantGeoCoordinateToDrawWay.append(var);//and put this object into list
    }

    return listVariantGeoCoordinateToDrawWay;

 }

 void CustomPosition::positionUpdated(const QGeoPositionInfo &info)
 {

        latitude=info.coordinate().latitude();
        longitude=info.coordinate().longitude();

        /*
        preparing a query using the query->prepare() method
        Insert values into the Positioning In Time table, in its time,latitude,longitude columns
        */
         query->prepare("INSERT INTO PositioningInTime (time,latitude,longitude) "
                        "VALUES (:time, :latitude, :longitude)");

         query->bindValue(":time", QDateTime::currentDateTime().toString("yyyy.MM.dd.hh.mm.ss"));//in the time column, the current date and time in a certain format is passed to the current.toString method("dd.MM.yyyy.hh.mm.ss") the required date and time format in the string version
         query->bindValue(":latitude", latitude);//in the latitude column, the latitude value
         query->bindValue(":longitude", longitude);//in the longitude column, the longitude value
         query->exec();//execution of the prepared request

         //====================================================================================================

         emit positionChanged();//send signal to QML



 }










