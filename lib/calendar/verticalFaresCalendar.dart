
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/calendar/calendarFunctions.dart';
import 'package:vmba/calendar/widgets/cannedFact.dart';
import 'package:vmba/components/vidButtons.dart';

import '../Helpers/settingsHelper.dart';
import '../chooseFlight/chooseFlightPage.dart';
import '../components/trText.dart';
import '../data/globals.dart';
import '../data/models/availability.dart';
import '../data/models/models.dart';
import '../utilities/helper.dart';
import '../utilities/messagePages.dart';
import '../utilities/timeHelper.dart';
import '../v3pages/v3Theme.dart';
import 'flightPageUtils.dart';


class VerticalFaresCalendar  extends StatefulWidget {
  AvailabilityModel objAv;
  NewBooking newBooking;
  void Function() loadData;

  VerticalFaresCalendar({required this.newBooking, required this.objAv, required this.loadData}) ;

  _VerticalFaresCalendarState createState() => new _VerticalFaresCalendarState();

}

class _VerticalFaresCalendarState extends State<VerticalFaresCalendar> {
ScrollController _scrollController = ScrollController();
  int selectedFlt = 0;
  int expandedFlt = 0;
  int selectedFare = -1;
  get flightSelected => null;
  List<ExpansionTileController> _controllerList = [];

@override
void initState() {
  super.initState();
  double animateTo = 250;
  DateTime _departureDate = DateTime.parse(
      DateFormat('y-MM-dd').format(widget.newBooking.departureDate as DateTime));
  DateTime _currentDate =
  DateTime.parse(DateFormat('y-MM-dd').format(getGmtTime()));

  int calenderWidgetSelectedItem = 0;
  // count flights
  if(widget.objAv.availability.cal != null && widget.objAv.availability.cal?.day != null  ) {
    for (var f in widget.objAv.availability.cal!.day) {
      if (DateTime.parse(f.daylcl).isAfter(_currentDate) ||
          isSearchDate(DateTime.parse(f.daylcl), _departureDate)) {
        calenderWidgetSelectedItem += 1;
        if (isSearchDate(DateTime.parse(f.daylcl), _departureDate)) {
          break;
        }
      }
    }
  }

  if (calenderWidgetSelectedItem == 0 || calenderWidgetSelectedItem == 1) {
    animateTo = 0;
  } else if (calenderWidgetSelectedItem == 2) {
    animateTo = 150;
  }
  WidgetsBinding.instance.addPostFrameCallback((_) =>
      _scrollController.animateTo(animateTo,
          duration: new Duration(microseconds: 1), curve: Curves.ease));
  // what is expanded and selected
  if (widget.objAv != null && widget.objAv.availability.itin != null && widget.objAv.availability.itin!.length == 1) {
    selectedFlt = 1;
    expandedFlt = 1;
  } else {
    selectedFlt = 1;
  }

  widget.objAv.availability.itin!.forEach((element) {
    _controllerList.add(new ExpansionTileController());
  });



}
//Widget verticalFaresCalendar()

  @override
  Widget build(BuildContext context) {
  EdgeInsets mar = EdgeInsets.fromLTRB(10, 10, 0, 10);

    return new Column(
      children: <Widget>[
        new Container(
          //margin: EdgeInsets.symmetric(vertical: 1.0),
          margin: mar,
          //height: 70.0,
          constraints: new BoxConstraints(
            minHeight: 65.0,
            maxHeight: 80.0,
          ),
          child: getCalenderDays(widget.objAv, widget.newBooking),
        ),
        new Expanded(
          child: flightList(widget.objAv),
        ),
      ],
    );
}
Widget getCalenderDays(AvailabilityModel objAv, NewBooking newBooking) {
  if (objAv != null && objAv.availability.cal != null && objAv.availability.cal!.day != null) {
    return new ListView(
        shrinkWrap: true,
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        children: objAv.availability.cal!.day
            .map(
              (item) =>
              getCalDay(item, 'out', newBooking.departureDate as DateTime, DateTime.parse(DateFormat('y-MM-dd').format(getGmtTime())),
                  onPressed:() => {
                    hasDataConnection().then((result) {
                      if (result == true) {
                        _changeSearchDate(DateTime.parse(item.daylcl));
                      } else {
//                    noInternetSnackBar(context);
                      }
                    })
                  }),

        )
            .toList());
  } else {
    return new TrText('No Calender results');
  }
  }
  _changeSearchDate(DateTime newDate) {
    print(this.widget.newBooking.departureDate.toString());
    setState(() {
      this.widget.newBooking.departureDate = newDate;
      widget.loadData();
    });
  }

