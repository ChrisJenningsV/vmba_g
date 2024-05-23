


import 'package:flutter/material.dart';

TextScaler? v2H2Scale() {
  return TextScaler.linear(1.2);
}

class V2Heading2Text extends Text {
  V2Heading2Text(super.data);

  build(BuildContext context){
    return Text(data!, textScaler: v2H2Scale(), style: TextStyle(fontWeight: FontWeight.bold) ,);
  }
}
