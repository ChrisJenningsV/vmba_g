import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'package:vmba/data/models/cities.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/repository.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/data/globals.dart';
import 'package:vmba/calendar/widgets/langConstants.dart';
import 'package:vmba/components/trText.dart';


// Future<String> _loadCitylistAsset() async {
//   return await rootBundle.loadString('lib/assets/data/citylist.json');
// }

Future<Session> login() async {
  logit('login');

  var body = {"AgentGuid": "${gblSettings.vrsGuid}"};

  try {
    final http.Response response = await http.post(
        Uri.parse(gblSettings.apiUrl + "/login"),
        headers: {
          'Content-Type': 'application/json',
          'Videcom_ApiKey': gblSettings.apiKey
        },
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
      print('failed');
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
      headers: {
        'Content-Type': 'application/json',
        'Videcom_ApiKey': gblSettings.apiKey
      },
      body: msg);

  if (response.statusCode == 200) {
    print('message send successfully: $msg');
    return response.body.trim();
  } else {
    print('failed: $msg');
  }
}

Future sendVRSCommandList(msg) async {
  final http.Response response = await http.post(
      Uri.parse(gblSettings.apiUrl + "/RunVRSCommandList"),
      headers: {'Content-Type': 'application/json',
        'Videcom_ApiKey': gblSettings.apiKey
      },
      body: msg);

  if (response.statusCode == 200) {
    print('message send successfully: $msg');
    return response.body.trim();
  } else {
    print('failed');
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

Future<String> cityCodeToName(String code) async {
  City city;
  city = await Repository.get().getCityByCode(code);

  if(city != null ){
    if( city.shortName != null && city.shortName != 'null' && city.shortName.isNotEmpty) {
      return city.shortName;
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
  List<Country> countries;

  Countrylist({this.countries});

  Countrylist.fromJson(Map<String, dynamic> json) {
    if (json['countries'] != null) {
      countries = [];
      //new List<Country>();
      json['countries'].forEach((v) {
        countries.add(new Country.fromJson(v));
      });
    }
  }
}

class Country {
  String numCode;
  String alpha2code;
  String alpha3code;
  String enShortName;
  String nationality;

  Country(
      {this.numCode,
      this.alpha2code,
      this.alpha3code,
      this.enShortName,
      this.nationality});

  Country.fromJson(Map<String, dynamic> json) {
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
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
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

}
// convert UK dd/mm/yyyy G
DateTime parseUkDateTime(String str) {
  DateFormat inputFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
  DateTime dateTime = inputFormat.parse(str,true);

  DateTime converted = dateTime.toLocal();
return converted;
}