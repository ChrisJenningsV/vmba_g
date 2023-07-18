import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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
      Map map = json.decode(response.body);
      LoginResponse loginResponse = new LoginResponse.fromJson(map);
      if (loginResponse.isSuccessful) {
        if( gblVerbose == true ) { print('successful login'); }
        gblSession = loginResponse.getSession();
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
  return null;
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
  City city;
  city = await Repository.get().getCityByCode(code);

  if (city != null) {
    if (city.mobileBarcodeType != null && city.mobileBarcodeType != 'null' &&
        city.mobileBarcodeType.isNotEmpty) {
      return city.mobileBarcodeType;
    }
  }
  return 'AZTEC';
}

Future<String> cityCodeToName(String code) async {
  City city;
  city = await Repository.get().getCityByCode(code);

  if(city != null ){
    if( city.shortName != null && city.shortName != 'null' && city.shortName.isNotEmpty) {
      return translate(city.shortName);
    } else {
      return city.name;
    }
  }
  return  code;

/*   Cities city;
  String jsonString = await _loadCitylistAsset();
  final Map map = json.decode(jsonString);
  Citylist citylist = new Citylist.fromJson(map);

  city = citylist.cities
      .firstWhere((item) => item.code == code, orElse: () => null);
  return city == null ? code : city.name; */
}

/*
class Citylist {
  List<Cities> cities;

  Citylist({this.cities});

  Citylist.fromJson(Map<String, dynamic> json) {
    if (json['cities'] != null) {
      cities = [];
      // new List<Cities>();
      json['cities'].forEach((v) {
        cities.add(new Cities.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cities != null) {
      data['cities'] = this.cities.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cities {
  String code;
  String name;

  Cities({this.code, this.name});

  Cities.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    return data;
  }
}

 */

Future<Countrylist> getCountrylist() async {
  String jsonString = await _loadCountrylistAsset();
  final Map map = json.decode(jsonString);
  Countrylist countrylist = new Countrylist.fromJson(map);
  return countrylist;
}

class Countrylist {
  List<DbCountry> countries;

  Countrylist({this.countries});

  Countrylist.fromJson(Map<String, dynamic> json) {
    if (json['countries'] != null) {
      countries = [];
      //new List<Country>();
      json['countries'].forEach((v) {
        countries.add(new DbCountry.fromJson(v));
      });
    }
  }
}

class DbCountry {
  String numCode;
  String alpha2code;
  String alpha3code;
  String enShortName;
  String nationality;

  DbCountry(
      {this.numCode,
      this.alpha2code,
      this.alpha3code,
      this.enShortName,
      this.nationality});

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

/* class Cities {
  final List<City> cities;

  Cities({
    this.cities
  });

  factory Cities.fromJson(Map<String, dynamic> parsedJson) {
  
  return new Cities(
      cities: parsedJson['city'],
  );
}
}

class City {
  final String code;
  final String name;

  City(
    this.code,
    this.name,
  );

  City.fromJson(Map<String, dynamic> parsedjson)
      : code = parsedjson['code'],
        name = parsedjson['name'];

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
      };
} */

class SlideTopRoute extends PageRouteBuilder {
  final Widget page;
  SlideTopRoute({this.page})
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
/*
Widget appLink(String uri, String displayValue) {
  return GestureDetector(
    onTap: () async {
      //String uri = 'https://flutter.io';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    },
    child: Text(displayValue),
  );
}*/

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
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
    logit('check connectivity result ${connectivityResult.toString()}');
    return false;
  }
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
  if( wantRtl()) {
    return translateNo(price.toStringAsFixed(2)) + ' ' + translate(_currencySymbol)  ;
  }
  return _currencySymbol + price.toStringAsFixed(2);
 // return _currencySymbol + formatCurrency.format(price);
}
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
showSnackBar(String message,BuildContext context) {
  final snackBar = SnackBar(
    content: Text(message),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        // Some code to undo the change.
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
// convert UK dd/mm/yyyy G
DateTime parseUkDateTime(String str) {
  DateFormat inputFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
  DateTime dateTime = inputFormat.parse(str,true);

  DateTime converted = dateTime.toLocal();
return converted;
}

String validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return 'Enter Valid Email';
  else
    return null;
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


InputDecoration getDecoration(String label, {String hintText, Widget prefixIcon}) {
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
  document.body.nodes.forEach((el){
    String s = el.text;
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
  Image img;
  String name = country.enShortName;
  String name2 = '';
  if( name.length > 20) {   // was 30 but not work on old iPhone
    // split on a space'
    //name2 = name.substring(30);
    //name = name.substring(0,30);
    int  middle = 20; // (name.length / 2).round();
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
    logit(e);
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

  /*   if (img == null ) {
      return Row(children: <Widget>[
        SizedBox(width: 10,),
        Expanded( child: new Text(name))
      ],
      mainAxisAlignment: MainAxisAlignment.start,);
    } else {
      return Row(children: <Widget>[
        img,
        SizedBox(width: 10,),
        Expanded( child: new Text(name))
      ],
        mainAxisAlignment: MainAxisAlignment.start,
      );*/

  return Row(children: list);
}

