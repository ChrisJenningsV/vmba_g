import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';

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

Widget v2SearchValueText(String text, {bool narrowField = false}){
  double fontSize = 18.0;
  double scale = 1.25;
  if( narrowField) {
    if (text.length > 15) {
      fontSize = 16.0;
      scale = 1.2;
    }
    if (text.length > 18) {
      fontSize = 15.0;
      scale = 1.1;
    }
    if (text.length > 20)
    {
      fontSize = 12.0;
      scale = 1.0;
    }
  } else {
    if (text.length > 20){
      fontSize = 16.0;
      scale = 1.1;
    }
  }

  if( gblIsIos) {
    return Text(text,style: new TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(scale));
  } else {
    return Text(text,style: new TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold));
  }
}

Widget v2MenuText(String text, {bool smallFont = false }){
  return Text(translate(text), style: TextStyle(fontWeight: FontWeight.bold), textScaler: smallFont ? TextScaler.linear(1.0):TextScaler.linear(1.2),);
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

Widget v2NotifyText( String text,  Color? txtColor){
  return Text(text,
      style: TextStyle(
//      fontSize: 14,
          color: txtColor)
  );
}

Widget v2FlightText(String text,  Color? txtColor, {int? maxLines = null}){
  return Text(translate(text),
      style: TextStyle(
//      fontSize: 14,
      color: txtColor,),
      maxLines: maxLines,
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

String replaceCrWithBreak(String body1){
  String body2 = '';
  for (int i=0; i<body1.length;i++){
    String c1 = body1[i];
    if( c1.codeUnitAt(0) == 10){
      // it's single code new line / line feed
      c1 = '<br>';

    } else if( c1 == '\\'){
      String c2 = body1[i+1];
      if( c2 == 'n'){
        // rip it out
        i++;
        c1 = '<br>';
      }
    }
    body2 += c1;
  }
  return body2;
}

