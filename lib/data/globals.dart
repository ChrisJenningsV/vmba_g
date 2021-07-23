import 'package:flutter/material.dart';
import 'package:vmba/data/models/models.dart';
import 'SystemColors.dart';
import 'package:vmba/data/settings.dart';

// variable shared to whole app
// initialized in main_XX.dart
//
String gblAppTitle ;
String gblLanguage = 'en' ;
bool gblLangFileLoaded = false;
bool gblSaveLangsFile = true;
String gblLangFileModTime = '';
String gblBuildFlavor = 'AH';
String gblError = '';
String gblErrorTitle = '';
String gblSine = '';
String gblVersion = '';
String gblAction='';
String gblMobileFlags = '';
int gblSecurityLevel = 0;
int gblFqtvBalance = 0;
bool gblIsIos = false;
bool gblIsLive = true;
bool gblTimerExpired = false;
bool gblPayBtnDisabled = false;
bool gblRememberMe = false;
bool gblRedeemingAirmiles = false;
bool gblNewDatepicker = false;
bool shownUpdate = false;
bool gblCentreTitle = false;
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
