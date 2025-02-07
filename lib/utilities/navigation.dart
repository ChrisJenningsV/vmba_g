import 'package:flutter/material.dart';

import '../data/globals.dart';
import '../dialogs/genericFormPage.dart';
import '../menu/myFqtvPage.dart';
import '../mmb/viewBookingPage.dart';
import 'helper.dart';


// go to new user home page
void navToHomepage(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
}

void navToNewInstallPage(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil(
      '/NewInstallPage', (Route<dynamic> route) => false);
}


void navToFlightSearchPage(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil('/FlightSearchPage', (Route<dynamic> route) => false);
}

void navToMyBookingsPage(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil(
  '/MyBookingsPage', (Route<dynamic> route) => false);

}

void navToMyBookingPage(BuildContext context, String rloc) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) =>
            ViewBookingPage(
              rloc: rloc,
            ))
  );
}
void navToSmartDialogHostPage(BuildContext context, FormParams params){
  gblActionBtnDisabled = false;
  Navigator.push(
      context,
      SlideTopRoute(
          page: SmartDialogHostPage(
            formParams: params
          ))
  );
}

void navToFqtvPage(BuildContext context){
  Navigator.push(
      context, SlideTopRoute(page: MyFqtvPage(
      isAdsBooking: false,
      isLeadPassenger: true,)
    ));

  }
