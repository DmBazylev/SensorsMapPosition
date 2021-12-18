import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import com.myinc.CustomMagnetometer 1.0//import custom magnetometer from C++
import com.myinc.CustomPosition 1.0//import custom positioning from C++

import QtLocation 5.6
import QtPositioning 5.6//to set MapQuickItem property coordinate:  QtPositioning.coordinate(customPosition.latitude, customPosition.longitude);
import QtSensors 5.2//for LightSensor

Window {
    id:window
    visible: true
    width: 640
    height: 480

    Plugin //the plugin downloads the map from a source on the Internet
    {
        id: osmMapPlugin
        name: "osm"

        //provide the address of the tile server to the plugin
        PluginParameter {
            name: "osm.mapping.custom.host"
            value: "http://localhost/osm/"    //ip address of source
        }

        /*disable retrieval of the providers information from the remote repository.
       If this parameter is not set to true (as shown here), then while offline,
       network errors will be generated at run time*/
        PluginParameter {
            name: "osm.mapping.providersrepository.disabled"
            value: true
        }
    }

    Map {
        id:map
        anchors.fill: parent
        plugin: osmMapPlugin
        visible: true

        center{
            latitude:43.10
            longitude:131.86
        }

        zoomLevel: 14//map scaling - the larger the number, the larger the map and vice versa

    }


    //==========================================Position in present time=========================================================
    MapQuickItem
    {
        id:marker
        coordinate:  QtPositioning.coordinate(customPosition.latitude, customPosition.longitude);//placed in the coordinates sent by the geolocation source (position in present time)
        visible:true
        sourceItem: Rectangle
        {
            width: 3
            height:width
            color:"black"
        }

        //the addition is carried out through the add Map Item() method, which is called when a signal is received from Component that it has been created

        Component.onCompleted:
        {
            map.addMapItem(marker)//adding a marker element to the map (in this case, it is the location of the phone on the map)
        }

        zoomLevel: 0.0//object remains the same size on the screen at all zoom levels, you can 0.0 and not specify this by default

    }

    //==========================================Position at a certain time=========================================================
    MapQuickItem
    {
        id:markerInTime
        visible:false
        sourceItem: Rectangle
        {
            //id:rect
            width: 4
            height:width
            radius:width/2
            color:"red"
        }

        Component.onCompleted: //добавление осуществляется через метод addMapItem() который вызывается при получении сигнала от Component о том что он создан
        {
            map.addMapItem(markerInTime)//добавление в карту элемента маркера (точка нахождения телефона на карте в определенное время)
        }

        zoomLevel: 0.0//объект остается одного и того же размера на экране при всех уровнях масштабирования, можно 0.0 и не указывать это умолчанию

    }

    //======================================================Visual element of the output of the time of obtaining coordinates=================================================================

    Rectangle{
        id:time
        x:markerInTime.x-50
         y:markerInTime.y-20

        width:120
        height:25

        color:"transparent"

        Text{
            id:timeText
            font.pixelSize:10
            text:""
        }


    }

    //======================================================The path in a certain period of time on map=================================================================

    MapPolyline{
        id:createWay
        width:150
        height:30

        line.color:"black"
        line.width:1
        Component.onCompleted: {
            map.addMapItem(createWay)
           }

    }


    //========================================ToolBar==================================================================================
    Row
    {

        x:10
        y:15
        anchors.horizontalCenter: parent.Center

        spacing:10


        //=================button Compass=========================================================
        Rectangle {
            width:80
            height:30
            radius:5
            border.color:"green"
            color: "transparent"
            Text{
                anchors.centerIn: parent
                font.pixelSize:8
                text:"COMPASS"

            }
            MouseArea{
                anchors.fill:parent
                onClicked: {
                    customMagnetometer.setSwitchOn();
                    compass.visible=(compass.visible==true)?false:true
                }
            }
        }


        //=================button GeoCoordinate=========================================================
        Rectangle {
            width:80
            height:30
            radius:5
            border.color:"blue"
            color: "transparent"
            Text{
                anchors.centerIn: parent
                font.pixelSize:8
                text:"GEOCOORDINATE"
            }
            MouseArea{
                anchors.fill:parent
                onClicked: {
                    position.visible=(position.visible===true)?false:true
                }
            }
        }

        //=================button to show LightSensor=========================================================
        Rectangle {
            width:80
            height:30
            radius:5
            border.color:"red"
            color: "transparent"//прозрачный цвет
            Text{
                anchors.centerIn: parent
                font.pixelSize:8
                color:"black"
                text:"LIGHTSENSOR"
            }
            MouseArea{
                anchors.fill:parent
                onClicked: {
                     rectLightSensor.visible=(rectLightSensor.visible===true)?false:true

                    if(rectLightSensor.visible==true)
                    {
                        lightSensor.active=true;
                        lightSensor.start();
                    }
                    else if(rectLightSensor.visible==false)
                    {
                        lightSensor.stop();
                        lightSensor.active=false;
                    }
                }
            }

        }

        //=================button to exit from App=========================================================
        Rectangle {//кастомизированная кнопка выхода из приложения
            id:quitButton
            width:80
            height:30
            radius:5
            border.color:"lightgreen"
            color: "transparent"

            Text{
                anchors.centerIn: parent
                font.pixelSize:8
                text:"EXIT"
            }
            MouseArea{
                anchors.fill:parent
                onClicked: {
                    customPosition.cleanBeforeCertainDate();//crear dataBase from records that early than certain date
                    Qt.quit();//exit from application
                }
            }
        }

    }

    //==========================================================================================================================

    Row
    {

        x:10
        y:50
        anchors.horizontalCenter: parent.Center
        spacing:10

        //=================button to search for a position in a certain place at a certain time=========================================================
        Rectangle {
            width:80
            height:30
            radius:5
            border.color:"darkRed"
            color: "transparent"
            Text{
                anchors.centerIn: parent
                font.pixelSize:8
                text:"FIND POSITION"+'\n'+"IN REQUESTED TIME"
            }
            MouseArea{
                anchors.fill:parent
                onClicked: {
                    findPosInTime.visible=(findPosInTime.visible===true)?false:true

                }
            }
        }

        //=================button to show way in requested period time=========================================================
        Rectangle {
            width:80
            height:30
            radius:5
            border.color:"darkCyan"
            color: "transparent"
            Text{
                anchors.centerIn: parent
                font.pixelSize:8
                text:"SHOW WAY"

            }
            MouseArea{
                anchors.fill:parent
                onClicked: {
                       rectToGetWay.visible=(rectToGetWay.visible==true)?false:true
                }
            }
        }

        //=================button to clear way =========================================================
        Rectangle {
            width:80
            height:30
            radius:5
            border.color:"darkGreen"
            color: "transparent"
            Text{
                anchors.centerIn: parent
                font.pixelSize:8
                text:"CLEAR WAY"
            }
            MouseArea{
                anchors.fill:parent
                onClicked: {
                   createWay.path=[];
                }
            }
        }

//===========================================button to show last position===========================================================
    Rectangle {
        width:80
        height:30
        radius:5
        border.color:"red"
        color: "transparent"
        Text{
            anchors.centerIn: parent
            font.pixelSize:8
            text:"LAST COORDINATE"
        }
        MouseArea{
            anchors.fill:parent
            onClicked: {
                customPosition.selectLastPosInTime();

                markerInTime.coordinate=QtPositioning.coordinate(customPosition.getLastTakenLatitude(), customPosition.getLastTakenLongitude());//элемент карты ставится в координаты присылаемые источником геопозиционирования (координаты в определенное время из базы данных)
               timeText.text=customPosition.getLastTakenTime();
                map.center.latitude=customPosition.getLastTakenLatitude();
                map.center.longitude=customPosition.getLastTakenLongitude();

                markerInTime.visible=true;
            }
        }
    }


}


    //==========================================================================================================================
    //==========================================================================================================================
    //==========================================================================================================================


    Rectangle{
        id:root

        //====================================================COMPASS======================================================================


        Rectangle{
            id:compass
            x:50
            y:150           
            width: 300
            height:width
            color: "transparent"//прозрачный цвет
            visible:false

     //=======================================================================================================================

            Canvas{
                anchors.fill:parent
                id:canvas

                //custom comfort drawing properties
                property double widthToDrawCompass:200/2
                property double heightToDrawCompass:widthToDrawCompass
                property double dec:widthToDrawCompass/10
                property double shiftFromLeftUpCorner:50+0

                onPaint: {
                    var ctx=getContext("2d");//creating a context object
                    ctx.strokeStyle="black"//set border line color
                    ctx.lineWidth=1.5//set border line width

//=======================================================================================================================================
                    // drawing a circle using the arc method (below)
                    /* There is an
                    arc method for drawing circles, which needs to be passed six parameters at once:
                    1)The horizontal coordinate of the center of the circle on the canvas (in pixels)
                    2)The vertical coordinate of the center of the circle on the canvas (in pixels)
                    3)Circle radius (in pixels)
                    4)The initial angle of the circle (in radians!)
                    5)The final angle of the circle (in radians!)
                    6)Draw clockwise or counterclockwise (if against, then the value is "false", and if clockwise, then "true"). By default, it draws counterclockwise
                    */


                    ctx.strokeStyle="rgb(255, 0, 255)";//purple circle color
                    ctx.arc(widthToDrawCompass+shiftFromLeftUpCorner, heightToDrawCompass+shiftFromLeftUpCorner, widthToDrawCompass-(widthToDrawCompass/10), 0, 2 * Math.PI);//circle drawing method, the sixth parameter (which is the default) is omitted
                    ctx.stroke();//draw lines

                    ctx.strokeStyle="red"//red circle color
                    ctx.beginPath();
                    ctx.arc(widthToDrawCompass+shiftFromLeftUpCorner, heightToDrawCompass+shiftFromLeftUpCorner, widthToDrawCompass-(widthToDrawCompass/3), 0, 2 * Math.PI);
                    ctx.stroke();

                    ctx.strokeStyle="darkRed"//dark circle color
                    ctx.beginPath();
                    ctx.arc(widthToDrawCompass+shiftFromLeftUpCorner, heightToDrawCompass+shiftFromLeftUpCorner, widthToDrawCompass-(widthToDrawCompass/2), 0, 2 * Math.PI);
                    ctx.stroke();


//=======================================================================================================================================

                    ctx.strokeStyle="black"//set border line color
                    ctx.beginPath()
                    //arrows
                    //up arrow
                    ctx.moveTo(widthToDrawCompass+shiftFromLeftUpCorner,shiftFromLeftUpCorner+dec)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner+dec,heightToDrawCompass+shiftFromLeftUpCorner-dec)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner,heightToDrawCompass+shiftFromLeftUpCorner)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner-dec,heightToDrawCompass+shiftFromLeftUpCorner-dec)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner,shiftFromLeftUpCorner+dec)

                    //right arrow
                    ctx.moveTo(2*widthToDrawCompass+shiftFromLeftUpCorner-dec,heightToDrawCompass+shiftFromLeftUpCorner)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner+dec,heightToDrawCompass+shiftFromLeftUpCorner+dec)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner,heightToDrawCompass+shiftFromLeftUpCorner)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner+dec,heightToDrawCompass+shiftFromLeftUpCorner-dec)
                    ctx.lineTo(2*widthToDrawCompass+shiftFromLeftUpCorner-dec,heightToDrawCompass+shiftFromLeftUpCorner)

                    //down arrow
                    ctx.moveTo(widthToDrawCompass+shiftFromLeftUpCorner,heightToDrawCompass+shiftFromLeftUpCorner)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner+dec,heightToDrawCompass+shiftFromLeftUpCorner+dec)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner,2*heightToDrawCompass+shiftFromLeftUpCorner-dec)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner-dec,heightToDrawCompass+shiftFromLeftUpCorner+dec)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner,heightToDrawCompass+shiftFromLeftUpCorner)

                    //left arrow
                    ctx.moveTo(shiftFromLeftUpCorner+dec,heightToDrawCompass+shiftFromLeftUpCorner)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner-dec,heightToDrawCompass+shiftFromLeftUpCorner-dec)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner,heightToDrawCompass+shiftFromLeftUpCorner)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner-dec,heightToDrawCompass+shiftFromLeftUpCorner+dec)
                    ctx.lineTo(shiftFromLeftUpCorner+dec,heightToDrawCompass+shiftFromLeftUpCorner)
