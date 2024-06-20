

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/globals.dart';

Color actionButtonColor( {bool availableOffline = false} ){
  if(  availableOffline == true || gblNoNetwork == false) {
    if( gblV3Theme != null && gblV3Theme!.generic != null && gblV3Theme!.generic!.actionButtonColor != null ) {
      return gblV3Theme!.generic!.actionButtonColor as Color;
    } else {
      return gblSystemColors.primaryButtonColor;
    }
  } else {
    return disabledActionButtonColor();
  }
}
Color actionButtonDisabledColor(){
  return Colors.white;
}
Color actionButtonDisabledTextColor(){
  return Colors.grey;
}

Color cancelButtonColor( ){
  return Colors.grey.shade100;
}

Color disabledActionButtonColor(){
  return gblSystemColors.primaryButtonColor.withOpacity(0.4);
}



