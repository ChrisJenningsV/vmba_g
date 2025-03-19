import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/v3pages/controls/V3AppBar.dart';
import '../../Products/productFunctions.dart';
import '../../calendar/bookingFunctions.dart';
import '../../data/models/pnr.dart';
import '../../summary/FareRulesView.dart';
import '../../summary/summaryView.dart';
import '../../summary/vidFlightTimeline.dart';
import '../../v3pages/controls/V3Constants.dart';
import '../helper.dart';
import 'package:vmba/components/showDialog.dart';

double? imageWidth;
//class CustomWidget {
PreferredSizeWidget appBar(BuildContext context, String title, PageEnum pageEnum, String curPage,
    {Widget? leading,
      bool automaticallyImplyLeading=false, List<Widget>? actions,
        Color? backgroundColor,
        NewBooking? newBooking,
        String imageName = '',
        double? elevalion,
        NetworkImage? backgroundImage,
        PreferredSizeWidget? bottom,
        double? toolbarHeight ,
        int curStep = 0,
        bool statusBarOn= false}) {
  if( automaticallyImplyLeading == null ) {automaticallyImplyLeading=true;}
  if( bottom != null ){
//    logit( 'bottom on page $title');
  }
  bool wantOutline = false;

  double height = 80;
  if( gblSettings.wantTallPageImage ) {
    height = 140;
  }
  if( curStep == null ){
    curStep = 1;
  }


  Widget? flexibleSpace ;

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
    String pageImage = '' ;
    if( pageMap[imageName.toUpperCase()] != null ){
      pageImage = pageMap[imageName.toUpperCase()];
    }

    switch (pageImage) {
      case '[DEST]':
        pageImage = gblDestination;
        break;
    }
    if( pageImage == '') {
      pageImage = 'blank';
    }

    if( pageImage != 'blank' && gblSettings.homePageStyle != 'V3') {
      backgroundImage = NetworkImage(
          '${gblSettings.gblServerFiles}/pageImages/$pageImage.png');
    }
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
          child:  V3AppBar( pageEnum,
            leading: leading,
            bottom: bottom,
            //toolbarHeight: toolbarHeight,
            flexibleSpace: flexibleSpace,
            elevation: elevalion,
            automaticallyImplyLeading: automaticallyImplyLeading,
            centerTitle: gblCentreTitle,
            //backgroundColor: Colors.transparent,
            hasBackgroundImage: true,

            iconTheme: IconThemeData(
                color: Colors.white),
            title: getText(title),
            actionsIconTheme: IconThemeData( color: Colors.white),
            actions: actions,
          )
      );


    }

  }


  if( flexibleSpace != null ) {
    wantOutline = true;
  }

  if( (gblSettings.wantLeftLogo || gblSettings.imageBackgroundPages.contains(curPage) )&& (leading == null || leading == false)) {

    return V3AppBar(pageEnum,
      flexibleSpace: flexibleSpace,
      centerTitle: gblCentreTitle,
      title: getText(title),
      toolbarHeight: toolbarHeight,
      elevation: elevalion,
      leading: getAppBarLeft(curPage),
      leadngWidth: imageWidth,
      //backgroundColor: (backgroundColor == null) ? gblSystemColors.primaryHeaderColor : backgroundColor,
      iconTheme: IconThemeData(
          color: gblSystemColors.headerTextColor),
      actions: actions,
      bottom: bottom,
    );

  } else {
    PreferredSizeWidget ab = V3AppBar(pageEnum,
      leading: leading,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
      flexibleSpace: flexibleSpace,
      elevation: elevalion,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: gblCentreTitle,
      //backgroundColor: (backgroundColor == null) ? gblSystemColors.primaryHeaderColor : backgroundColor,

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

Widget getSummaryBody(BuildContext context, NewBooking newBooking,  Widget Function(NewBooking newBooking) body, Key key) {
  //logit('gsb:');
  if( gblError != '') {
    return displayMessage(context,'Booking Error', gblError );
  }
  if (gblSettings.wantProducts) {
    return StatusBar(key: key, newBooking: newBooking, body: body,);

  } else {
    return body(newBooking);
  }
}

class StatusBar extends StatefulWidget {
  final NewBooking newBooking;
  final Widget Function(NewBooking newBooking) body;

  StatusBar({Key key = const Key("statbar_key"), required this.newBooking, required this.body}) : super(key: key);

  StatusBarState createState() => StatusBarState();
}
class StatusBarState extends State<StatusBar> {

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    setAmountPayable(gblPnrModel as PnrModel);

    Color? iconClr = gblSystemColors.headerTextColor;
    if( gblPnrModel == null || gblPnrModel!.pNR == null ){
      return Container();
    }

    return
      ListView(
          children: [

      Container(
     child:
    Column(children: [
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Container(
            padding: EdgeInsets.only(top: 0),
            color: _isExpanded ? Colors.grey.shade200 : gblSystemColors.primaryHeaderColor,

            child:
    ListTileTheme(
    contentPadding: EdgeInsets.all(0),
        dense: true,
        horizontalTitleGap: 0.0,
        //minLeadingWidth: 0,
    child: ExpansionTile(
              trailing: Icon(
                _isExpanded ? Icons.keyboard_arrow_up: Icons.keyboard_arrow_down,
                color: _isExpanded ? Colors.black : iconClr,
              ),
             // backgroundColor: Colors.grey,
              initiallyExpanded: false,
              title: _getTitle(widget.newBooking, _isExpanded),

              children: getTabs(context, widget.newBooking, _isExpanded), // getBookingSummaryBar(context, widget.newBooking, _isExpanded),
              onExpansionChanged: (value) {
                _isExpanded = value;
                // whene setState methode is called the widget build function will be replayed with the new changes that we've done
                setState(() {});
              },
            ))
        ),
      ),
      widget.body(widget.newBooking),
    ])
    )]);
  }

  void refresh(){
    setState(() {

    });
  }
}