  Widget flightList(AvailabilityModel objAv) {
    if (objAv != null && objAv.availability.itin != null && objAv.availability.itin!.length > 0) {
      int fltNo = 1;
      List<Widget> list = [];
      objAv.availability.itin!.forEach((item) {
        //(objAv.availability.itin!.map((item) {
          list.add(flight(item, fltNo));
          fltNo ++;
      });

      return new
      ListView(
          scrollDirection: Axis.vertical,
          children: list);
    } else {
      return noFlightsFound();
    }
  }

  Widget flight(AvItin item, int fltNo){
    int seatCount = widget.newBooking.passengers.adults +
        widget.newBooking.passengers.youths +
        widget.newBooking.passengers.seniors +
        widget.newBooking.passengers.students +
        widget.newBooking.passengers.children;


    return Card(
      color: selectedFlt == fltNo ? gblSystemColors.selectedFlt : gblSystemColors.unselectedFlt,
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all( Radius.circular( 5))
      ),
      child: ClipPath(
        child: Container(
          decoration: BoxDecoration(
              border: Border(top: BorderSide(
                  color: Colors.grey.shade200, width: 0))),
          //           height: 100,
          width: double.infinity,
          child:

          ExpansionTile(
            iconColor: gblSystemColors.fltText,
            collapsedIconColor: gblSystemColors.fltText,
            /*  trailing: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.green,
              ),*/
            controller: _controllerList[fltNo-1],
            onExpansionChanged: (selected){
              if( selected == true ){
                logit('Select $fltNo');
                selectedFlt = fltNo;
                expandedFlt = fltNo;
                selectedFare = -1;
                // collapse other tiles
                int index = 1;
                _controllerList.forEach((element) {
                  if( index == fltNo){

                  } else {
                    element.collapse();
                  }
                  index ++;
                });
                setState(() {

                });
              } else {
                setState(() {

                });

              }
            },
            //backgroundColor: Colors.grey.shade200,
            //tilePadding: EdgeInsets.all(0),
              childrenPadding: EdgeInsets.all(0),
//        backgroundColor:  Colors.blue,
              initiallyExpanded: expandedFlt == fltNo ,
              title: flightTitle(item, fltNo),
              children: [ Container(
                  color: Colors.grey.shade200,
                  child: getFareList(item, fltNo))]
          ),
        ),
        clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5))),
      ),

    );;
  }
  Widget getFareList(AvItin item, int fltNo){
    List<Widget> list = [];

    List<String>? prices = item.flt[0].fltav.pri;
    int curFare = 0;
    prices?.forEach((flt) {
      Color bgClr = Colors.white;
      if( gblSystemColors.fareColors != null &&  gblSystemColors.fareColors!.length > curFare){
        bgClr = gblSystemColors.fareColors![curFare];
      }
      if( fltNo == selectedFlt && curFare == selectedFare) bgClr = gblSystemColors.selectedFare!;
      list.add(Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(5.0))),
          color: bgClr,
          child: getFare(item,fltNo, curFare)));
      curFare +=1;
    });

    return Column(
      children: list
    );
  }
  Widget getFare(AvItin item, int curFltNo, int curFare){
    String? name = widget.objAv.availability.classbands?.band![curFare].cbdisplayname;
    int noAv = getAvalability(item.flt, curFare);
    double upgradePrice = 0;
 //   logit('fltNo $curFltNo index $index');

    int fltNo = 1;
    int len = item.flt[fltNo-1].fltav.pri!.length;
    String cur ='';
    if(noAv > 0 && curFare > 0 && curFare <= item.flt[fltNo-1].fltav.pri!.length){
      //logit('a');
      cur = item.flt[fltNo-1].fltav.cur![0];
      if( item.flt[fltNo-1].fltav.pri![curFare] != '' && item.flt[fltNo-1].fltav.pri![curFare-1 ] != '') {
        //logit('b');
        if (double.parse(item.flt[fltNo - 1].fltav.pri![curFare]) >
            double.parse(item.flt[fltNo - 1].fltav.pri![curFare - 1])) {
          //logit('c');
          upgradePrice = double.parse(item.flt[fltNo - 1].fltav.pri![curFare]) -
              double.parse(item.flt[fltNo - 1].fltav.pri![curFare - 1]);
        }
      }
     }
//    logit('index $index upgrade $upgradePrice');

    if( name == 'Fly Flex Plus') name = 'Fly Flex +';

    if( noAv == 0) return Container();

    return InkWell(
        onTap: () {
//          logit('clicketty');
          setState(() {
            selectedFare = curFare;
          });
          _GoToNextPage();
        },
        child: Padding(
      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name as String, textScaler: TextScaler.linear(1.25), style: TextStyle(fontWeight: FontWeight.bold),),
            Padding(padding: EdgeInsets.all(5)),
            getPrice(item, curFare),
          ],
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              vidTextButton(context, 'View details', _onPressedViewDetails, p1: curFare, p3: name),
              Padding(padding: EdgeInsets.all(5)),
              curFare == 0 || upgradePrice == 0 ? Container() : Container(color: Colors.black,
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  fltText('Upgrade from'),
                  fltText(calenderPrice( cur,upgradePrice.round().toString(), '')),
                ],
              ),),
            ]
        ),
        V3Divider(),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              fareText('Available'),
              Padding(padding: EdgeInsets.all(5)),
              fareText('Select'),
            ]
        ),
      ],
    )
    )
    );
  }

  void _onPressedViewDetails({int? p1, int? p2, String? p3}) async {
    logit('view details');
    gblActionBtnDisabled = false;
    Band classband = widget.objAv.availability.classbands!.band![p1!];
    _viewDetailDialog(context, p3, classband );
  }

  int getAvalability(List<Flt> item, int index){
    int noAv = int.parse(item[0].fltav.fav![index]);
    item.forEach((element) {
      if( element.fltav.fav![index] == '0'){
        noAv = 0;
      }
      if( element.fltav.av![index] == '0' || element.fltav.av![index] == ''){
        noAv = 0;
      }
    });
    return noAv;
  }



  Widget getPrice(AvItin item, int curfare){
    int noAv = getAvalability(item.flt, curfare);

    if(noAv > 0) {
/*
      double val = 0.0;
      int miles = 0;
      String cur = '';
*/
      Prices prices = item.getPrices(curfare);


/*
      item.flt.forEach((element) {
        String newStr = element.fltav.pri![index];
        double? newVal = double.tryParse(newStr);
        if( newVal != null )    val +=  newVal as double;
        newVal = double.tryParse(element.fltav.tax![index]);
        if( newVal != null )    val +=  newVal as double;
        String newMiles = element.fltav.miles![index];
        int? newMileVal = int.tryParse(newMiles);
        if( newMileVal != null )    miles +=  newMileVal as int;
      });
*/

 //     logit( 'Price${calenderPrice(item[0].fltav.cur![index], val.toStringAsFixed(gblSettings.currencyDecimalPlaces), item[0].fltav.miles![index])}');
      return Text(calenderPrice(prices.currency, prices.price.toStringAsFixed(gblSettings.currencyDecimalPlaces), prices.miles.toString()), //item[0].fltav.miles![index]),
        style: new TextStyle( fontWeight: FontWeight.bold          ,
        ), textScaler: TextScaler.linear(1.25),);
    } else {
      return getNoSeatsRow();
    }
  }


  Widget flightTitle(AvItin? item, int fltNo) {
    List <Widget> innerList = [];

    innerList.add(vertFlightRow(context, item));
   /* if (gblSettings.wantCanFacs &&
        item!.flt.first.fltdet.canfac?.fac.isNotEmpty != null) {
      innerList.add(V3Divider());
      innerList.add(CannedFactWidget(flt: item.flt));
    }
    innerList.add(infoRow(context, item!));*/
    return Container(
      // margin: EdgeInsets.only(top: 10, bottom: 10.0, left: 5, right: 5),
        color: selectedFlt == fltNo ? gblSystemColors.selectedFlt : gblSystemColors.unselectedFlt,
        padding: EdgeInsets.all(10),
        child: Column(
          children: innerList,
        )
    );
  }

  Widget vertFlightRow(BuildContext context, AvItin? item){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            vertGetTime(item?.flt.first.time.dtimlcl as String),
            vertGetDate(item?.flt[0].time.ddaylcl as String),
            vertGetAirport(item?.flt.first.dep as String),
            getTerminal(getTerminalString(item?.flt.first  as Flt, true), true),
          ],
        ),
        Column(children: [
       /*   new RotatedBox(
              quarterTurns: 1,
              child: new Icon(
                Icons.airplanemode_active,
                size: 60.0,
              )),*/
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            vertGetTime(item?.flt.last.time.atimlcl as String),
            vertGetDate(item?.flt.last.time.adaylcl  as String),
            vertGetAirport(item?.flt.last.arr as String),
            getTerminal(getTerminalString(item?.flt.first as Flt, false), false),
          ],
        ),
        V3VertDivider(),
        Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          fltText('from'),
          ]),

      ],
    );
  }

  void _GoToNextPage(){

  }
 }
