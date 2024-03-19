

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/globals.dart';

Color actionButtonColor( {bool availableOffline = false} ){
  if(  availableOffline == true || gblNoNetwork == false) {
    return gblSystemColors.primaryButtonColor;
  } else {
    return disabledActionButtonColor();
  }
}

Color cancelButtonColor( ){
  return Colors.grey.shade100;
}

Color disabledActionButtonColor(){
  return gblSystemColors.primaryButtonColor.withOpacity(0.4);
}



