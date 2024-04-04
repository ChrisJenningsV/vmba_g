import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
//import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
//import 'package:connectivity/connectivity.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vmba/Helpers/settingsHelper.dart';
import 'package:vmba/Helpers/stringHelpers.dart';
import 'package:vmba/data/models/cities.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/repository.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom ;
import 'package:html/parser.dart' as parser;
import 'package:vmba/data/globals.dart';
import 'package:vmba/calendar/widgets/langConstants.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/utilities/widgets/buttons.dart';

import '../Helpers/networkHelper.dart';
import '../controllers/vrsCommands.dart';
import '../main.dart';
import 'messagePages.dart';
import 'package:provider/provider.dart';

// Future<String> _loadCitylistAsset() async {
//   return await rootBundle.loadString('lib/assets/data/citylist.json');
// }


Future<Session> login() async {
  logit('login');

  var body = {"AgentGuid": "${gblSettings.vrsGuid}"};
      //"AppFile": '${gblLanguage}.json' };   // temp fix

  try {
    final http.Response response = await http.post(
        Uri.parse(gblSettings.apiUrl + "/login"),
        headers: getApiHeaders(),
        body: JsonEncoder().convert(body));

    if (response.statusCode == 200) {
      Map<String, dynamic> map = json.decode(response.body);
      LoginResponse loginResponse = new LoginResponse.fromJson(map);
      if (loginResponse.isSuccessful) {
        if( gblVerbose == true ) { print('successful login'); }
        gblSession = loginResponse.getSession();
        gblLoginSuccessful = true;
        return loginResponse.getSession();
      }
    } else {
      logit('logib failed');
      logit('status code ${response.statusCode} ');
      //return  LoginResponse();
    }
  } catch(e) {
    print(e.toString());
  }
  return gblSession as Session;
}

Future sendVRSCommand(msg) async {
  final http.Response response = await http.post(
      Uri.parse(gblSettings.apiUrl + "/RunVRSCommand"),
      headers: getApiHeaders(),
      body: msg);

  if (response.statusCode == 200) {
    logit('message send successfully 1: $msg');
    return response.body.trim();
  } else {
    logit('failed6: $msg');
  }
}

Future sendVRSCommandList(msg) async {
  final http.Response response = await http.post(
      Uri.parse(gblSettings.apiUrl + "/RunVRSCommandList"),
      headers: getApiHeaders(),
      body: msg);

  if (response.statusCode == 200) {
    logit('message send successfully 2: $msg');
    return response.body.trim();
  } else {
    logit('failed');
  }
}

Future<String> _loadCountrylistAsset() async {
  switch (gblSettings.aircode) {
    case 'SI':
      return await rootBundle
          .loadString('lib/assets/blueislands/json/countries.json');
      break;
    case 'LM':
      return await rootBundle
          .loadString('lib/assets/loganair/json/countries.json');
      break;
    default:
      return await rootBundle.loadString('lib/assets/$gblAppTitle/json/countries.json');
  }
}

Future<String> mobileBarcodeTypeForCity(String code) async {
  City? city;
  city = await Repository.get().getCityByCode(code);

  if (city != null) {
    if (city.mobileBarcodeType != null && city.mobileBarcodeType != 'null' &&
        city.mobileBarcodeType.isNotEmpty) {
      return city.mobileBarcodeType;
    }
  }
  return 'AZTEC';
}

String cityCodetoAirport(String code){
  if(gblAirportCache!= null && gblAirportCache![code]!= null ) {
    return translate(gblAirportCache![code] as String);
  }
  return code;
}

Future<String> xcityCodeToName(String code) async {
  City? city;
  logit('cc->name $code');
  city = await Repository.get().getCityByCode(code);
  if(city == null )logit('c $code is null');
  if(city != null ){
    logit('c ${city.toString()}');
    if( city.shortName != null && city.shortName != '' && city.shortName != 'null' && city.shortName.isNotEmpty) {
      return translate(city.shortName);
    } else {
      return city.name;
    }
  }
  return  code;


}

Future<Countrylist> getCountrylist() async {
  String jsonString = await _loadCountrylistAsset();
  final Map<String, dynamic> map = json.decode(jsonString);
  Countrylist countrylist = new Countrylist.fromJson(map);
  return countrylist;
}

class Countrylist {
  List<DbCountry>? countries;

  Countrylist({this.countries});

