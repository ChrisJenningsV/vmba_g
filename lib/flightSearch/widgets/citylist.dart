import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vmba/data/repository.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

Future<List<Routes>> fetchCitylistData(http.Client client) async {
  try {
    final response = await rootBundle.loadString('lib/assets/data/cities.json');
    return compute(parseRouteData, response);
  } catch (e) {
    print(e);
    return null;
  }
}

// A function that will convert a response body into a List<Routes>
List<Routes> parseRouteData(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Routes>((json) => Routes.fromJson(json)).toList();
}

Future<List<String>> fetchDepartureCities() async {
  try {
    List<String> list;
    // ignore: await_only_futures
    list = await Repository.get().getAllDepartures();


    return list;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<List<String>> fetchDestinationCities(String departure) async {
  try {
    // ignore: await_only_futures
    List<String> list = await Repository.get().getDestinations(departure);
    list.toSet().toList().sort((a, b) => a.compareTo(b));

    return list;
  } catch (e) {
    print(e);
    return null;
  }
}

class Routes {
  final String org;
  final List<String> dest;

  Routes({
    this.org,
    this.dest,
  });

  Routes.fromMap(Map<String, dynamic> map)
      : this(
          org: map['org'],
          dest: map['dest'],
        );

  factory Routes.fromJson(Map<String, dynamic> parsedjson) {
    var destFromJson = parsedjson['dest'];
    List<String> destList = new List<String>.from(destFromJson);
    return Routes(
      org: parsedjson['org'],
      dest: destList,
    );
  }
}

//class Departures extends StatelessWidget {
class Departures extends StatefulWidget {
  final String title;

  Departures({Key key, this.title}) : super(key: key);
  @override
  _DeparturesState createState() => new _DeparturesState();
}

class _DeparturesState extends State<Departures> {
//  bool _loadingInProgress;
//  String _loadingMsg = 'Loading cities...';
  List<String> _cityData;

  @override
  void initState() {
    super.initState();
//    _loadingInProgress = true;
    _loadData();
  }
  Future _loadData() async {
    //Repository.get().getAllDepartures().then((cityData) {
    if( _cityData == null ) {
      _cityData = await Repository.get().getAllDepartures();
    }
     /* int i=0;
      while( i < 10 && cityData.length == 0) {
        // not finished - some bug in dart async stuff ??
        sleep(Duration(milliseconds:100));
        i = i+1;
      }
      _cityData = cityData;
*/

      if( _cityData.length > 0) {
        setState(() {
//          _loadingInProgress = false;
        });
      } else {
//        _loadingInProgress = true;
//        _loadingMsg = 'Reloading Cities...';
          setState(() {
        });
      }

  }
  @override
  Widget build(BuildContext context) {

    if (_cityData == null || _cityData.length==0) {
      return new Center(
          child: new ElevatedButton(onPressed: () => _loadData(),
            child: TrText("Load cities Failed, RETRY"),
            )
  /*      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TrText(_LoadingMsg),
            )
          ],
        ),*/

      );
    } else {
      return DepartureList(routes: _cityData);
    }
  }

  }
  /*  return new FutureBuilder<List<String>>(
      //future: fetchDepartureCities(),
      future:  Repository.get().getAllDepartures(),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        // cj new bit
        if( snapshot.hasData && snapshot.data.length > 0) {
          return DepartureList(routes: snapshot.data);
        } else {
          if(gbl_verbose) {
            if (snapshot.hasData) {
              var cs = snapshot.connectionState;
              print(".. loading departures - bad hasData " );
            } else {
              print(".. loading departures");
            }
          }
          return Center(child: CircularProgressIndicator());
        }

//        return snapshot.hasData
//            ? DepartureList(routes: snapshot.data)
//            : Center(child: CircularProgressIndicator());
      },
    );

   */



class DepartureList extends StatelessWidget {
  // final List<Routes> routes;
  final List<String> routes;

  DepartureList({Key key, this.routes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (gblVerbose) {print('build DepartureList len=${routes.length}');}
    return new ListView.builder(
        itemCount: routes == null ? 0 : routes.length,
        itemBuilder: (BuildContext context, i) {
          //return new ListTile(title: Text('${routes[i].org}'.split('|')[1],),
          return new ListTile(
              title: Text(
                '${routes[i]}'.split('|')[1],
              ),
              onTap: () {
                //Navigator.pop(context, '${routes[i].org}');
                Navigator.pop(context, '${routes[i]}');
              });
        });
  }
}

/*
class Arrivals extends StatelessWidget {
  final String title;
  final String departureCityCode;

  Arrivals({Key key, this.title, this.departureCityCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List<String>>(
      //future: fetchCitylistData(http.Client()),
      future: fetchDestinationCities(departureCityCode),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        if( snapshot.hasData ) {
          return ArrivalList(
            routes: snapshot.data,
            departureCityCode: departureCityCode,
          );
        } else {
          if(gbl_verbose) print("loading arrivals..");
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
*/
class Arrivals extends StatefulWidget {
  final String title;
  final String departCityCode;

  Arrivals({Key key, this.title,this.departCityCode}) : super(key: key);
  @override
  _ArrivalsState createState() => new _ArrivalsState();
}
class _ArrivalsState extends State<Arrivals> {
//  bool _loadingInProgress;
  String departCityCode;
//  String _loadingMsg = 'Loading arrivals...';
  List<String> _departCityData;

  @override
  void initState() {
    super.initState();
//    _loadingInProgress = true;
    departCityCode = widget.departCityCode;
    _loadData();
  }

  Future _loadData() async {
    //Repository.get().getAllDepartures().then((cityData) {
    if ( _departCityData == null ) {
      _departCityData = await Repository.get().getDestinations(departCityCode);
    }
    if( _departCityData.length > 0) {
      setState(() {
//        _loadingInProgress = false;
      });
    } else {
//      _loadingInProgress = true;
//      _loadingMsg = 'Reloading Cities...';
      setState(() {
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_departCityData == null || _departCityData.length == 0) {
      return new Center(
          child: new ElevatedButton(onPressed: () => _loadData(),
            child: TrText("Load cities Failed, RETRY"),
          )
        /*      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TrText(_LoadingMsg),
            )
          ],
        ),*/

      );
    } else {
      return ArrivalList(routes: _departCityData);
    }
  }
}
    class ArrivalList extends StatelessWidget {
  final List<String> routes;
  final String departureCityCode;

  ArrivalList({Key key, this.routes, this.departureCityCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (gblVerbose) {print('build ArrivalList len=${routes.length}');}
    return new ListView.builder(
        itemCount: routes == null ? 0 : routes.length,
        itemBuilder: (BuildContext context, i) {
          return new ListTile(
              title: Text(
                '${routes[i]}'.split('|')[1],
              ),
              onTap: () {
                Navigator.pop(context, '${routes[i]}');
              });
        });
  }
}
