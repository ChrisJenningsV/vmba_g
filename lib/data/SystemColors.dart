
import 'package:flutter/material.dart';

class SystemColors {
  final Color primaryButtonColor;
  Color? progressColor ;
  final Color? primaryButtonTextColor;
  final Color? otherButtonTextColor;
  Color accentButtonColor = Colors.cyan;
  Color? home1ButtonColor;
  Color? home2ButtonColor;
  Color? home1ButtonTextColor;
  Color? home2ButtonTextColor;

  //final Color buttonColor; // = Color.fromRGBO(243, 135, 57, 1);
  final Color primaryColor; // = Colors.white;
   Color? otherButtonColor;
   Color textButtonTextColor;
   Color plainTextButtonTextColor;
   Color accentColor; // = Colors.white;
  Color? classBandIconColor;

  Color borderColor;
   Color primaryHeaderColor ;
   Color? dialogHeaderColor ;
   Color? dialogHeaderTextColor;
   Color? calInRangeColor;
   Color? calDisabledColor;
   Color? calTextColor;
   Color? calDepartColor;
   Color? calReturnColor;
   Color? calTodayColor;
   Color? calBackColor;
   Color? calTodayTextColor;
   Color? progressBackColor;
   Color? progressTextColor;
   Color? headerTextColor;
   Color? promoBackColor;
   Color? oldPriceColor;
   Color textEditBorderColor =  Colors.grey.shade300;
   Color? textEditIconColor;
   Color? tabUnderlineColor;
   Color? v3TitleColor;
   Color?  inputFillColor;
   Color? backgroundColor;

   Brightness statusBar = Brightness.light;

//  final Color primaryTitle;
  //final Color accentTitle;
//  final Color accentBody;
 // final Color primaryLink;
  //final Color accentLink;
   Color? seatPlanColorSelected;
   Color? seatPlanColorEmergency;
   Color? seatPlanColorAvailable;
   Color? seatPlanColorUnavailable;
   Color? seatPlanColorRestricted;
  Color? seatPlanTextColorSelected;
  Color? seatPlanTextColorEmergency;
  Color? seatPlanTextColorAvailable;
  Color? seatPlanTextColorUnavailable;
  Color? seatPlanTextColorRestricted;
  Color? seatPlanBackColor;
  Color? seatPlanFuselageColor;
  Color? seatPlanWingColor;
  Color? seatPlanWallColor;
  Color? seatPriceColor;
  Color? seatSelectButtonColor;
  Color? seatSelectTextColor;

   // new av colors
  Color? selectedFlt;
  Color? unselectedFlt;
  Color? fltText;
  Color? selectedFare;
  Color? defaultFaretext;
  Color? selectedFareText;
  List<Color>? fareColors;


  SystemColors({
    required this.primaryButtonColor,
    required this.accentButtonColor,
    required this.primaryColor,
    required this.accentColor,
    this.classBandIconColor,
    this.progressColor,
    this.otherButtonColor,
    this.otherButtonTextColor,
    this.primaryButtonTextColor,
    this.textButtonTextColor = Colors.black,
    this.plainTextButtonTextColor = Colors.blue,
    this.home1ButtonColor,
    this.home2ButtonColor,
    this.home1ButtonTextColor,
    this.home2ButtonTextColor,
    this.progressBackColor,
    this.progressTextColor,
    required this.primaryHeaderColor,
    this.dialogHeaderColor,
    this.dialogHeaderTextColor,
    this.calInRangeColor = Colors.black54,
    this.calDisabledColor = Colors.transparent,
    this.calTextColor = Colors.black,
    this.calDepartColor = Colors.green,
    this.calReturnColor = Colors.blue,
    this.calTodayColor = Colors.white,
    this.calBackColor,
    this.calTodayTextColor = Colors.red,
    this.headerTextColor,
    this.statusBar =Brightness.light,
    this.textEditBorderColor = Colors.grey,
    this.textEditIconColor,
    this.tabUnderlineColor,
//    this.primaryTitle,
 //   this.accentTitle,
 //   this.accentBody,
//    this.primaryLink,
//    this.accentLink,
    this.seatPlanWingColor = Colors.grey,
    this.seatPlanFuselageColor = Colors.black,
    this.seatPlanWallColor = Colors.lightBlueAccent,
    this.borderColor = Colors.grey,
    this.seatPlanColorSelected,
    this.seatPlanColorEmergency,
    this.seatPlanColorAvailable,
    this.seatPlanColorUnavailable,
    this.seatPlanColorRestricted,
    this.seatPlanTextColorSelected,
    this.seatPlanTextColorEmergency,
    this.seatPlanTextColorAvailable,
    this.seatPlanTextColorUnavailable,
    this.seatPlanTextColorRestricted,
    this.seatPlanBackColor,
    this.seatPriceColor,
    this.seatSelectButtonColor,
    this.seatSelectTextColor,

    this.promoBackColor ,
    this.v3TitleColor = Colors.black,
    this.inputFillColor ,
    this.backgroundColor,
    this.selectedFlt = Colors.black,
    this.unselectedFlt = Colors.grey,
    this.fltText = Colors.white,
    this.defaultFaretext = Colors.black,

    this.fareColors,
    this.selectedFare = Colors.red,
    this.selectedFareText = Colors.white,
  });

  void setDefaults() {

    if( textButtonTextColor == null ) textButtonTextColor = Colors.black;
    //if( accentColor == null ) accentColor = Colors.black;
    if( oldPriceColor == null ) oldPriceColor = Colors.red;

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
    if( progressColor == null ) progressColor =  primaryHeaderColor;
    if( textEditBorderColor == null ) textEditBorderColor = Colors.grey.shade300;
    if( textEditIconColor == null ) textEditIconColor =Colors.grey.shade500;
    if( inputFillColor == null ) inputFillColor = Colors.grey.shade100;
    if( backgroundColor == null ) backgroundColor = Colors.grey.shade400;
    if( dialogHeaderColor == null ) dialogHeaderColor = primaryHeaderColor;
    if( dialogHeaderTextColor == null ) dialogHeaderTextColor = headerTextColor;
    if( calBackColor == null ) calBackColor = Colors.grey.shade300;
  }
}
