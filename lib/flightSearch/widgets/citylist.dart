import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vmba/Helpers/settingsHelper.dart';
import 'package:vmba/calendar/calendarFunctions.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/v3pages/controls/V3Constants.dart';
import 'package:vmba/v3pages/v3Theme.dart';

import '../../data/models/cities.dart';
import '../../flightStatus/flightStatusPage.dart';
import '../../utilities/helper.dart';
import '../../v3pages/controls/V3AppBar.dart';

TextEditingController _searchEditingController =   TextEditingController();

Future<List<Routes>?> fetchCitylistData(http.Client client) async {
  try {
    final response = await rootBundle.loadString('lib/assets/data/cities.json');
    return compute(parseRouteData, response);
  } catch (e) {
    print(e.toString());
    return null;
  }
}

// A function that will convert a response body into a List<Routes>
List<Routes> parseRouteData(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Routes>((json) => Routes.fromJson(json)).toList();
}




Future<List<String>?> fetchDestinationCities(String departure) async {
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
    required this.org,
    required this.dest,
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
  bool isFlightStatus = false;

  Departures({Key key= const Key("deps_key"), this.title='', this.isFlightStatus = false}) : super(key: key);
  @override
  _DeparturesState createState() => new _DeparturesState();
}

class _DeparturesState extends State<Departures> {
//  bool _loadingInProgress;
//  String _loadingMsg = 'Loading cities...';
  List<String>? _cityData;

  @override
  void initState() {
    super.initState();
//    _loadingInProgress = true;
     _loadData(onComplete);
  }
  void  onComplete() {
    Timer(const Duration(milliseconds: 400), ()
    {
      setState(() {
        // _displayProcessingIndicator = false;
      });
    });

  }
  Future<List<String>?> fetchDepartureCities(void Function() onComplete) async {
    try {
      List<String>? list;
      // ignore: await_only_futures
      list = await Repository.get().getAllDepartures(onComplete);


      return list;
    } catch (e) {
      print(e);
      return null;
    }
  }
  Future _loadData(void Function() onComplete) async {
    if( gblSettings.useLogin2 && gblCityList != null) {
      // build routes
      // ABZ|Aberdeen (ABZ)
      _cityData = [];
      if( widget.isFlightStatus) {
        if( gblFlightStatuss!=null  ) {
          List<String>? sorted =  gblFlightStatuss!.getSortedList();
          sorted!.forEach((element) {
            _cityData!.add('${element}|${cityCodetoAirport(element)} (${element})');
          });
          }
      } else {
        gblCityList!.cities!.forEach((city) {
          _cityData!.add('${city.code}|${city.name} (${city.code})');
        });
      }
      return ;
    }


    //Repository.get().getAllDepartures().then((cityData) {
    if( _cityData == null ) {
      _cityData = await Repository.get().getAllDepartures(onComplete);
    }

    if (_cityData == null || _cityData!.length==0) {
      // delay
      Future.delayed(Duration(milliseconds: 100), () {
        if (_cityData == null || _cityData!.length == 0) {
          if( gblVerbose) print(" This line is execute after 100 ms - no cities");
          setState(() {          });
        } else {
          if( gblVerbose) print(" This line is execute after 100 ms - got cities");
          setState(() {          });
        }
      });
    }



  }
  @override
  Widget build(BuildContext context) {
  //logit('build departures');

    if (_cityData == null || _cityData!.length==0) {
      return new Center( child: TrText("Loading...")
         /* child: new ElevatedButton(onPressed: () => _loadData(),
            child: TrText("Load cities Failed, RETRY"),
            )*/
        );
    } else {
      return DepartureList(routes: _cityData);
    }


  }

  }






class DepartureList extends StatefulWidget {
  // final List<Routes> routes;

  DepartureList({ this.routes});

  final List<String>? routes;

  DepartureListState createState() =>
      DepartureListState();

}

