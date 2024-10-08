



import 'package:flutter/material.dart';

import '../data/globals.dart';

void setLiveTest() {
  if(gblIsLive == true) {
    //gblSettings.payUrl = gblSettings.livePayUrl;
    gblSettings.payPage = gblSettings.livePayPage;
    gblSettings.xmlUrl = gblSettings.liveXmlUrl;
    gblSettings.apisUrl = gblSettings.liveApisUrl;
    gblSettings.apiUrl = gblSettings.liveApiUrl;
    gblSettings.smartApiUrl = gblSettings.liveSmartApiUrl;
    gblSettings.creditCardProvider  = gblSettings.liveCreditCardProvider;
  } else {
    // gblSettings.payUrl = gblSettings.testPayUrl;
    gblSettings.payPage = gblSettings.testPayPage;
    gblSettings.xmlUrl = gblSettings.testXmlUrl;
    gblSettings.apisUrl = gblSettings.testApisUrl;
    gblSettings.apiUrl = gblSettings.testApiUrl;
    gblSettings.smartApiUrl = gblSettings.testSmartApiUrl;
    gblSettings.creditCardProvider  = gblSettings.testCreditCardProvider;
    if( gblSettings.testServerFiles != '' && gblSettings.testServerFiles.isNotEmpty){
      gblSettings.gblServerFiles = gblSettings.testServerFiles;
    }
  }
}

bool wantRtl() {
  if( gblLanguage == 'ar'){
    return true;
  }
  return false;
}

bool wantPageV2() {
  if( gblSettings.pageStyle == 'V2' ) {
    return true;
  } else {
    return false;
  }
}
bool wantHomePageV2() {
  if( gblSettings.homePageStyle == 'V2') {
    return true;
  } else {
    return false;
  }
}

bool wantHomePageV3() {
  if( gblSettings.homePageStyle == 'V3') {
    return true;
  } else {
    return false;
  }
}
bool wantCustomHome(){
  return gblSettings.wantCustomHomepage;
}

Color v2BorderColor(){
  return gblSystemColors.borderColor;
  //return Colors.grey.withOpacity(0.5);
}
EdgeInsets v2FormPadding(){
  return EdgeInsets.all(5);
}

BoxDecoration v2FormDecoration() {
  if( gblSettings.wantShadows) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey,
          //  gblSystemColors.primaryHeaderColor.withOpacity(0.5), //Colors.blue.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 9), // changes position of shadow
        ),
      ],
    );
  } else {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    );

  }
}

Color v2PageBackgroundColor(){
  if( gblSystemColors.backgroundColor != null ) {
    return gblSystemColors.backgroundColor as Color;
  }
  return Colors.grey.shade400;
  //return Colors.grey.withOpacity(0.5);
}

double v2BorderWidth() {
  return 1;
}

int parseInt( String str ){
  if( str == null ) {
    return 0;
  }
  if( str.isEmpty) {
    return 0;
  }
  return int.parse(str);
}