  Countrylist.fromJson(Map<String, dynamic> json) {
    if (json['countries'] != null) {
      countries = [];
      //new List<Country>();
      json['countries'].forEach((v) {
        countries?.add(new DbCountry.fromJson(v));
      });
    }
  }
}

class DbCountry {
  String numCode='';
  String alpha2code='';
  String alpha3code='';
  String enShortName='';
  String nationality='';

  DbCountry(
      {this.numCode='',
      this.alpha2code='',
      this.alpha3code='',
      this.enShortName='',
      this.nationality=''});

  DbCountry.fromJson(Map<String, dynamic> json) {
    numCode = json['num_code'];
    alpha2code = json['alpha_2_code'];
    alpha3code = json['alpha_3_code'];
    enShortName = json['en_short_name'];
    nationality = json['nationality'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['num_code'] = this.numCode;
    data['alpha_2_code'] = this.alpha2code;
    data['alpha_3_code'] = this.alpha3code;
    data['en_short_name'] = this.enShortName;
    data['nationality'] = this.nationality;
    return data;
  }
}

class SlideTopRoute extends PageRouteBuilder {
  final Widget page;
  SlideTopRoute({required this.page})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
                  position:
                      Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                          .animate(animation),
                  child: child),
        );
}

Widget appLinkWidget(String uri, Widget displayWidget) {
  return GestureDetector(
    onTap: () async {
      //String uri = 'https://flutter.io';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    },
    child: displayWidget,
  );
}

List<Text> textSpliter(String data) {
  List<Text> textWidgets = [];
  // List<Text>();
  data.split(' ').forEach((word) {
    textWidgets.add(Text(word + ' '));
  });
  return textWidgets;
}

List<Text> textSpliterBoldText(String data) {
  List<Text> textWidgets = [];
  // List<Text>();
  data.split(' ').forEach((word) {
    textWidgets
        .add(Text(word + ' ', style: TextStyle(fontWeight: FontWeight.w700)));
  });
  return textWidgets;
}

Future<bool> hasDataConnection() async {
  return (gblNoNetwork == false);
/*  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
    logit('check connectivity result ${connectivityResult.toString()}');
    return false;
  }*/
}

Future<bool> hasSystemMessage() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
    return false;
  }
}

bool isSearchDate(DateTime itemDate, DateTime searchDate) {
  DateTime _searchDate =
      DateTime.parse(searchDate.toString().split(' ')[0] + ' 00:00:00');
  int diffDays = itemDate.difference(_searchDate).inDays;
  if (diffDays == 0) {
    return true;
  } else {
    return false;
  }
}

String formatPrice(String currency, double price) {
  String _currencySymbol = currency;
  //var formatCurrency = new NumberFormat.simpleCurrency();

  if( gblSettings.wantCurrencySymbols == true ) {
    _currencySymbol = simpleCurrencySymbols[currency] ?? currency;
  }
  if( wantRtl() && gblSettings.wantEnglishDates == false) {
    return translateNo(price.toStringAsFixed(2)) + ' ' + translate(_currencySymbol)  ;
  }
  return _currencySymbol + price.toStringAsFixed(2);
 // return _currencySymbol + formatCurrency.format(price);
}

/*
noInternetSnackBar(BuildContext context) {
  final snackBar = SnackBar(
    content: Text(translate('No Internet Connection.'), style: TextStyle(color: Colors.red),),
    duration: const Duration(hours: 1),
    action: SnackBarAction(
      label: translate('OK'),
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // Some code to undo the change.
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
*/
showSnackBar(String message,BuildContext context,{String label= 'Undo' }) {
  final snackBar = SnackBar(
    content: Text(message),
    dismissDirection: DismissDirection.none,
    duration: Duration(days: 365),
    action: SnackBarAction(
      label: label,
      onPressed: () {
        //Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // Some code to undo the change.
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar,);
}


void logit(String msg) {
  var now = DateTime.now();


  log( '${now.hour}:${now.minute}:${now.second}:${now.millisecond} $msg', name: ':');
  // add to msg buffer
  if( gblWantLogBuffer) {
    if (gblLogBuffer.length >= 15) {
      gblLogBuffer.removeAt(0);
    }
    gblLogBuffer.add(msg);
  }
}
void showAlert(String txt) {
  criticalErrorPage(NavigationService.navigatorKey.currentContext!,txt,title: txt, wantButtons: false );
  //showNotification( NavigationService.navigatorKey.currentContext, notification, txt);
}

bool gblSnackBarShowing = false;
showSnackbarMessage(String msg){
  gblSnackBarShowing = true;
  final snackBar = SnackBar(
    content: Container(
      //height: 40,
      child: Row(

          children: [
            Icon(Icons.error,size: 30,color: Color(Colors.red.value),
            ),
            Padding(padding: EdgeInsets.all(3),),
            Text(translate(msg), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, ), textScaleFactor: 1.5, ),
          ]),
    ),
    duration: const Duration(hours: 1),
    /* action: SnackBarAction(
      label: translate('OK'),
      onPressed: () {
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext as BuildContext).hideCurrentSnackBar();
        // Some code to undo the change.
      },
    ),*/
  );
  ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext as BuildContext).showSnackBar(snackBar);
}