class DepartureListState extends State<DepartureList> {

//  DepartureList({Key key, this.routes}) : super(key: key);
  List<String>? routes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    routes = widget.routes;
  }


  void filterCities(String filter){
    routes = [];
    if( widget.routes != null ) {
      logit('filter cities ${widget.routes!.length} found ');
    } else {
      logit('filter cities null found ');
    }
    _getRoutes(widget.routes)!.forEach((route) {
      String code = route.split('|')[0].toUpperCase();
      String name = route.split('|')[1].toUpperCase();

      if(code.startsWith(filter.toUpperCase()) || name.startsWith(filter.toUpperCase())){
        routes!.add(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (routes!.length == null) {
      logit('build DepartureList len=null');
    } else  {
      logit('build DepartureList len=${routes!.length}');
    }
//    if( _searchEditingController.text.isNotEmpty) {
      filterCities(_searchEditingController.text);
  //  }
    return
    /*
      SingleChildScrollView(
        physics:AlwaysScrollableScrollPhysics(),
        child: Container(
          height: 1000,
        child: Column(
        children: [
          */
          new ListView.builder(
              //physics:AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
          itemCount: routes == null ? 0 : routes!.length ,
          itemBuilder: (BuildContext context, i) {
/*
            return new ListTile(
              //dense: true,
                title: Text(
                translate('${routes![i]}'.split('|')[1]),
                ),
                onTap: () {
                  //Navigator.pop(context, '${routes[i].org}');
                  Navigator.pop(context, '${routes![i]}');
                });
*/
            return new ListTile(
              //minVerticalPadding: 0,
                dense: false,
                visualDensity: VisualDensity(vertical: -2),
                title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      i==0 ? Padding(padding: EdgeInsets.all(3) ): Container(),
                      Text(translate('${routes![i]}'.split('|')[1])),
                      Padding(padding: EdgeInsets.all(3) ),
                      /*wantHomePageV3() ?*/ V3CityDivider() /*: Container()*/,
                    ]
                ),
                onTap: () {
                  Navigator.pop(context, '${routes![i]}');
                });
          }
/*        })],
    )
        )

 */
      );
  }
}

class Arrivals extends StatefulWidget {
  final String title;
  final String departCityCode;
  bool isFlightStatus;

  Arrivals({Key key= const Key("arrvs_key"), this.title='',this.departCityCode='', this.isFlightStatus = false}) : super(key: key);
  @override
  _ArrivalsState createState() => new _ArrivalsState();
}
class _ArrivalsState extends State<Arrivals> {
//  bool _loadingInProgress;
  String departCityCode='';
//  String _loadingMsg = 'Loading arrivals...';
  List<String>? _departCityData;

  @override
  void initState() {
    super.initState();
//    _loadingInProgress = true;
    departCityCode = widget.departCityCode;
    _loadData();
  }

  Future _loadData() async {
    //Repository.get().getAllDepartures().then((cityData) {
    if( widget.isFlightStatus) {
      _departCityData = [];
      if( gblFlightStatuss!=null  ) {
        List<String>? sorted = gblFlightStatuss!.getSortedDestList(departCityCode);
        sorted!.forEach((element) {
          _departCityData!.add('${element}|${cityCodetoAirport(element)} (${element})');
        });
      }
      return;
    }

    if( gblSettings.useLogin2 && gblCityList != null) {
      // build routes
      // ABZ|Aberdeen (ABZ)
      if ( _departCityData == null || _departCityData == '') {
        _departCityData = [];
        gblCityList!.cities!.forEach((city) {
          if( city.code == departCityCode){
            city.destinations.forEach((cty) {
              String cityData = '${cty.code}|${cty.name} (${cty.code})';
              if( !_departCityData!.contains(cityData) ) {
                _departCityData!.add(cityData);
              }

            });
          }
        });
      }
      return ;
    }


    if ( _departCityData == null || _departCityData == '') {
      _departCityData = await Repository.get().getDestinations(departCityCode);
    }
    if (_departCityData == null || _departCityData!.length==0) {
      // delay
      Future.delayed(Duration(milliseconds: 100), () {
        if (_departCityData == null || _departCityData!.length == 0) {
          if( gblVerbose) print(" This line is execute after 100 ms - no cities");
          setState(() {          });
        } else {
          if( gblVerbose) print(" This line is execute after 100 ms - got cities");
          setState(() {          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //logit('build arr');
    if (_departCityData == null || _departCityData!.length == 0) {
      return new Center( child: TrText("Loading...")
    /* child: new ElevatedButton(onPressed: () => _loadData(),
            child: TrText("Load cities Failed, RETRY"),
            )*/

      );
    } else {
      return ArrivalList(routes: _departCityData);
    }
  }
}


 class ArrivalList extends StatefulWidget {
   final List<String>? routes;
   final String? departureCityCode;

   ArrivalList({Key key= const Key("arrlist_key"), this.routes, this.departureCityCode = null})
       : super(key: key);

   ArrivalListState createState() =>
       ArrivalListState();
 }

  class ArrivalListState extends State<ArrivalList> {

 // TextEditingController _fqtvTextEditingController =   TextEditingController();

  //  DepartureList({Key key, this.routes}) : super(key: key);
  List<String>? routes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    routes = widget.routes;
  }

  void filterCities(String filter){
    routes = [];
    _getRoutes(widget.routes)!.forEach((route) {
      String code = route.split('|')[0].toUpperCase();
      String name = route.split('|')[1].toUpperCase();

      if(code.startsWith(filter.toUpperCase()) || name.startsWith(filter.toUpperCase())){
        routes!.add(route);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    if(gblLogCities ) {logit('build ArrivalList len=${routes!.length}');}

//      if( _searchEditingController.text.isNotEmpty) {
        filterCities(_searchEditingController.text);
  //    }

    return
 /*     new ListView.separated(
          separatorBuilder: (context, index) => wantHomePageV3() ? V3Divider() : Container(),*/
        ListView.builder(
          shrinkWrap: true,
          itemCount: routes == null ? 0 : routes!.length ,
          itemBuilder: (BuildContext context, i) {
            return new ListTile(
                //minVerticalPadding: 0,
                dense: false,
                visualDensity: VisualDensity(vertical: -2),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  i==0 ? Padding(padding: EdgeInsets.all(3) ): Container(),
                  Text(translate('${routes![i]}'.split('|')[1])),
                  Padding(padding: EdgeInsets.all(3) ),
                  /*wantHomePageV3() ?*/ V3CityDivider() /*: Container()*/,
                ]
                ),
                onTap: () {
                  Navigator.pop(context, '${routes![i]}');
                });
          }
      );
  }

}

class CitiesScreen extends StatefulWidget {
  final String filterByCitiesCode;
  bool isFlightStatus = false;

  CitiesScreen({Key key= const Key("citysc_key"), this.filterByCitiesCode='', this.isFlightStatus = false}) : super(key: key);


  CitiesScreenState createState() => CitiesScreenState();
}

class CitiesScreenState  extends State<CitiesScreen> {

  List<String>? _cityData ;
  List<String>? routes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    _searchEditingController.text = '';
  }
  void onComplete() {
    Timer(const Duration(milliseconds: 400), ()
    {
      setState(() {
       // _displayProcessingIndicator = false;
      });
    });
  }
  Future _loadData() async {
    //Repository.get().getAllDepartures().then((cityData) {
    if (_cityData == null || _cityData!.length == 0) {
      _cityData = await Repository.get().getAllDepartures(onComplete);
    }

    if (_cityData == null || _cityData!.length == 0) {
      // delay
      for( var i  = 0; i< 10 ; i++ ) {
        Future.delayed(Duration(milliseconds: 200), () {
          if (_cityData == null || _cityData!.length == 0) {
            if (gblVerbose) print(
                " This line is execute after 100 ms - no cities");
            //setState(() {});
          } else {
            i = 10;
            if (gblVerbose) print(
                " This line is execute after 100 ms - got cities");
            setState(() {});
          }
        });
      }
    }
    routes = _cityData;
  }
  @override
  Widget build(BuildContext context) {
    Color fillColor = Colors.white.withOpacity(0.5);
    if( gblSystemColors.primaryHeaderColor == Colors.white ) {
      fillColor = Colors.grey.withOpacity(0.5);
    }
    return new Scaffold(
      appBar: new V3AppBar(
          //brightness: gblSystemColors.statusBar,
          PageEnum.chooseAirport,
          //backgroundColor: gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: TextFormField(
            style: TextStyle(color: gblSystemColors.headerTextColor), //color: Colors.white),
            decoration: InputDecoration(
              fillColor: fillColor,
              filled: true,
              counterText: '',
                prefixIcon: Icon(Icons.search),
              labelStyle: TextStyle(color: gblSystemColors.headerTextColor), // Colors.white),
              //    contentPadding:
              //      new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              labelText: translate('Start typing airport code or name'),
            ),

            controller: _searchEditingController,
            keyboardType: TextInputType.streetAddress,
            onChanged: (String value) {
              //filterCities(_searchEditingController.text);
              setState(() {

              });
            },
          ),

      ),
      body: new Container(
          child: (widget.filterByCitiesCode != null && widget.filterByCitiesCode != '')
              ? Arrivals(departCityCode: widget.filterByCitiesCode,isFlightStatus: widget.isFlightStatus
          )
              : Departures(isFlightStatus: widget.isFlightStatus)),
    );
  }

}
List<String>? _getRoutes(List<String>? routes ){
  List<String>? domRoutes = [];
  if( gblSelectedCurrency != null && gblSelectedCurrency != '' &&
      gblSettings.currencyLimitedToDomesticRoutes != null && gblSettings.currencyLimitedToDomesticRoutes != '' &&
      gblSettings.domesticCountryCode != null && gblSettings.domesticCountryCode != '' &&
      gblSettings.currencyLimitedToDomesticRoutes.contains(gblSelectedCurrency)){

    // filter to only domestic cities
    routes!.forEach((c) {
      if( isDomesticCity(c)){
        domRoutes.add(c);
      }
    });
    return domRoutes;
  }
  return routes;

}
