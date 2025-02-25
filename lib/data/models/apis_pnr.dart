
class DatabaseRecord {
  static final dbRloc = "rloc";
  static final dbData = "data";
  static final dbDelete = "deleteRecord";

  String rloc, data;
  int delete;

  DatabaseRecord({
    required this.rloc,
    required this.data,
    required this.delete,
  });

  DatabaseRecord.fromMap(Map<String, dynamic> map)
      : this(
          rloc: map[dbRloc],
          data: map[dbData],
          delete: map[dbDelete],
        );

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      dbRloc: rloc,
      dbData: data,
      dbDelete: delete,
    };
  }
}

class ApisPnrStatusModel {
  Xml? xml;

  ApisPnrStatusModel({this.xml});

  ApisPnrStatusModel.fromJson(Map<String, dynamic> json) {
    xml = json['xml'] != null ? new Xml.fromJson(json['xml']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xml != null) {
      data['xml'] = this.xml?.toJson();
    }
    return data;
  }

  bool apisRequired(int journey) {
    //print(apisPnrStatus);
    if ( xml != null && xml!.pnrApis.flights != null &&
        xml!.pnrApis.flights!.flight[journey].apisrequired == 'True') {
      return true;
    } else {
      return false;
    }
  }

  bool apisInfoEntered(int journey, int passenger) {
    bool apisentered;
    apisentered = xml!.pnrApis.flights!.flight[journey].passengers!.passenger
            .firstWhere((pax) => pax.paxno == passenger.toString())
            .apisentered
            .toLowerCase() ==
        'true';
    if (apisentered) {
      return true;
    } else {
      return false;
    }
  }

  bool apisInfoEnteredAll(int journey) {
    if (xml!.pnrApis.flights!.flight[journey].passengers!.passenger
            .where((pax) => pax.apisentered.toLowerCase() == 'false')
            .length ==
        0) {
      return true;
    } else {
      return false;
    }
  }
}

class Xml {
  PnrApis pnrApis = PnrApis(pnr: '');

  Xml({required this.pnrApis});

  Xml.fromJson(Map<String, dynamic> json) {
    if( json['pnr_apis'] != null) {
      pnrApis = PnrApis.fromJson(json['pnr_apis']    );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    //if (this.pnrApis != null) {
      data['pnr_apis'] = this.pnrApis.toJson();
    //}
    return data;
  }
}

class PnrApis {
  String pnr='';
  Flights? flights;

  PnrApis({required this.pnr, this.flights});

  PnrApis.fromJson(Map<String, dynamic> json) {
    pnr = json['pnr'];
    flights =
        json['flights'] != null ? new Flights.fromJson(json['flights']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pnr'] = this.pnr;
    if (this.flights != null) {
      data['flights'] = this.flights!.toJson();
    }
    return data;
  }
}

class Flights {
  List<Flight> flight = [];

  Flights({this.flight= const[]});

  Flights.fromJson(Map<String, dynamic> json) {
    if (json['flight'] != null) {
      flight = [];
      //new List<Flight>();
      if (json['flight'] is List) {
        json['flight'].forEach((v) {
          flight.add(new Flight.fromJson(v));
        });
      } else {
        flight.add(new Flight.fromJson(json['flight']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
//    if (this.flight != null) {
      data['flight'] = this.flight.map((v) => v.toJson()).toList();
  //  }
    return data;
  }
}

class Flight {
  String line = '';
  String fltno = '';
  String fltdate = '';
  String depart ='';
  String arrive = '';
  String apisrequired = '';
  String apiscountries = '';
  Passengers? passengers;

  Flight(
      {this.line ='',
      this.fltno ='',
      this.fltdate ='',
      this.depart ='',
      this.arrive ='',
      this.apisrequired ='',
      this.apiscountries ='',
      this.passengers });

  Flight.fromJson(Map<String, dynamic> json) {
    line = json['line'];
    fltno = json['fltno'];
    fltdate = json['fltdate'];
    depart = json['depart'];
    arrive = json['arrive'];
    apisrequired = json['apisrequired'];
    apiscountries = json['apiscountries'];
    passengers = json['passengers'] != null
        ? new Passengers.fromJson(json['passengers'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['line'] = this.line;
    data['fltno'] = this.fltno;
    data['fltdate'] = this.fltdate;
    data['depart'] = this.depart;
    data['arrive'] = this.arrive;
    data['apisrequired'] = this.apisrequired;
    data['apiscountries'] = this.apiscountries;
    final passengers = this.passengers;
    if (passengers != null) {
      data['passengers'] = passengers.toJson();
    }
    return data;
  }
}

class Passengers {
   List<Passenger> passenger = [];

   Passengers({this.passenger = const []});

  Passengers.fromJson(Map<String, dynamic> json) {
    if (json['passenger'] != null) {
      //passenger = [];
      //new List<Passenger>();

      if (json['passenger'] is List) {
        json['passenger'].forEach((v) {
          passenger.add(new Passenger.fromJson(v));
        });
      } else {
        passenger.add(new Passenger.fromJson(json['passenger']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    //if (this.passenger != null) {
      data['passenger'] = this.passenger.map((v) => v.toJson()).toList();
    //}
    return data;
  }
}

class Passenger {
  String paxno = '';
  String apisentered = '';

  Passenger({this.paxno = '', this.apisentered = ''});

  Passenger.fromJson(Map<String, dynamic> json) {
    paxno = json['paxno'];
    apisentered = json['apisentered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['paxno'] = this.paxno;
    data['apisentered'] = this.apisentered;
    return data;
  }
}
