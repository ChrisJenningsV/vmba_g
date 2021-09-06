import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vmba/calendar/flightPageUtils.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/models/models.dart';
import '../helper.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';



//class CustomWidget {
Widget appBar(BuildContext context, String title,
    {Widget leading, bool automaticallyImplyLeading, List<Widget> actions, Color backgroundColor,
        NewBooking newBooking,
        String imageName,  double elevalion, NetworkImage backgroundImage,
        Widget bottom, double toolbarHeight,
        int curStep}) {
  if( automaticallyImplyLeading == null ) {automaticallyImplyLeading=true;}
  if( bottom != null ){
    logit( 'bottom on page $title');
  }
  bool wantOutline = false;
  double height = 80;
  if( gblSettings.wantTallPageImage ) {
    height = 140;
  }
  if( curStep == null ){
    curStep = 1;
  }

  if( gblSettings.wantTallPageImage && gblSettings.wantStatusLine && imageName != null && newBooking != null) {
    Color txtCol = Colors.white;
    Color backCol = Colors.grey.withOpacity(0.6);
    TextStyle tStyle = TextStyle( color:  txtCol);
    //TextStyle cityStyle = TextStyle( color:  txtCol);
    var row1 = Row(children: [

      FutureBuilder(
        future: cityCodeToName(
          newBooking.departure,
        ),
        initialData: newBooking.departure.toString(),
        builder: (BuildContext context, AsyncSnapshot<String> text) {
          return new Text(text.data,
              style:  tStyle);
        },
      ),
      //TrText(newBooking.departure, style: tStyle, textScaleFactor: 2) ,
      RotatedBox(
          quarterTurns: 1,
          child: new Icon(
            Icons.airplanemode_active,
            size: 20,
            color: txtCol,
          )),
      FutureBuilder(
        future: cityCodeToName(
          newBooking.arrival,
        ),
        initialData: newBooking.arrival.toString(),
        builder: (BuildContext context, AsyncSnapshot<String> text) {
          return new Text(
            text.data,
            style: tStyle,
          );
        },
      ),
      Spacer(),
      Text( getIntlDate('EEE dd MMM', newBooking.departureDate), style: TextStyle(color: txtCol),)
    ],);

    List <Widget> list = [];

    list.add(Text(newBooking.passengers.adults.toString() , style: tStyle));
    list.add(Icon(Icons.person,color: txtCol, size: 15,));
    list.add(Padding(padding: EdgeInsets.only(left: 5),));

    if( newBooking.passengers.children > 0) {
      list.add( Text(newBooking.passengers.children.toString(), style: tStyle));
      list.add(Icon(Icons.child_care,color: txtCol, size: 15));
      list.add(Padding(padding: EdgeInsets.only(left: 5),));
    }

    if( newBooking.passengers.infants > 0) {
      list.add( Text(newBooking.passengers.infants.toString(), style: tStyle));
      list.add(Icon(Icons.child_friendly,color: txtCol, size: 15));
      list.add(Padding(padding: EdgeInsets.only(left: 5),));
    }

    if( newBooking.passengers.youths > 0) {
      list.add( Text(newBooking.passengers.youths.toString(), style: tStyle));
      //list.add( Text('Y'));
      list.add(Icon(Icons.directions_run,color: txtCol, size: 15));
      list.add(Padding(padding: EdgeInsets.only(left: 5),));
    }

    if( newBooking.passengers.students > 0) {
      list.add( Text(newBooking.passengers.students.toString(), style: tStyle));
      //list.add( Text('Y'));
      list.add(Icon(Icons.school, color: txtCol, size: 15));
      list.add(Padding(padding: EdgeInsets.only(left: 5),));
    }

    if( newBooking.passengers.seniors > 0) {
      list.add( Text(newBooking.passengers.seniors.toString(), style: tStyle));
      //list.add( Text('S'));
      list.add(Icon(Icons.directions_walk,color: txtCol, size: 15));
      list.add(Padding(padding: EdgeInsets.only(left: 5),));
    }
    list.add(Spacer());
    list.add(Text( gblPayable, style: TextStyle(color: txtCol)));


  var row2 = Row(children: list);


  List<Widget> widgets = [];
    widgets.add(row1);
    widgets.add(row2);


    if( gblSettings.wantProgressBar) {
      Widget status = _getStatus(context, curStep);
      widgets.add(status);
    }

    bottom = PreferredSize(
        child: Container(
          color: backCol,
        child: Column( children: widgets, ))
        , preferredSize: Size.fromHeight(40.0),) ;
    height = 140;
  }

  Widget flexibleSpace ;

  if( backgroundImage != null ) {
    flexibleSpace = Image(
      image:
        backgroundImage,
      fit: BoxFit.cover,);
    backgroundColor = Colors.transparent;
  }

  if( imageName != null && imageName.isNotEmpty) {
    // map page name to image name
    Map pageMap = json.decode(gblSettings.pageImageMap.toUpperCase());
    String pageImage = pageMap[imageName.toUpperCase()];

    switch (pageImage) {
      case '[DEST]':
        pageImage = gblDestination;
        break;
    }
    if( pageImage == null) {
      pageImage = 'blank';
    }


    backgroundImage = NetworkImage('${gblSettings.gblServerFiles}/pageImages/$pageImage.png');
    if( backgroundImage != null ) {
      flexibleSpace = Image(
        image:
        backgroundImage,
        fit: BoxFit.cover,);
      //backgroundColor = Colors.transparent;
      wantOutline = true;
      //toolbarHeight = 100;

      return PreferredSize(
          preferredSize: Size.fromHeight(height),
          child:  AppBar(
            leading: leading,
            bottom: bottom,
            //toolbarHeight: toolbarHeight,
            flexibleSpace: flexibleSpace,
            elevation: elevalion,
            automaticallyImplyLeading: automaticallyImplyLeading,
            centerTitle: gblCentreTitle,
            brightness: gblSystemColors.statusBar,
            backgroundColor: Colors.transparent,

            iconTheme: IconThemeData(
                color: Colors.white),
            title: getText(title),
            actionsIconTheme: IconThemeData( color: Colors.white),
            actions: actions,
          ));


    }

  }


  if( flexibleSpace != null ) {
    wantOutline = true;
  }

  if( gblSettings.wantLeftLogo && leading == null ) {
    return AppBar(
      flexibleSpace: flexibleSpace,
      centerTitle: gblCentreTitle,
      toolbarHeight: toolbarHeight,
      elevation: elevalion,
      leading: gblSettings.wantLeftLogo ? Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Image.asset(
              'lib/assets/$gblAppTitle/images/appBarLeft.png',
              color: Color.fromRGBO(255, 255, 255, 0.1),
              colorBlendMode: BlendMode.modulate)) :Text(''),
      brightness: gblSystemColors.statusBar,
      backgroundColor: (backgroundColor == null) ? gblSystemColors.primaryHeaderColor : backgroundColor,
      iconTheme: IconThemeData(
          color: gblSystemColors.headerTextColor),
      title: new TrText(title,
          style: TextStyle(
              color: gblSystemColors.headerTextColor),
          variety: 'title'),
      actions: actions,
      bottom: bottom,
    );

  } else {
    Widget ab = AppBar(
      leading: leading,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
      flexibleSpace: flexibleSpace,
      elevation: elevalion,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: gblCentreTitle,
      brightness: gblSystemColors.statusBar,
      backgroundColor: (backgroundColor == null) ? gblSystemColors.primaryHeaderColor : backgroundColor,

      iconTheme: IconThemeData(
          color: gblSystemColors.headerTextColor),
      title: wantOutline ? getText(title) : new TrText(title,
          style: TextStyle(
              color: gblSystemColors.headerTextColor),
              variety: 'title',),
        actions: actions,
    );
    return ab;
  }

}