hideSnackBarMessage() {
  if(gblSnackBarShowing == true){
    ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext as BuildContext).hideCurrentSnackBar();
  }
  gblSnackBarShowing = false;
}

// convert UK dd/mm/yyyy G
DateTime parseUkDateTime(String str) {
  DateFormat inputFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
  DateTime dateTime = inputFormat.parse(str,true);

  DateTime converted = dateTime.toLocal();
return converted;
}

String validateEmail(String value) {
/*
  String pattern =
      r'^(([^<>()[\]#$!%&^*+-=?\\.,;:\s@\"]+(\.[^<>()[\]#$!%&^*+-=?\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
*/
  RegExp regex = new RegExp(gblEmailValidationPattern);
  if (!regex.hasMatch(value))
    return 'Enter Valid Email';
  else
    return '';
}

Widget infoBox(String txt ) {
  return Padding(padding: new EdgeInsets.only(top: 5.0,  bottom: 5),
    child: ListTile(
      title: Transform.translate(
        offset: Offset(-16, 0),
        child:  Padding( padding: const EdgeInsets.all(8.0),
            child: Text(translate(txt), textScaleFactor: 0.75),
        ),
      ),
      tileColor: Colors.cyan.shade50,
      leading: Column( children: [
        Padding(padding: EdgeInsets.only(top:5),),
        Icon(Icons.info, color: Colors.cyan.shade900 , ),
        Padding(padding: EdgeInsets.only(top:10),)
        ]
    ),
    ),);
}

Widget warningBox(String txt ) {
  return Padding(padding: new EdgeInsets.only(top: 10.0,  bottom: 5),
    child: ListTile(
      title: Transform.translate(
        offset: Offset(-16, 0),
        child: Padding(padding: const EdgeInsets.all(8.0),
        child:Text(translate(txt), textScaleFactor: 0.75),
      ),),
      tileColor: Colors.yellow.shade50,
      leading: Column( children: [
        Padding(padding: EdgeInsets.only(top:5),),
        Icon(Icons.warning_amber_outlined, color: Colors.yellow.shade900 , ),
        Padding(padding: EdgeInsets.only(top:10),)
      ]
      ),
    ),);
}


InputDecoration getDecoration(String label, {String hintText='', Widget? prefixIcon}) {
  //var borderRadius = 10.0;

  //if ( gblSettings.wantMaterialControls == true ) {
    return InputDecoration(
      fillColor: Colors.grey.shade100,
      filled: true,
      //counter: Container(),
      counterText: '',
      hintText: hintText,
      prefixIcon: prefixIcon,

      labelStyle: TextStyle(color: Colors.grey),
      //    contentPadding:
      //      new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      labelText: translate(label),

//        fillColor: Colors.white,
    );

  //}

}

String cleanInt(String str) {
  if( str.contains('.')){
    str=str.split('.')[0];
  }
  return str;
}

void showHtml(BuildContext context, String title, String txt ) {
  Widget wHtml = Column( children: getDom(txt), mainAxisSize: MainAxisSize.min, );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        actions: <Widget>[
          smallButton( text: 'OK', icon: Icons.check, onPressed: () {   Navigator.of(context).pop();}),
          /*new TextButton(
            child: new TrText("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),*/
        ],
        title: new TrText(title),
        content: wHtml,

      );
    },
  );
}

