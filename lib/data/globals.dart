import 'package:flutter/material.dart';
import 'package:vmba/data/models/models.dart';
import 'SystemColors.dart';
import 'package:vmba/data/settings.dart';

// variable shared to whole app
// initialized in main_XX.dart
//
String gblAppTitle ;
String gblLanguage = 'en' ;
String gblLanguages ;
String gblServerFiles;
String gblBuildFlavor = 'FL';
String gblError = '';
String gblSine = '';
String gblVersion = '';
String gblAction='';
String gblMobileFlags = '';
int gblSecurityLevel = 0;
int gblFqtvBalance = 0;
bool gblIsIos = false;
bool gblIsLive = false;
bool gblTimerExpired = false;
bool gblPayBtnDisabled = false;
bool gblRememberMe = false;
bool gblRedeemingAirmiles = false;
bool gblNewDatepicker = true;
bool shownUpdate = false;
String gblFqtvNumber = '';
//String gblAdsNo = '';
//String gblAdsPin = '';
PassengerDetail gblPassengerDetail;
SystemColors gblSystemColors;
Session gblSession;
Map gblLangMap ;
Settings gblSettings;
bool gblNoNetwork;
bool gblVerbose = false;
bool  gblWantLogin = true;
TextStyle gblTitleStyle;
List<String> gblTitles = <String>[
  'Mr',
  'Mrs',
  'Ms',
  'Dr',
  'Miss',
  'Mstr',
  'Prof',
  'Rev'
];
