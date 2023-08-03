
import 'package:meta/meta.dart';

class RoutesDB {
  static final dbName = "org";
  static final dbValue = "dest";

  String org, dest;
  //int id;

  RoutesDB({
    required this.org,
    required this.dest,
  });

  RoutesDB.fromMap(Map<String, dynamic> map)
      : this(
          org: map[dbName],
          dest: map[dbValue],
        );

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      dbName: org,
      dbValue: dest,
    };
  }
}

class RoutesModel {
  List<Routes> routes = List.from([Routes()]);

  RoutesModel();

  RoutesModel.fromJson(Map<String, dynamic> json) {
    if (json['Routes'] != null) {
      routes = [];
      // new List<Routes>();
      json['Routes'].forEach((v) {
        routes.add(new Routes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.routes != null) {
      data['Routes'] = this.routes.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Routes {
  Airport departure = Airport();
  List<Airport> destinations = List.from([Airport()]);

  Routes();

  Routes.fromJson(Map<String, dynamic> json) {
    if( json['departure'] != null)departure = Airport.fromJson(json['departure']);
    if (json['destinations'] != null) {
      destinations = [];
      // new List<Airport>();
      json['destinations'].forEach((v) {
        destinations.add(new Airport.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.departure != null) {
      data['departure'] = this.departure.toJson();
    }
    if (this.destinations != null) {
      data['destinations'] = this.destinations.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Airport {
  String airportCode='';
  String airportName='';
  double latitude =0;
  double longitude=0;
  bool direct=true;

  Airport();

  Airport.fromJson(Map<String, dynamic> json) {
    airportCode = json['airportCode'];
    airportName = json['airportName'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    direct = json['direct'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['airportCode'] = this.airportCode;
    data['airportName'] = this.airportName;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['direct'] = this.direct;
    return data;
  }
}