List<Widget> getTabs(BuildContext context, NewBooking newBooking, bool isExpanded) {
  List <Widget> tabViews = [];
  tabViews.add(
      ListView(
     // shrinkWrap: false,
      //mainAxisSize: MainAxisSize.max,
      children: getBookingSummaryBar(context, newBooking,isExpanded)));

  tabViews.add(SummaryView(newBooking: newBooking,));
  if( gblPnrModel != null ) {
    tabViews.add(FareRulesView(fQItin: gblPnrModel!.pNR.fareQuote.fQItin,
      itin: gblPnrModel!.pNR.itinerary.itin,));
  }
  List<Widget> list=[];
  list.add(
    DefaultTabController(
        length: 3,

        child: SizedBox(
            height: 600,
            child: Column(
                children: <Widget>[
                  TabBar(
                    labelColor: Colors.grey,
                    indicatorColor: gblSystemColors.tabUnderlineColor == null ? Colors.amberAccent : gblSystemColors.tabUnderlineColor,
                    // indicatorSize: ,
                    tabs: <Widget>[
                      Tab(text: translate("Journeys"),),
                      Tab(text: translate("Details"),),
                      Tab ( text: translate('Fare Rules')),
                    ],
            ),
                  Expanded(
                      child: TabBarView(
                        //controller: _controller,
                        children: tabViews,)
                  )
                ])
        )
    )
  );
  return list;
}

