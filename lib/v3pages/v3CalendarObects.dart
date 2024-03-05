


import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/v3pages/v3Card.dart';

import '../calendar/calendarFunctions.dart';
import '../data/models/availability.dart';
import '../utilities/helper.dart';
import '../utilities/timeHelper.dart';

Widget v3CalendarDay(Day item, DateTime selectedDate,Widget ln2, Widget? ln3,void Function()? onPressed){
  Color backClr =  Colors.grey.shade200;
  Color txtClr = Colors.black54;

  if( isSearchDate(DateTime.parse(item.daylcl),selectedDate)) {
    backClr = gblSystemColors.primaryHeaderColor;
    txtClr = gblSystemColors.headerTextColor as Color;
  }
  if( DateTime.parse(item.daylcl).add(Duration(days: 1)).isBefore(getGmtTime())){
    logit('hide ${item.daylcl.toString()} ${getGmtTime()}');
    return Container();
  }

  return Container(
      height: 60,
      width: 120,
      child: v3Card(
      Container(
          width: 100,
          height: 48,
          child:
          Column(
              children: [
                ln2,
                ln3 != null ? ln3 : Container()
              ])),
          onPressed,
      title: getCalDate(item.daylcl, txtClr),
        backClr: backClr
  ));

/*
  return Card(
    child: InkWell(
      onTap:() {
        onPressed!();
      },
      child:  Column(
          children: [
            // add title
            getCalDate(item.daylcl, txtClr),
            // add content
            Card(
                color: Colors.white,
                elevation: 1,
                child:
                Container(
                  width: DateTime.parse(item.daylcl).isBefore(getGmtTime()) ? 0 :100,
                  height: 48,
                child:
                Column(
                  children: [
                    ln2,
                    ln3 != null ? ln3 : Container()
                  ])),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))

            )
            ,
          ]
      ),
    ),
        color: backClr,
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)))
  );
*/
}