
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/calendar/calendarFunctions.dart';
import 'package:vmba/calendar/widgets/cannedFact.dart';
import 'package:vmba/components/vidButtons.dart';

import '../components/trText.dart';
import '../data/globals.dart';
import '../data/models/availability.dart';
import '../data/models/models.dart';
import '../utilities/helper.dart';
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

  get flightSelected => null;

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
      return new
      ListView(
          scrollDirection: Axis.vertical,
          children: (objAv.availability.itin!
              .map(
                (item) =>  flight( item),
          )
              .toList()));
    } else {
      return noFlightsFound();
    }
  }

  Widget flight(AvItin item){
    int seatCount = widget.newBooking.passengers.adults +
        widget.newBooking.passengers.youths +
        widget.newBooking.passengers.seniors +
        widget.newBooking.passengers.students +
        widget.newBooking.passengers.children;

    return Card(
      color:  Colors.white ,
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
            //backgroundColor: Colors.grey.shade200,
            //tilePadding: EdgeInsets.all(0),
              childrenPadding: EdgeInsets.all(0),
//        backgroundColor:  Colors.blue,
              initiallyExpanded: true ,
              title: flightTitle(item),
              children: [ Container(
                  color: Colors.grey.shade200,
                  child: getFareList(item))]
          ),
        ),
        clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5))),
      ),

    );;
  }
  Widget getFareList(AvItin item){
    List<Widget> list = [];

    List<String>? prices = item.flt[0].fltav.pri;
    int index = 0;
    prices?.forEach((flt) {
      list.add(Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(5.0))),
          color: Colors.white,
          child: getFare(item, index)));
      index +=1;
    });

    return Column(
      children: list
    );
  }
  Widget getFare(AvItin item, int index){
    String? name = widget.objAv.availability.classbands?.band![index].cbdisplayname;
    int noAv = getAvalability(item.flt, index);

    if( name == 'Fly Flex Plus') name = 'Fly Flex +';

    if( noAv == 0) return Container();

    return Padding(
      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name as String, textScaler: TextScaler.linear(1.25), style: TextStyle(fontWeight: FontWeight.bold),),
            Padding(padding: EdgeInsets.all(5)),
            getPrice(item.flt, index),
          ],
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              vidActionButton(context, 'View details', (p0) { logit('clicked view details'); }),
              Padding(padding: EdgeInsets.all(5)),
            ]
        ),
        V3Divider(),

      ],
    )
    );
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

  Widget getPrice(List<Flt> item, int index){
    int noAv = getAvalability(item, index);

    if(noAv > 0) {
      double val = 0.0;

      item.forEach((element) {
        String newStr = element.fltav.pri![index];
        double? newVal = double.tryParse(newStr)  ;
        if( newVal != null )    val +=  newVal as double;
        newVal = double.tryParse(element.fltav.tax![index]);
        if( newVal != null )    val +=  newVal as double;
      });

 //     logit( 'Price${calenderPrice(item[0].fltav.cur![index], val.toStringAsFixed(gblSettings.currencyDecimalPlaces), item[0].fltav.miles![index])}');
      return Text(calenderPrice(item[0].fltav.cur![index], val.toStringAsFixed(gblSettings.currencyDecimalPlaces), item[0].fltav.miles![index]),
        style: new TextStyle( fontWeight: FontWeight.bold          ,
        ), textScaler: TextScaler.linear(1.25),);
    } else {
      return getNoSeatsRow();
    }
  }


  Widget flightTitle(AvItin? item) {
    List <Widget> innerList = [];

    innerList.add(flightRow(context, item));
    if (gblSettings.wantCanFacs &&
        item!.flt.first.fltdet.canfac?.fac.isNotEmpty != null) {
      innerList.add(V3Divider());
      innerList.add(CannedFactWidget(flt: item.flt));
    }
    innerList.add(infoRow(context, item!));
    return Container(
      // margin: EdgeInsets.only(top: 10, bottom: 10.0, left: 5, right: 5),
        //color: Colors.grey,
        padding: EdgeInsets.all(10),
        child: Column(
          children: innerList,
        )
    );
  }

 }