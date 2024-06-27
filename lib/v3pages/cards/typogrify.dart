

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/trText.dart';
import '../v3Theme.dart';

Widget labelText(String label){
  return Align(
    alignment: Alignment.topLeft,
    child: Text(translate(label), style: TextStyle(color: Colors.grey),),
  );

}

Widget inPageTitleText(String label){
  return Column(
  children: [
    Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
    child: Align(
    alignment: Alignment.topLeft,
    child: Text(translate(label), textScaler: TextScaler.linear(1.3), style: TextStyle(fontWeight: FontWeight.bold),),
    )),
    V3Divider()
    ]
  );

}
