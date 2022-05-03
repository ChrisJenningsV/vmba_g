import 'package:meta/meta.dart';

class Cities {
  List<City> cities;

  Cities({this.cities});

  Cities.fromJson(Map<String, dynamic> json) {
    if (json['Cities'] != null) {
      cities = [];
      //new List<City>();
      if (json['Cities'] is List) {
        json['Cities'].forEach((v) {
          cities.add(new City.fromJson(v));
        });
      } else {
        cities.add(new City.fromJson(json['Cities']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cities != null) {
      data['City'] = this.cities.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class City {
  static final dbCode = "code";
  static final dbName = "name";
  static final dbShortName = "shortName";
  static final dbWebCheckinEnabled = "webCheckinEnabled";
  static final dbWebCheckinStart = "webCheckinStart";
  static final dbWebCheckinEnd = "webCheckinEnd";
  static final dbMobileBarcodeType = "mobileBarcodeType";

  String code, name, shortName, mobileBarcodeType;
  int webCheckinEnabled, webCheckinStart, webCheckinEnd;

  City({
    @required this.code,
    @required this.name,
    @required this.shortName,
    @required this.webCheckinEnabled,
    @required this.webCheckinStart,
    @required this.webCheckinEnd,
    @required this.mobileBarcodeType,
  });

  City.fromMap(Map<String, dynamic> map)
      : this(
          code: map[dbCode],
          name: map[dbName],
          shortName: map[dbShortName],
          webCheckinEnabled: map[dbWebCheckinEnabled],
          webCheckinStart: map[dbWebCheckinStart],
          webCheckinEnd: map[dbWebCheckinEnd],
          mobileBarcodeType: map[dbMobileBarcodeType],
        );

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      dbCode: code,
      dbName: name,
      dbName: shortName,
      dbWebCheckinEnabled: webCheckinEnabled,
      dbWebCheckinStart: webCheckinStart,
      dbWebCheckinEnd: webCheckinEnd,
      dbMobileBarcodeType: mobileBarcodeType,
    };
  }

  City.fromJson(Map<String, dynamic> json) {
    code = json['cityCode'];
    name = json['airportName'];
    shortName = json['shortAirportName'];
    webCheckinEnabled = (json['webCheckinEnabled'] == true || json['webCheckinEnabled'] == 'true')  ? 1 : 0;
    webCheckinStart = json['webCheckinStart'];
    webCheckinEnd = json['webCheckinEnd'];
    mobileBarcodeType = json['mobileBarcodeType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cityCode'] = this.code;
    data['airportName'] = this.name;
    data['shortAirportName'] = this.shortName;
    data['webCheckinEnabled'] = this.webCheckinEnabled == 1 ? 'true' : 'false';
    data['webCheckinStart'] = this.webCheckinStart;
    data['webCheckinEnd'] = this.webCheckinEnd;
    data['mobileBarcodeType'] = this.mobileBarcodeType;
    return data;
  }
}
