


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../components/trText.dart';
import '../../data/globals.dart';
import '../../utilities/helper.dart';
import '../../v3pages/v3Theme.dart';



Widget? dayBuilder(BuildContext context,  DateTime date,
  TextStyle? textStyle,
  BoxDecoration? decoration ,
  bool? isSelected ,
  bool? isDisabled ,
  bool? isToday,
  {bool isInRange = false  }) {


  decoration = BoxDecoration(color: Colors.grey.shade500,
    borderRadius: BorderRadius.circular(1),);
  if( gblV3Theme != null ){
    decoration = BoxDecoration(color: gblV3Theme!.calendar.selectableColor,
      borderRadius: BorderRadius.circular(1),);
  }
  if( isInRange) {
    decoration = BoxDecoration(color: gblSystemColors.calInRangeColor,
      borderRadius: BorderRadius.circular(1),);

  }

  Widget lineTwo = Text('');
  Color textColor = Colors.black;
  if(isSelected != null && isSelected == true){
    textColor = Colors.white;
    if( gblV3Theme != null ){
      textColor = gblV3Theme!.calendar.selectedTextColor;
    }
  }

//  logit('day: ${date.day} isSelected: $isSelected isDisabled: $isDisabled' );

  if(isToday != null && isToday == true ){
    textStyle = TextStyle( color: Colors.red, fontWeight: FontWeight.bold);
    decoration = BoxDecoration( );
    lineTwo = RotatedBox(
        quarterTurns: 1,
        child: new Icon(
          Icons.airplanemode_active,
          color: Colors.red,
          size: 15.0,
        ));
  } else if( isDisabled != null && isDisabled== false){
    /*  lineTwo = RotatedBox(
          quarterTurns: 1,
          child: new Icon(
            Icons.airplanemode_active,
            color: Colors.black,
            size: 15.0,
          ));*/

  }
  if( gblFlightPrices != null ) {
    // check for this date
    gblFlightPrices!.flightPrices.forEach((flightPrice) {
      //       logit( ' match ${flightPrice.FlightDate} to ${date.toString().substring(0,10)}');
      if( flightPrice.FlightDate != '' && flightPrice.FlightDate== date.toString().substring(0,10)){
        if( flightPrice.Selectable == false){
          // logit( ' match no sel  ${flightPrice.FlightDate}');
          //    if ( textStyle != null ) {
          textStyle = TextStyle( color: Colors.red, fontWeight: FontWeight.bold);
          //  }
        }
        //logit('${flightPrice.FlightDate} ${flightPrice.CssClass}');
        if( flightPrice.CssClass.contains('flight-has-price' )) {
          if(flightPrice.Price == '') {
            lineTwo = RotatedBox(
                quarterTurns: 1,
                child: new Icon(
                  Icons.airplanemode_active,
                  color: isToday == true ? Colors.red : Colors.black,
                  size: 15.0,
                ));
          } else {
            lineTwo = Text(formatPrice(flightPrice.Currency, flightPrice.Price,places: 0),
              textScaler: TextScaler.linear(0.8),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),);
          }
          textStyle = TextStyle( color: Colors.black, fontWeight: FontWeight.bold);
        } else if( flightPrice.CssClass.contains('not-available')){
          isDisabled = true;
          textStyle = TextStyle( color: textColor, fontWeight: FontWeight.bold);
          lineTwo =  Text('-', style: TextStyle(color: textColor),);
        } else if( flightPrice.CssClass.contains('no-price')){
          isDisabled = true;
          textStyle = TextStyle( color: textColor, fontWeight: FontWeight.bold);
          lineTwo =  Text('-', style: TextStyle(color: textColor),);
        }

        if(isSelected != null && isSelected == true){
          textStyle = TextStyle( color: Colors.white, fontWeight: FontWeight.bold);
          decoration = BoxDecoration(color: Colors.red,
              borderRadius: BorderRadius.circular(1));
        }

      }
    });
  }
  return Container(
    margin:  EdgeInsets.fromLTRB(1, 0, 1, 0),
    //padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
    decoration: decoration,
    child: Center(
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Text(
            MaterialLocalizations.of(context).formatDecimal(date.day),
            style: textStyle,
            textScaleFactor: 1,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Container(
              child: lineTwo,
              /*               height: 4,
                width: 4,*/
/*
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: isSelected == true
                      ? Colors.white
                      : Colors.grey[500],
                ),
*/
            ),
          ),
        ],
      ),
    ),


  );
}/*
final startDate = DateUtils.dateOnly(widget.selectedDates[0]);
final endDate = DateUtils.dateOnly(widget.selectedDates[1]);

isDateInBetweenRangePickerSelectedDates =
!(dayToBuild.isBefore(startDate) ||
dayToBuild.isAfter(endDate)) &&
!DateUtils.isSameDay(startDate, endDate);}
*/

Widget wrapCal( Widget child, void Function() callback, bool isReturn, DateTime? depDate,DateTime? retDate){
  return Align(alignment: Alignment.topCenter,
      child:
      Padding(
      padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
  child:
  Container(
  child:
  Column(
  children: [
    getLabel(isReturn, depDate, retDate),
    Divider(color: Colors.grey, height: 2,),
    Padding(padding: EdgeInsets.all(10),),
    child,
  // if test build, allow test of new theme
  gblIsLive ? Container() :
  Padding(
  padding: const EdgeInsets.all(8.0),
  child: TextButton(
  onLongPress: () async {
  await loadNetTheme('theme.json');
    callback();
  },
  child: Container(),
  onPressed: () {},
  ),
  ),
  ]
  )
  )
  )
  );
}
Widget getLabel(bool isReturn, DateTime? depDate,DateTime? retDate, ){
  List<Widget> list = [];
  List<Widget> rowList = [];

  list.add(Text(translate('Departing: '), style: TextStyle(fontWeight: FontWeight.bold),));
  if( depDate != null ){
    list.add(Text(DateFormat('dd MMM kk').format(depDate)));
  }
  rowList.add(Row(
    children: list   ,
  ));

  if( isReturn  ) {
    List<Widget> list2 = [];
    list2.add(Text(translate('Returning: '), style: TextStyle(fontWeight: FontWeight.bold),));
    if( retDate != null ){
      list2.add(Text(DateFormat('dd MMM kk').format(retDate)));
    }
    rowList.add(Row(
      children: list2   ,
    ));

  }

  return Padding(
      padding: EdgeInsets.only(top: 10.0, left: 10, right: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: rowList   ,
    )
  );
}

