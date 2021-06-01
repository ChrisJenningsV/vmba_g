import 'dart:async';
import 'dart:convert';
//import 'package:loganair/data/repository.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'package:vmba/data/models/cities.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/data/settings.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/data/globals.dart';

//import 'package:loganair/data/models/cities.dart';
//import 'package:url_launcher/url_launcher.dart';
//import 'package:connectivity/connectivity.dart';

// Future<String> _loadCitylistAsset() async {
//   return await rootBundle.loadString('lib/assets/data/citylist.json');
// }

Future<Session> login() async {
  var body = {"AgentGuid": "${gblSettings.vrsGuid}"};

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
      print('successful login');
      return loginResponse.getSession();
    }
  } else {
    print('failed');
    //return  LoginResponse();
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
    print('message send successfully');
    return response.body.trim();
  } else {
    print('failed: $msg');
  }
}

Future<http.Response> post(Uri url,
  {Map<String, String> headers, Object body, Encoding encoding}) {

}

Future sendVRSCommandList(msg) async {
  final http.Response response = await http.post(
      Uri.parse(gblSettings.apiUrl + "/RunVRSCommandList"),
      headers: {'Content-Type': 'application/json',
        'Videcom_ApiKey': gblSettings.apiKey
      },
      body: msg);

  if (response.statusCode == 200) {
    print('message send successfully');
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
      return await rootBundle.loadString('lib/assets/${gblAppTitle}/json/countries.json');
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
