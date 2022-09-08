import 'package:flutter/material.dart';

class SystemColors {
  final Color primaryButtonColor;
  final Color primaryButtonTextColor;
  final Color otherButtonTextColor;
  final Color accentButtonColor;
  final Color home1ButtonColor;
  final Color home2ButtonColor;
  final Color home1ButtonTextColor;
  final Color home2ButtonTextColor;

  //final Color buttonColor; // = Color.fromRGBO(243, 135, 57, 1);
  final Color primaryColor; // = Colors.white;
   Color otherButtonColor;
   Color textButtonTextColor;
   Color accentColor; // = Colors.white;

   Color primaryHeaderColor;
   Color progressBackColor;
  Color progressTextColor;
   Color headerTextColor;
   Color promoBackColor;

  final Brightness statusBar;

//  final Color primaryTitle;
  //final Color accentTitle;
//  final Color accentBody;
 // final Color primaryLink;
  //final Color accentLink;
   Color seatPlanColorSelected;
   Color seatPlanColorEmergency;
   Color seatPlanColorAvailable;
   Color seatPlanColorUnavailable;
   Color seatPlanColorRestricted;

  SystemColors({
    @required this.primaryButtonColor,
    @required this.accentButtonColor,
    @required this.primaryColor,
    @required this.accentColor,
    this.otherButtonColor,
    this.otherButtonTextColor,
    this.primaryButtonTextColor,
    this.textButtonTextColor,
    this.home1ButtonColor,
    this.home2ButtonColor,
    this.home1ButtonTextColor,
    this.home2ButtonTextColor,
    this.progressBackColor,
    this.progressTextColor,
    this.primaryHeaderColor,
    this.headerTextColor,
    this.statusBar,
//    this.primaryTitle,
 //   this.accentTitle,
 //   this.accentBody,
//    this.primaryLink,
//    this.accentLink,
    this.seatPlanColorSelected,
    this.seatPlanColorEmergency,
    this.seatPlanColorAvailable,
    this.seatPlanColorUnavailable,
    this.seatPlanColorRestricted,
    this.promoBackColor ,
  });

  void setDefaults() {

    if( textButtonTextColor == null ) textButtonTextColor = Colors.black;
    if( accentColor == null ) accentColor = Colors.black;

    //final Color primaryHeaderColor;
    //final Color headerTextColor;

    //final Brightness statusBar;

    if( seatPlanColorSelected == null ) seatPlanColorSelected = Colors.blue.shade900;
    if(seatPlanColorEmergency == null) seatPlanColorEmergency= Colors.red;
    if(seatPlanColorAvailable == null) seatPlanColorAvailable = Colors.blue;
    if(seatPlanColorUnavailable == null) seatPlanColorUnavailable =Colors.grey.shade300;
    if(seatPlanColorRestricted == null) seatPlanColorRestricted = Colors.green[200];
    if( promoBackColor == null ) promoBackColor = Colors.blue.shade100;
    if( otherButtonColor == null ) otherButtonColor = primaryButtonColor;

    if(progressBackColor == null ) progressBackColor = primaryHeaderColor;
    if(progressTextColor == null) progressTextColor = headerTextColor;


  }
}