Widget _getTitle(NewBooking newBooking,bool expanded) {
  if( gblPnrModel!= null ) setAmountPayable(gblPnrModel as PnrModel);
  Color? txtCol = gblSystemColors.headerTextColor;
  if( expanded){
    txtCol = Colors.black;
  }
  TextStyle tStyle = TextStyle( color:  txtCol,fontSize: 20);
 return Padding(padding: EdgeInsets.only(left: 10, top: 0),
      child:  Row(children: [
        Text(cityCodetoAirport(newBooking.departure),
            textScaleFactor: 0.75,
            style:  tStyle),

   /*     FutureBuilder(
          future: cityCodeToName(
            newBooking.departure,
          ),
          initialData: newBooking.departure.toString(),
          builder: (BuildContext context, AsyncSnapshot<String> text) {
            return new Text(text.data as String,
                textScaleFactor: 0.75,
                style:  tStyle);
          },
        ),
*/
        newBooking.isReturn ?
        new RotatedBox(
            quarterTurns: 1,
            child: new Icon(
              Icons.import_export,
              size: 20,
              color: txtCol,
            ))
            :
        new Icon(
          Icons.arrow_forward_sharp,
          size: 20,
          color: txtCol,
        ),

  /*      FutureBuilder(
          future: cityCodeToName(
            newBooking.arrival,
          ),
          initialData: newBooking.arrival.toString(),
          builder: (BuildContext context, AsyncSnapshot<String> text) {
            return new Text(
              text.data as String,
              textScaleFactor: 0.75,
              style: tStyle,
            );
          },
        ),*/
        Text(cityCodetoAirport(newBooking.arrival),
            textScaleFactor: 0.75,
            style:  tStyle),

        Spacer(),
        Text( gblPayable, style: TextStyle(color: txtCol), textScaleFactor: 1.0,),

      ],));

}


List<Widget> getBookingSummaryBar(BuildContext context,  NewBooking newBooking, bool expanded) {

    //Color txtCol = Colors.white;
/*
    if(expanded) {
      txtCol = Colors.black;
    }
*/

    List <Widget> widgets = [];
    DateTime a1 = DateTime.parse(newBooking.outboundflts.first.time.adaygmt + ' ' + newBooking.outboundflts.first.time.atimgmt);
    DateTime d1 = DateTime.parse(newBooking.outboundflts.last.time.ddaygmt + ' ' + newBooking.outboundflts.last.time.dtimgmt);
    int diff = d1.difference(a1).inMinutes;
    String duration = getDuration(diff);
  if(newBooking.outboundflts.length == 1 ) {
    widgets.add(TimelineHeader(title: translate('Outbound Flight'), duration: duration));
  } else {
    widgets.add(TimelineHeader(title: translate('Outbound Flights'), duration: duration));
  }
  widgets.add(TimelineDelivery(newBooking:  newBooking, isReturn:  false,)); // Expanded(child:

  if( newBooking.isReturn){

    DateTime a1 = DateTime.parse(newBooking.returningflts.first.time.adaygmt + ' ' + newBooking.returningflts.first.time.atimgmt);
    DateTime d1 = DateTime.parse(newBooking.returningflts.last.time.ddaygmt + ' ' + newBooking.returningflts.last.time.dtimgmt);
    int diff = d1.difference(a1).inMinutes;
    String duration = getDuration(diff);
    widgets.add(TimelineHeader(title: translate('Return Flight'), duration: duration));
    widgets.add(TimelineDelivery(newBooking:  newBooking, isReturn: true,)); // Expanded(child:

  }

    return widgets;
}
getPaxCounts(NewBooking newBooking, List<Widget> listMain, Color txtCol, TextStyle tStyle  ) {
  List<Widget> list = [];
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
  listMain.add(Row(children: list,));

}


Widget getAppBarLeft(String curPage) {
  Widget leading = Text('');
  if(gblSettings.wantLeftLogo || gblSettings.titleImagePages.contains(curPage) ) {
    if( gblSettings.aircode == 'SI') {
      leading = Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Image.asset(
              'lib/assets/$gblAppTitle/images/appBarLeft.png',
              color: Color.fromRGBO(255, 255, 255, 0.1),
              colorBlendMode: BlendMode.modulate)
      );
    } else {
      leading = Image.asset('lib/assets/$gblAppTitle/images/appBarLeft.png',
              alignment: Alignment.topLeft,);
      imageWidth = 300;
    }
  }
  return leading;
}

Widget getText(String txt) {
  return Text(translate(txt), textScaler: TextScaler.linear(1.25),
    style: TextStyle(
      color: Colors.red , //gblSystemColors.headerTextColor,
    ),
  );


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
        color: gblSystemColors.headerTextColor,
      ),
    ),
  ],
);

}

