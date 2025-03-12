import 'package:flutter/material.dart';

import '../Helpers/settingsHelper.dart';
import '../components/trText.dart';


/*
  using TextScaler.linear text does not seem to get resize when system font size changed
  with fontSize: pixel, text sizes

 */

Widget v2Label(String text) {
  return TrText(text,
      style: new TextStyle(
          fontWeight: FontWeight.bold, fontSize: 15.0
          ,color: wantHomePageV3() ? v2LabelColor() : null ));

}

Widget v2SearchValueText(String text){
  return Text( text,style: new TextStyle( fontSize: 18.0, fontWeight: FontWeight.bold ));
}

Widget v2MenuText(String text ){
  return Text(translate(text), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),);
}

Widget v2CalDateText(String text, Color? txtColor){
  return Text(text,
 //     textScaler: TextScaler.linear(1.2),
      style: TextStyle(
        fontSize: 14,
          color: txtColor)
  );
}

Widget v2CalDayPriceText(String text, Color? txtColor){
  return Text(text,
    //  textScaler: TextScaler.linear(1.2),
      style: TextStyle(
          fontSize: 14,
          color: txtColor)
  );
}

Widget v2CalFromText(String text, Color? txtColor){
  return Text(translate(text),
      textScaler: TextScaler.linear(1.2),
      style: TextStyle(
          fontSize: 14,
          color: txtColor)
  );
}
Widget v2TextButton(String text,  Color? txtColor){
  return Text(translate(text),
      style: TextStyle(
//      fontSize: 14,
          color: txtColor)
  );
}

Widget v2FlightText(String text,  Color? txtColor){
  return Text(translate(text),
      style: TextStyle(
//      fontSize: 14,
      color: txtColor)
  );
}
Widget v2TerminalText(String text,  Color? txtColor){
  return Text(translate(text),
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: txtColor)
  );
}

Widget v2FlightPriceText(String text,  Color? txtColor){
  return Text(translate(text),
      style: TextStyle(
          fontSize: 16,
          color: txtColor)
  );
}



