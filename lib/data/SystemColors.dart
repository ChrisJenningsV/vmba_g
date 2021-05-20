import 'package:flutter/material.dart';

class SystemColors {
  final Color primaryButtonColor;
  final Color primaryButtonTextColor;
  final Color accentButtonColor;

  //final Color buttonColor; // = Color.fromRGBO(243, 135, 57, 1);
  final Color primaryColor; // = Colors.white;
  final Color textButtonTextColor;
  final Color accentColor; // = Colors.white;

  final Color primaryHeaderColor;
  final Color headerTextColor;

  final Brightness statusBar;

  final Color primaryTitle;
  final Color accentTitle;
  final Color primaryBody;
  final Color accentBody;
  final Color primaryLink;
  final Color accentLink;
  final Color seatPlanColorSelected;
  final Color seatPlanColorEmergency;
  final Color seatPlanColorAvailable;
  final Color seatPlanColorUnavailable;
  final Color seatPlanColorRestricted;

  SystemColors({
    @required this.primaryButtonColor,
    @required this.accentButtonColor,
    @required this.primaryColor,
    @required this.accentColor,
    this.primaryButtonTextColor,
    this.textButtonTextColor,
    this.primaryHeaderColor,
    this.headerTextColor,
    this.statusBar,
    this.primaryTitle,
    this.accentTitle,
    this.primaryBody,
    this.accentBody,
    this.primaryLink,
    this.accentLink,
    this.seatPlanColorSelected,
    this.seatPlanColorEmergency,
    this.seatPlanColorAvailable,
    this.seatPlanColorUnavailable,
    this.seatPlanColorRestricted,
  });
}