List<Widget> getDom( String str){
List<Widget> list = [];
  dom.Document document = parser.parse(str);
  (document.body?.nodes as List).forEach((el){
    String s = el.text as String;
    if( s != null && s.isNotEmpty) {
      list.add(Flexible(
          child: Text(s, overflow: TextOverflow.clip,)));
    }
    logit( s + ' ${el.nodes.length} nodes');
  });


  return list;
}
bool parseBool( Object str ){
  if( str == null ) {
    return false;
  }
  if( str == '') {
    return false;
  }
  if( str == '-1') {
    return true;
  }
  if( str.runtimeType == String ) {
    return ((str as String).toLowerCase() == 'true');
  }
  if( str == false) return false;
  return true;
}
Widget addCountry(DbCountry country) {
  Image? img;
  String name = country.enShortName;
  String name2 = '';
  if( name.length > 28) {   // was 30 but not work on old iPhone
    // split on a space'
    //name2 = name.substring(30);
    //name = name.substring(0,30);
    int  middle = 28; // (name.length / 2).round();
    int before = name.lastIndexOf(' ', middle);
    int after = name.indexOf(' ', middle + 1);

    if (before == -1 || (after != -1 && middle - before >= after - middle)) {
      middle = after;
    } else {
      middle = before;
    }

    name2 = name.substring(middle + 1);
    name = name.substring(0, middle);
  }
  //return Text(name);

  try {
    img = Image.asset(
      'icons/flags/png/${country.alpha2code.toLowerCase()}.png',
      package: 'country_icons',
      width: 20,
      height: 20,);
  } catch(e) {
    logit(e.toString());
  }
  List<Widget> list = [];
  if (img != null ) {
    list.add(img);
  }
  list.add(SizedBox(width: 10,));
  if( name2 != '') {
    list.add(Column(
      children: [
        new Text(name),
        new Text(name2)
      ],
    ));
  } else {
    list.add(new Text(name));
  }


  return Row(children: list);
}

networkOffline() {
  if( gblNoNetwork == false) {
    gblNoNetwork = true;
    showSnackbarMessage('No Network');
  }
  refreshCurPage();

}

networkOnline() async {
  gblNoNetwork = false;
  hideSnackBarMessage();
  if( gblLoginSuccessful == false && gblCurPage != 'ROOTPAGE'){
    await Repository.get().settings();
  } else {
    refreshCurPage();
  }

}

refreshCurPage(){
  gblInRefreshing = true;
  Provider.of<LocaleModel>(NavigationService.navigatorKey.currentContext as BuildContext,listen:false).changelocale(Locale(gblLanguage));
  Timer(Duration(seconds: 10), () {
    gblInRefreshing = false;
  });
}

commonPageInit(String pageName) {
  if(gblNoNetwork == false){
    // check no snackbar
    hideSnackBarMessage();
  }
  //gblPayAction = pageName;
  gblPageName = pageName;
  gblActionBtnDisabled = false;
  setError('');
  gblStack = null;
  gblInRefreshing = false;
}

networkStateChange(Map netState) {
  switch(netState.keys.toList()[0]){
    case ConnectivityResult.mobile:
    // 'Mobile: Online';
      logit('Mobile: Online');
      networkOnline();
      break;
    case ConnectivityResult.wifi:
    // 'WiFi: Online';
      logit('WiFi: Online');
      networkOnline();
      break;
    case ConnectivityResult.none:
    default:
    // 'Offline';
      logit('Offline');
      networkOffline();
  }

}
bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return num.tryParse(s) != null;
}

List <String> splitString(String str, int maxLen){
  List <String> splitStr = str.split(' ');
  List <String> strings = [];

  String addStr = '';
  int index = 0;
  splitStr.forEach((element) {
    bool addedEl = false;
    if( addStr != '' && (addStr.length + element.length > maxLen)  ){
      strings.add(addStr);
      addStr = '';
  /*  } else if(  addStr != '' && (addStr.length + element.length <= maxLen)   ) {
      strings.add(addStr + ' ' + element);
      addStr = '';
      addedEl = true;*/
    }
    if( addedEl == false && element.length >= maxLen ){
      addStr = '';
      strings.add( element);
      addedEl = true;
    }


    index +=1;
    if( index == splitStr.length){
      // last one
      if( addStr != '' && (addStr.length + element.length <= maxLen)  ) {
        strings.add(addStr + ' ' + element);
        addedEl = true;
      } else if (addStr != '' ) {
        strings.add(addStr);
      }
      if(addedEl == false ) strings.add(element);

    } else {
      if( addedEl == false) addStr = addStr + ' ' + element;
    }
  });

  return strings;
}
Future<void> reloadSavedBooking(String rloc) async {
  try {
  await Repository.get().fetchApisStatus(rloc);
  await Repository.get().fetchPnr(rloc);
  } catch(e) {
    logit(e.toString());
  }
}