//=======================================================================================================================================
                    // vertical and horisontal lines
                    //vertical line from the top vertex of the top arrow to the bottom vertex of the bottom arrow
                    ctx.moveTo(widthToDrawCompass+shiftFromLeftUpCorner,shiftFromLeftUpCorner+dec)
                    ctx.lineTo(widthToDrawCompass+shiftFromLeftUpCorner,2*heightToDrawCompass+shiftFromLeftUpCorner-dec)

                    //horizontal line from the left vertex of the left arrow to the right vertex of the right arrow
                    ctx.moveTo(shiftFromLeftUpCorner+dec,heightToDrawCompass+shiftFromLeftUpCorner)
                    ctx.lineTo(2*widthToDrawCompass+shiftFromLeftUpCorner-dec,heightToDrawCompass+shiftFromLeftUpCorner)

//=======================================================================================================================================
                    //arrows between the left, right, upper and lower arrows (at an angle of 45 degrees to them)
                    // between the top and left
                    ctx.moveTo(7.5*dec+shiftFromLeftUpCorner,9*dec+shiftFromLeftUpCorner)
                    ctx.lineTo(5*dec+shiftFromLeftUpCorner,5*dec+shiftFromLeftUpCorner)
                    ctx.lineTo(9*dec+shiftFromLeftUpCorner,7.5*dec+shiftFromLeftUpCorner)

                    //between down and right
                    ctx.moveTo(12.5*dec+shiftFromLeftUpCorner,11*dec+shiftFromLeftUpCorner)
                    ctx.lineTo(15*dec+shiftFromLeftUpCorner,15*dec+shiftFromLeftUpCorner)
                    ctx.lineTo(11*dec+shiftFromLeftUpCorner,12.5*dec+shiftFromLeftUpCorner)

                    //between right and up
                    ctx.moveTo(11*dec+shiftFromLeftUpCorner,7.5*dec+shiftFromLeftUpCorner)
                    ctx.lineTo(15*dec+shiftFromLeftUpCorner,5*dec+shiftFromLeftUpCorner)
                    ctx.lineTo(12.5*dec+shiftFromLeftUpCorner,9*dec+shiftFromLeftUpCorner)

                    //between left and down
                    ctx.moveTo(7.5*dec+shiftFromLeftUpCorner,11*dec+shiftFromLeftUpCorner)
                    ctx.lineTo(5*dec+shiftFromLeftUpCorner,15*dec+shiftFromLeftUpCorner)
                    ctx.lineTo(9*dec+shiftFromLeftUpCorner,12.5*dec+shiftFromLeftUpCorner)

 //=======================================================================================================================================
                    //lines from the vertices of the arrows that are at 45 degrees to the opposite

                    // line from the top of the upper left arrow to the top of the lower right arrow
                    ctx.moveTo(5*dec+shiftFromLeftUpCorner,5*dec+shiftFromLeftUpCorner)
                    ctx.lineTo(15*dec+shiftFromLeftUpCorner,15*dec+shiftFromLeftUpCorner)

                    //line from the top of the upper right arrow to the top of the lower left arrow
                    ctx.moveTo(15*dec+shiftFromLeftUpCorner,5*dec+shiftFromLeftUpCorner)
                    ctx.lineTo(5*dec+shiftFromLeftUpCorner,15*dec+shiftFromLeftUpCorner)
