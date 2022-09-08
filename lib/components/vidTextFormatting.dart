import 'package:flutter/material.dart';

Widget getH2Text(String stext, {String right}) {
  if (right != null ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(stext, style: TextStyle(fontWeight: FontWeight.bold),  textScaleFactor: 1.25,  ),
        Text(right, style: TextStyle(fontWeight: FontWeight.bold),  textScaleFactor: 1.25,  ),
      ],
    );
  }
  return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text( stext, style: TextStyle(fontWeight: FontWeight.bold),  textScaleFactor: 1.25, )
        ]);
}

Widget tableRow(String label , String value ){
  return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
      Text(label),
      Text(value),
  ],
  );
}

Widget tableTitle(String title,{String right}) {
  return getH2Text(title, right: right);
}