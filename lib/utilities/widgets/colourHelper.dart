

import 'dart:ui';

import '../../data/globals.dart';

Color actionButtonColor( {bool availableOffline = false} ){
  if(  availableOffline == true || gblNoNetwork == false) {
    return gblSystemColors.primaryButtonColor;
  } else {
    return disabledActionButtonColor();
  }
}

Color disabledActionButtonColor(){
  return gblSystemColors.primaryButtonColor.withOpacity(0.4);
}