Widget vertGetDate(String dt){
  //return fltText(getIntlDate('EEE dd MMM', DateTime.parse(dt)));
  return fltText(getIntlDate('dd MMM', DateTime.parse(dt)));
}
Widget vertGetTime(String tm) {
  String formattedTm = tm.substring(0, 5);
  if( gblSettings.avTimeFormat.contains(':'))
  {

  } else {
    formattedTm = formattedTm.replaceAll(':', '');
  }
  if( wantRtl()) {

    return fltText(getIntlDate('HHmm', DateTime.parse('2022-11-12 ' + tm)));

  } else {
    return fltText(formattedTm);
  }
    }

  Widget fltText(String text){
    return VBodyText(text, size: TextSize.large, color: gblSystemColors.fltText,);
  }

Widget fareText(String text){
  return VBodyText(text, size: TextSize.large, color: Colors.black,);
}

  Widget vertGetAirport(String code,) {

      return fltText(cityCodetoAirport(code));
  }

void _viewDetailDialog(BuildContext context, String? fareName, Band classband) {
  var txt = '';
  if( fareName == null) fareName = 'fare name';
  fareName = fareName == 'Fly Flex Plus' ? 'Fly Flex +' : fareName;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          shape: alertShape(),
          titlePadding: const EdgeInsets.all(0),
          title: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: gblSystemColors.primaryHeaderColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0),)),
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text(fareName!,style: TextStyle(color: gblSystemColors.headerTextColor),)),
          content: classbandText(classband!),
          //Text(txt == '' ? 'A newer version of the app is available to download' : txt),
          actions: <Widget>[
            new TextButton(
              child: new Text(
                'OK',
                style: TextStyle(color: Colors.black),
              ),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                  foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

          ]);
    },
  );
}