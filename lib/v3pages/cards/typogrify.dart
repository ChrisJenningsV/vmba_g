

import 'package:flutter/material.dart';

import '../../components/trText.dart';

Widget labelText(String label){
  return Align(
    alignment: Alignment.topLeft,
    child: Text(translate(label), style: TextStyle(color: Colors.grey),),
  );

}