//=======================================================================================================================================
                    ctx.stroke()//drawing of all the above lines (up to the upper command)this command draws all the lines that were started after the ctx.beginPath() command

//======================drawing letters (north N south S west W east E)=======================================================================
                    ctx.font = "24px serif";//set font size and type

                    ctx.fillStyle="blue"//set font color (in that case)
                    ctx.fillText('N', shiftFromLeftUpCorner+10*dec-8,5*dec-8);//draw text (one letter in that case)

                    ctx.fillStyle="red"//set font color (in that case)
                    ctx.fillText('S', shiftFromLeftUpCorner+10*dec-8,25*dec+25);

                    ctx.fillStyle="rgb(102,51,0)"//brown
                    ctx.fillText('W', shiftFromLeftUpCorner-24,15*dec+6);

                    ctx.fillStyle="rgb(0,153,153)"//sea wave
                    ctx.fillText('E', shiftFromLeftUpCorner+20*dec+2,15*dec+6);

               }


            }


        //=======================================================================================================================


            //compass arrow
            Rectangle{
                id:arrow
                //to set the position and size of the arrow, I use the compass's own canvas properties (listed above)
                x:canvas.widthToDrawCompass+canvas.shiftFromLeftUpCorner-canvas.dec
                y:canvas.heightToDrawCompass+canvas.shiftFromLeftUpCorner-9*canvas.dec
                width:2*canvas.dec
                height:18*canvas.dec
                color: "transparent"//transparent background color so as not to see the rectangle - the base of the arrow
               // I don't set the visible property because it is a child element of the compass and it takes the visible property of the parent

                property real arrowRotation: 0//angle of rotation of the arrow

                function updateArrow()//the function of turning the arrow according to the readings of the magnetic field received from the C++ code, functions in QML are created in JavaScript
                {
                    //set the angle calculated by the inverse tangent, Math is a JavaScript module that contains a mathematical function, it is not C++ and QML is not!!!!!
                    // are used when evaluating the testimony of the fields X and Y from C++, returns a value in radians, to convert to degrees divided by PI and multiply by 180
                    arrow.arrowRotation = ((Math.atan2(customMagnetometer.xCustomMagnetometer, customMagnetometer.yCustomMagnetometer) / Math.PI) * 180);
                }

                //object of the C++ class (registered in main.cpp) receiving magnetometer readings from C++ and managing them
                CustomMagnetometer{
                    id:customMagnetometer
                    property real xCustomMagnetometer:0//fields for magnetometer readings
                    property real yCustomMagnetometer:0

                    //when receiving signals from a C++ object (an object of the Custom Magnetometer class in C++)
                    // we record the X and Y readings in the corresponding fields -getters of the C++ class are used (they are available here because they are declared in C++ as Q_INVOKABLE
                    onXChanged: {
                        xCustomMagnetometer=customMagnetometer.getX();
                        arrow.updateArrow();
                    }

                    onYChanged: {
                        yCustomMagnetometer=customMagnetometer.getY();
                        arrow.updateArrow();
                    }

                }

                //arrow draw with Canvas
                Canvas{
                    anchors.fill:parent
                    onPaint: {
                        var ctx=getContext("2d");//creating a context object
                        ctx.fillStyle ="blue"//set color figure
                        ctx.strokeStyle="black"//set color line (border line in that case)
                        ctx.lineWidth=1//line width
                        ctx.beginPath()//bagin drawing
                        ctx.moveTo(arrow.width/2,0)//draw triangle on coordinate
                        ctx.lineTo(arrow.width,arrow.height/2)
                        ctx.lineTo(0,arrow.height/2)
                        ctx.lineTo(arrow.width/2,0)
                        ctx.fill()//fill figure with color
                        ctx.stroke()//draw border line

                        ctx.fillStyle ="red"
                        ctx.strokeStyle="black"
                        ctx.lineWidth=1
                        ctx.beginPath()
                        ctx.moveTo(arrow.width/2,height)
                        ctx.lineTo(0,arrow.height/2)
                        ctx.lineTo(arrow.width,arrow.height/2)
                        ctx.lineTo(arrow.width/2,height)
                        ctx.fill()
                        ctx.stroke()

                    }


                }

                rotation: arrowRotation//turn the arrow to the calculated angle

            }


        }

    }

    //====================================================coordinate display element======================================================================

     Rectangle{
        id:position
        anchors.centerIn: parent
        width: 200
        height:100
        color: "transparent"
        visible:false

        CustomPosition//from C++
        {
            id:customPosition
            property double latitude:0;
            property double longitude:0;
            property double distance:0;

            onPositionChanged://when receiving a signal from the C++ class, we read the necessary information (longitude, latitude, distance)
            {
                latitude=customPosition.getLatitude();
                longitude=customPosition.getLongitude();
                txt.text="latitude: "+customPosition.latitude+'\n'+ "longitude: "+customPosition.longitude;
            }

        }

        Text{
            id:txt
            font.pixelSize:15
            anchors.centerIn: parent
            text: "latitude: "+customPosition.latitude+'\n'+ "longitude: "+customPosition.longitude

        }

    }


    //========================================================Visual element to find Position in Time===============================================================================

    Rectangle{
        id: findPosInTime

        anchors.centerIn: parent
        width: 170
        height:120
        border.color:"#C0C0C0"  //silver color
        border.width:2
        color: "transparent"
        radius:10
        visible:false

        Column{
            anchors.centerIn: parent
            spacing:15

            TextField//элемент ввода данных, он визуально отображается сам по себе, то есть в прямоугольник Rectangle его не обязательно засовывать
            {
                id:txtFd
                width:140
                height:30
                font.pointSize: 10
                placeholderText: "Enter date and time:\n yyyy.mm.dd.hh.mm.ss"
            }

            Rectangle
            {
                width:140
                height:30
                border.color:"black"
                color:"transparent"
                radius:5

                Text{
                    anchors.centerIn: parent
                    color:"darkRed"
                    font.pixelSize: 10
                    text:"ENTER"
                }

                MouseArea{
                    anchors.fill:parent
                    onClicked: {

                        customPosition.selectLastApproxPosInTime(txtFd.text);// the text field contains the value entered in the field
                        txtFd.text=""//after that clear data entry element

                        markerInTime.coordinate=QtPositioning.coordinate(customPosition.getQueryLatitude(), customPosition.getQueryLongitude());//элемент карты ставится в координаты присылаемые источником геопозиционирования (координаты в определенное время из базы данных)
                        timeText.text=customPosition.getQueryTime();
                        map.center.latitude=customPosition.getQueryLatitude();
                        map.center.longitude=customPosition.getQueryLongitude();

                        markerInTime.visible=true;

                    }
                }


            }


        }

    }


    //==========================================================Element to get time period for way ========================================================================

    Rectangle
    {
        id:rectToGetWay
        width:170
        height:180
        border.color:  "#C0C0C0"  //silver color
        border.width: 2
        color:"transparent"
        radius:10
        anchors.centerIn: parent
        visible: false

        Column
        {
            anchors.centerIn: parent
            spacing:20

            TextField//the data entry element, it is visually displayed by itself, that is, it is not necessary to put it in a rectangle in a Rectangle
            {
                id:textFieldStartWayTime
                width:140
                height:30
                font.pointSize: 8
                placeholderText: "Enter start moment" +'\n' +" way: yyyy.mm.dd.hh.mm.ss"
            }

            TextField
            {
                id:textFieldFinishWayTime
                width:140
                height:30
                font.pointSize: 8
                placeholderText: "Enter finish moment" +'\n' +" way: yyyy.mm.dd.hh.mm.ss"
            }


            Rectangle
            {
                id:buttonToInputTime
                width:140
                height:30
                border.color:"black"
                color:"transparent"
                radius:5

                Text{
                    anchors.centerIn: parent
                    color:"darkRed"
                    font.pixelSize: 10
                    text:"ENTER"
                }

                MouseArea{
                    anchors.fill:parent
                    onClicked: //here (in the button click handler) we remove the information from the input fields and transfer it to work and clean the fields themselves
                    {
                        createWay.path=customPosition.getCoordToDrawWayFromBD(textFieldStartWayTime.text,textFieldFinishWayTime.text);//we pass the information taken from the input fields to the method for forming there, based on the database, a sheet with coordinates for the path and assign the path MapPolyline (createWay.path) property to the C++ generated coordinate sheet
                        textFieldStartWayTime.text=""//cleaning the input fields
                        textFieldFinishWayTime.text=""
                    }
                }


            }

        }

    }

    //=======================================================LightSensor===================================================================


    Rectangle{
        id:rectLightSensor
        anchors.centerIn: parent
        width:200
        height:100
        color:"transparent"
        visible:false


        LightSensor{
            id: lightSensor
            dataRate:1000
                        skipDuplicates: true
                        onReadingChanged:
                        {
                            textLightSensor.text= "LIGHT LEVEL: "+ lightSensor.reading.illuminance +" LUX"

                        }

        }

        Text{
            id:textLightSensor
            anchors.centerIn: parent
            color:"darkRed"
            font.pixelSize:25
            text:"LIGHT LEVEL: "+"0"+" LUX"
        }


    }

}//Window







