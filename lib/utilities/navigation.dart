import 'package:flutter/material.dart';

import '../mmb/viewBookingPage.dart';


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