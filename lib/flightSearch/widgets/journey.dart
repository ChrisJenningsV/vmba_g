import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vmba/flightSearch/widgets/citylist.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

class SelectedRoute {
  String departure;
  String arrival;

  SelectedRoute(this.departure, this.arrival);
}

class JourneyWidget extends StatefulWidget {
  JourneyWidget({Key key, this.onChanged}) : super(key: key);

  final ValueChanged<SelectedRoute> onChanged;

  _JourneyWidgetState createState() => _JourneyWidgetState();
}

class _JourneyWidgetState extends State<JourneyWidget> {
  String departureAirport = translate('Select departure airport');
  String departureCode = '';
  String arrivalAirport = translate('Select arrival airport');
  String arrivalCode = '';
  SelectedRoute route;

  @override
  initState() {
    super.initState();
    route = new SelectedRoute('', '');
  }

  void _handleDeptureSelectionChanged(String newValue) {
    if (newValue != "null") {
      setState(() {
        departureCode = newValue.split('|')[0];
        departureAirport = newValue.split('|')[1];
        arrivalAirport = translate('Select arrival airport');
        route.departure = departureCode;
        route.arrival = arrivalCode;
        widget.onChanged(route);
      });
    }
  }

  void _handleArrivalSelectionChanged(String newValue) {
    if (newValue != null && newValue != "null") {
      setState(() {
        arrivalCode = newValue.split('|')[0];
        arrivalAirport = newValue.split('|')[1];
        route.departure = departureCode;
        route.arrival = arrivalCode;
        widget.onChanged(route);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(

        //mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          new Column(
            //mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CitiesScreen()),
                    );
                    // print('$result');
                    _handleDeptureSelectionChanged('$result');
                  },
                  child: new Column(
                      // mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new TrText(
                          'Fly from',
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          ),
                        ),
                        _getAirportText(departureAirport, departureCode),
  /*                      new Text(
                          departureAirport,
                          style: new TextStyle(
                              fontWeight: FontWeight.w300,
                              color: departureCode == ''
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 18.0),
                        ),

   */
                        new Divider(
                          height: 0.0,
                        ),
                      ])),
              new Padding(
                padding: EdgeInsets.only(bottom: 5),
              ),
              new GestureDetector(
                  onTap: () async {
                    departureCode == 'null' || departureCode == ''
                        ? print('Pick departure city first')
                        : await arrivalSelection(context);
                  },
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ (gblSettings.wantCitySwap && departureCode.isNotEmpty && arrivalCode.isNotEmpty) ?
                        Row( children: [
                          TrText('Fly to',style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.import_export), color: Colors.blueGrey,
                            tooltip: translate('Swap Origin and Destination'),
                            onPressed: () {
                            setState(() {
                              var dest = departureAirport;
                              departureAirport =arrivalAirport;
                              arrivalAirport = dest;
                            });
                            },)
                        ],)
                        :new TrText('Fly to',
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15.0)),
                  _getAirportText(arrivalAirport,arrivalCode),
                      new Divider(
                        height: 0.0,
                      ),
                    ],
                  ))
            ],
          )
        ]);
  }

  Widget _getAirportText(String airportName, String code) {
    Color c;
    FontWeight fw;
    double fSize;
    double screenWidth = MediaQuery.of(context).size.width;

    if( screenWidth < 380 &&  airportName.length > 20 ) {
      fSize = 14.0;
    } else {
      fSize = 18.0;
    }
    if( code == '') {
      c = Colors.grey;
      fw = FontWeight.w300;
    } else {
      c = Colors.black;
      fw = FontWeight.w400;
    }

    return FittedBox(
        fit: BoxFit.contain,
        child: TrText(
      airportName,
      noTrans: true,
      style: new TextStyle(
          fontWeight: fw,
          color: c,
      fontSize: fSize))
    );
    //,
    //fontSize: fSize)
  }
  Future arrivalSelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CitiesScreen(filterByCitiesCode: departureCode)),
    );
    _handleArrivalSelectionChanged('$result');
  }
}

Future<String> loadAsset() async {
  return await rootBundle.loadString('lib/assets/data/testdata.json');
}

class CitiesScreen extends StatelessWidget {
  final String filterByCitiesCode;

  CitiesScreen({Key key, this.filterByCitiesCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        brightness: gblSystemColors.statusBar,
        backgroundColor: gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: new TrText('Flight Search',
            style: TextStyle(
                color:
                gblSystemColors.headerTextColor)),
      ),
      body: new Container(
          child: filterByCitiesCode != null
              ? Arrivals(departCityCode: filterByCitiesCode,
                )
              : Departures()),
    );
  }
}
