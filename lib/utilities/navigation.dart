import 'package:flutter/material.dart';


// go to new user home page
void navToHomepage(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
}

void navToFlightSearchPage(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil('/FlightSearchPage', (Route<dynamic> route) => false);
}