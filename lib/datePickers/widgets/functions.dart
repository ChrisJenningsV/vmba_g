


import 'package:flutter/cupertino.dart';

import '../../data/globals.dart';
import '../../utilities/helper.dart';
import '../../utilities/widgets/dataLoader.dart';

bool dayIsSelectable(DateTime day) {
  // is this a valid flight date
  bool retValue = true;
  if( gblFlightPrices != null ) {
    gblFlightPrices!.flightPrices.forEach((flightPrice) {
      if (flightPrice.FlightDate != '' &&
          flightPrice.FlightDate == day.toString().substring(0, 10)) {
        if (flightPrice.Selectable == false) {
          retValue = false;
        }
      }
    });
  }
  return retValue;
}
void monthChange(BuildContext context, DateTime newMonth, void Function() onComplete){
  logit('MonthChange event',verboseMsg: false);
  // load this months data
  LoadCalendarData(context, newMonth, onComplete);
}