Widget getText(String txt) {
return Stack(
  children: <Widget>[
    // Stroked text as border.
    Text(
      translate(txt),
      textScaleFactor: 1.25,
      style: TextStyle(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.grey.shade800,
      ),
    ),
    // Solid text as fill.
    Text(
      translate(txt),
      textScaleFactor: 1.25,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
  ],
);

}

Widget _getStatus(BuildContext context, int curStep ) {
  List <String> _steps= ['Search', 'Flights', 'Summary', 'Pax', 'Pay'];
  //List <IconData> _icons = [Icons.input, Icons.airplanemode_active, Icons.sim_card_outlined, Icons.person_outline, Icons.credit_card];
Color textClr = gblSystemColors.progressTextColor;

  return Container(
    color: gblSystemColors.progressBackColor,
   child:   StepProgressIndicator(
      totalSteps: 6,
      currentStep: curStep,
      size: 35,
      selectedColor: gblSystemColors.primaryHeaderColor.withOpacity(0.3),
      unselectedColor: Colors.grey.shade100.withOpacity(0.3),
      customStep: (index, color, _) {
        if (index <= curStep) {
          if( index == curStep) {
            return Container(
                color: gblSystemColors.progressBackColor,
                child: RotatedBox(
                    quarterTurns: 1,
                    child: new Icon(
                      Icons.airplanemode_active,
                      size: 30,
                      color: gblSystemColors.progressTextColor,
                    )));
          }
          return Container(
              color: gblSystemColors.progressBackColor,
            child: Column( children: [
            Text(translate(_steps[index]), textScaleFactor: 0.75, style: TextStyle(color: textClr),),
              Padding(padding: EdgeInsets.only(top: 5),),
              Container(height: 4,
                color: gblSystemColors.progressTextColor,),
              //Divider(color: Colors.grey, height: 4,),
              Spacer(),

          ]));
        } else {
          return Container(
            color: gblSystemColors.progressBackColor,
            child: Icon(
              Icons.cloud_outlined,
              color: gblSystemColors.progressTextColor,
              size: 15,
            ),
          );
        }
      }

  )    );

}

/*
Widget _drawStep(int index, Color color, int curStep ) {
  if( index <= curStep) {
  return Container(
    color: color,
    child: Column( children: [
      Text( index.toString()),
      Icon(
      Icons.check,
      color: Colors.white,
    )
  ]
  ));

  } else {
  return  Container(
  color: color,
  child: Icon(
  Icons.remove,
  ));
}
}
*/
/*
class Underline extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(0, 0);
    final p2 = Offset(50, 0);
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4;
    canvas.drawLine(p1, p2, paint);  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
*/