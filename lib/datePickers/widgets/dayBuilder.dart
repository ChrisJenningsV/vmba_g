import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../components/trText.dart';
import '../../data/globals.dart';
import '../../functions/text.dart';
import '../../utilities/helper.dart';



Widget? dayBuilder(BuildContext context,  DateTime date,
  TextStyle? textStyle,
  BoxDecoration? decoration ,
  bool? isSelected ,
  bool? isDisabled ,
  bool? isToday,
  {bool isInRange = false  }) {


/*
  decoration = BoxDecoration(color: Colors.grey.shade500,
    borderRadius: BorderRadius.circular(1),);
*/

  bool isPast = date.isBefore(DateTime.now());
  Widget lineTwo = Text('');
  Color? textColor = gblSystemColors.calTextColor;
  Color? decorationColor = Colors.grey.shade300.withOpacity(0.5);
  FontWeight? fontWeight;
  BoxDecoration? decoration;
  double line2TopPad = 18;

/*
  if( gblV3Theme != null ){
    decorationColor = gblV3Theme!.calendar.selectableColor;
  }
*/
  if( isSelected == null ) isSelected = false;
  if( isInRange || isSelected)  {
    if( gblSearchParams.isReturn && gblDepartDate != null && gblDepartDate!.isBefore( date)  && date.isBefore(gblReturnDate!)) {
      decorationColor = gblSystemColors.calInRangeColor;
    } else {
      if( !gblSearchParams.isReturn ) {
        decorationColor = gblSystemColors.calInRangeColor;
      } else {
        isSelected = false;
      }
    }
//    if ( date == gblDe)
  }


  if(isSelected != null && isSelected == true){
    textColor = Colors.white;
    if( gblV3Theme != null ){
      textColor = gblV3Theme!.calendar.selectedTextColor;
    }
  }

  if( gblDepartDate!= null && date.year == gblDepartDate!.year && date.month == gblDepartDate!.month && date.day == gblDepartDate!.day){
    decorationColor = gblSystemColors.calDepartColor;
  } else   if(gblSearchParams.isReturn && gblReturnDate != null &&  date.year == gblReturnDate!.year && date.month == gblReturnDate!.month && date.day == gblReturnDate!.day){
    decorationColor = gblSystemColors.calReturnColor;
  }


//  logit('day: ${date.day} isSelected: $isSelected isDisabled: $isDisabled' );

  if(isToday != null && isToday == true ){
    textColor = gblSystemColors.calTodayTextColor;
    decorationColor = gblSystemColors.calTodayColor;
//
//    decoration = BoxDecoration( );
    lineTwo = RotatedBox(
        quarterTurns: 1,
        child: new Icon(
          Icons.airplanemode_active,
          color: Colors.red,
          size: 15.0,
        ));
  } else if( isDisabled != null && isDisabled== true) {
    decorationColor =  gblSystemColors.calDisabledColor;
    textColor = Colors.black38;
   /* decoration = BoxDecoration(color: gblSystemColors.calDisabledColor,
      borderRadius: BorderRadius.circular(1),);*/
  } else if( isDisabled != null && isDisabled== false) {
    //textStyle = TextStyle( color: textColor);
  }

  textStyle = TextStyle( color: textColor, fontWeight: fontWeight);
  decoration = BoxDecoration(color: decorationColor,
    borderRadius: BorderRadius.circular(1),);

  if( gblFlightPrices != null ) {
    // check for this date
    gblFlightPrices!.flightPrices.forEach((flightPrice) {
      if( flightPrice.FlightDate != '' && flightPrice.FlightDate== date.toString().substring(0,10)){
        if( flightPrice.Selectable == false){
//          textStyle = TextStyle( color: Colors.red, fontWeight: FontWeight.bold);
        }
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
 //         textStyle = TextStyle( color: Colors.black, fontWeight: FontWeight.bold);
        } else if( flightPrice.CssClass.contains('not-available')){
          isDisabled = true;
     //     textStyle = TextStyle( color: textColor, fontWeight: FontWeight.bold);

            lineTwo = Text('-', style: TextStyle(color: textColor),);
        } else if( flightPrice.CssClass.contains('no-price')){

   //       textStyle = TextStyle( color: textColor, fontWeight: FontWeight.bold);
          if( gblSettings.wantIconsOnPriceCalendar ) {
            lineTwo =
              RotatedBox(
                  quarterTurns: 1,
                  child: new Icon(
                    Icons.airplanemode_active,
                    size: 15.0,
                    color: Colors.black,
                  ));
          } else {
            lineTwo = Text('-', style: TextStyle(color: textColor),);
          }
        }
        if( flightPrice.Selectable == false){
          isDisabled = true;
          line2TopPad = 10;
          decorationColor =  gblSystemColors.calDisabledColor;
          textColor = Colors.black38;
          if( gblSettings.wantIconsOnPriceCalendar && !isPast ) {
/*
            lineTwo = Stack( children: [
              RotatedBox(
                  quarterTurns: 1,
                  child: new Icon(
                    Icons.airplanemode_active,
                    size: 30.0,
                    color: Colors.grey,
                  )),
              Positioned(
                  left: 5,
                  top: 5,
                  child: Icon(Icons.close, size: 20.0, color: Colors.black,))
            ],);
*/
          }        }
      }
    });
  }
  TextScaler textScaler =  TextScaler.linear(0.8);
  if( gblSettings.wantPriceCalendar == false){
    textScaler =  TextScaler.linear(1.4);
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
            textScaler: textScaler,
          ),
          gblSettings.wantPriceCalendar ? Padding(
            padding: EdgeInsets.only(top: line2TopPad),
            child: Container(
              child: lineTwo,
            ),
          ) : Container(),
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
   ]
  )
  )
  )
  );
}
Widget getLabel(bool isReturn, DateTime? depDate,DateTime? retDate, ){
  List<Widget> list = [];
  List<Widget> rowList = [];
  bool wantCal2 = true;

  if( wantCal2) {
    List<Widget> list1 = [];
    list1.add(Container(
      decoration: BoxDecoration(
          color: gblSystemColors.calDepartColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white)
      ),
      child: RotationTransition(
          turns: new AlwaysStoppedAnimation(45 / 360),
          child: Padding(padding: EdgeInsets.all(4),
              child: Icon(
            Icons.airplanemode_active,
            size: 25.0,
            color: Colors.white,
          ))),
    ) );
    list1.add(Padding(padding: EdgeInsets.all(5)));
    List<Widget> colList =[];
    colList.add(v2Label(translate('Departing: ')));
    if (depDate != null) {
      colList.add(Text(DateFormat('dd MMM yy').format(depDate)));
    }
    list1.add(Column( children: colList,));
    rowList.add(Row(
      children: list1,
    ));
  } else {
    list.add(Text(translate('Departing: '),
      style: TextStyle(fontWeight: FontWeight.bold),));
    if (depDate != null) {
      list.add(Text(DateFormat('dd MMM yy').format(depDate)));
    }
    rowList.add(Row(
      children: list,
    ));
  }
  if( isReturn  ) {
    List<Widget> list2 = [];
    if( wantCal2) {
      list2.add(Container(
        decoration: BoxDecoration(
            color: gblSystemColors.calReturnColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white)
        ),
        child: RotationTransition(
            turns: new AlwaysStoppedAnimation(135 / 360),
            child: Padding(padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.airplanemode_active,
                  size: 25.0,
                  color: Colors.white,
                ))),
      ) );
      list2.add(Padding(padding: EdgeInsets.all(5)));
      List<Widget> colList =[];
      colList.add(v2Label(translate('Returning: ')));
      if (depDate != null) {
        colList.add(Text(DateFormat('dd MMM yy').format(retDate!)));
      }
      list2.add(Column( children: colList,));
      rowList.add(Row(
        children: list2,
      ));
    } else {
      list2.add(Text(translate('Returning: '),
        style: TextStyle(fontWeight: FontWeight.bold),));
      if (retDate != null) {
        list2.add(Text(DateFormat('dd MMM yy').format(retDate)));
      }
      rowList.add(Row(
        children: list2,
      ));
    }
  }

  return Container(
    color: Colors.white,
    child:
      Padding(
      padding: EdgeInsets.only(top: 10.0, left: 10, right: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: rowList   ,
    )
  ));
}

