import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vmba/flightSearch/widgets/citylist.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

import '../../Helpers/settingsHelper.dart';
import '../../functions/text.dart';
import '../../utilities/helper.dart';

class SelectedRoute {
  String departure;
  String arrival;

  SelectedRoute(this.departure, this.arrival);
}

class SelectJourneyWidget extends StatefulWidget {
  SelectJourneyWidget({Key key= const Key("selj_key"), this.onChanged}) : super(key: key);

  final ValueChanged<SelectedRoute>? onChanged;

  _SelectJourneyWidgetState createState() => _SelectJourneyWidgetState();
}

class _SelectJourneyWidgetState extends State<SelectJourneyWidget> {

  late SelectedRoute route;

  @override
  initState() {
    super.initState();
    route = new SelectedRoute('', '');
    gblSearchParams.initAirports();

  }

  void _handleDeptureSelectionChanged(String newValue) {
    if (newValue != "null") {
      setState(() {

        gblSearchParams.searchOriginCode = newValue.split('|')[0];
        gblOrigin = gblSearchParams.searchOriginCode;
        gblSearchParams.searchOrigin = newValue.split('|')[1];
        gblSearchParams.searchDestination = translate('Select arrival airport');
        gblSearchParams.searchDestinationCode = '';
        route.departure = gblSearchParams.searchOriginCode;
        route.arrival = gblSearchParams.searchDestinationCode;

        gblFlightPrices = null;
        logit('clear FlightPrices');
        widget.onChanged!(route);
      });
    }
  }

  void _handleArrivalSelectionChanged(String newValue) {
    if (newValue != null && newValue != "null") {
      setState(() {

        gblSearchParams.searchDestinationCode = newValue.split('|')[0];
        gblDestination = gblSearchParams.searchDestinationCode;
        gblSearchParams.searchDestination = newValue.split('|')[1];
        route.departure = gblSearchParams.searchOriginCode;
        route.arrival = gblSearchParams.searchDestinationCode;

        widget.onChanged!(route);
        logit('clear FlightPrices');
        gblFlightPrices = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    list.add( GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CitiesScreen()),
                );
                // print('$result');
                _handleDeptureSelectionChanged('$result');
              },
              child: getFlyFrom(context, 'Fly from'),
            ),);

            if( gblSettings.homePageStyle == 'V3') {
              list.add(Divider(color: Colors.grey, height: 5, thickness: 1.0, ),);
            } else {
              list.add(Padding(padding: EdgeInsets.only(bottom: 5)));
            }
            list.add( GestureDetector(
              onTap: () async {
                //departureCode == 'null' || departureCode == ''
                gblSearchParams.searchOriginCode == 'null' ||
                    gblSearchParams.searchOriginCode == ''
                    ? print('Pick departure city first')
                    : await arrivalSelection(context);
              },
              child: getFlyTo(context, setState, 'Fly to', true),
            ));

            if( wantHomePageV3()){
              return Container(
                //color: Colors.red,
                  child: Stack(
                      children: [
                        Column(
                            children: list
                        ),
                        Positioned(
                            top: 20,
                            left: 3 * MediaQuery
                                .sizeOf(context)
                                .width / 4,
                            child: Container(
                                width: 35,
                                height: 35,
                                color: Colors.white,
                                child: IconButton(icon: Icon(
                              Icons.sync, color: Colors.grey, size: 35,),
                              onPressed: () {
                                var dest = gblSearchParams.searchOrigin;
                                var org = gblSearchParams.searchDestination;
                                var destCode = gblSearchParams.searchOriginCode;
                                if( !dest.contains('Select') && !org.contains('Select')){
                                    gblSearchParams.searchOrigin =
                                        gblSearchParams.searchDestination;
                                    gblSearchParams.searchOriginCode =
                                        gblSearchParams.searchDestinationCode;
                                    gblSearchParams.searchDestinationCode =
                                        destCode;
                                    gblSearchParams.searchDestination = dest;
                                    gblDestination = dest;
                                    gblOrigin = gblSearchParams.searchOrigin;
                                    route.departure = gblSearchParams.searchOriginCode;
                                    route.arrival = gblSearchParams.searchDestinationCode;
                                    widget.onChanged!(route);
                                    setState(() {});
                                  }
                                }
                                ,)),)
                      ]));
            } else {
              return Container(
                //color: Colors.red,
                  child:
                        Column(
                            children: list
                        ));
            }
  }




  Future arrivalSelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CitiesScreen(
                  filterByCitiesCode: gblSearchParams.searchOriginCode)),
    );
    _handleArrivalSelectionChanged('$result');
  }

}
Widget _getAirportText(BuildContext context, String airportName, String code, bool bIsWide, {bool bold = false}) {
  Color c;
  FontWeight fw;
  double? fSize;
  double screenWidth = MediaQuery
      .of(context)
      .size
      .width;

  if (screenWidth < 380 && airportName.length > 20) {
    fSize = 14.0;
  } else {
    fSize = 18.0;
  }
  if (code == '') {
    c = Colors.grey;
    fw = FontWeight.w300;
  } else {
    c = Colors.black;
    fw = FontWeight.w400;
  }
  if (bold) fw = FontWeight.bold;

  double width = MediaQuery.of(context).size.width - 50;
  if( !bIsWide) width = width/2;

  return Container(
//      width: width,
      child:
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            wantHomePageV3() ? v2SearchValueText(translate(airportName), narrowField: !bIsWide) :
            TrText(
                translate(airportName),
                noTrans: true,
                style: TextStyle(
                    fontWeight: fw,
                    color: c,
                    fontSize: fSize)),
            Icon(Icons.keyboard_arrow_down_outlined)
          ])
    //)
  );
  //,
  //fontSize: fSize)
}

  Widget getFlyTo(BuildContext context, void Function(void Function()) setState, String title, bool flightSearchPage, {bool bWantWide = true} ) {

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //(gblSettings.wantCitySwap && departureCode.isNotEmpty && arrivalCode.isNotEmpty) ?
        (wantHomePageV3() == false &&  gblSettings.wantCitySwap && gblSearchParams.searchOriginCode.isNotEmpty &&
            gblSearchParams.searchDestinationCode.isNotEmpty && flightSearchPage) ?
        Row(children: [
          v2Label(title),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: Icon(Icons.import_export),
            color: Colors.blueGrey,
            tooltip: translate('Swap Origin and Destination'),
            onPressed: () {
                var dest = gblSearchParams.searchOrigin;
                var destCode = gblSearchParams.searchOriginCode;
                gblSearchParams.searchOrigin = gblSearchParams.searchDestination;
                gblSearchParams.searchOriginCode = gblSearchParams.searchDestinationCode;
                gblSearchParams.searchDestinationCode = destCode;
                gblSearchParams.searchDestination = dest;
              setState(() {
              });
            },)
        ],)
            : new TrText(title,
            style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
                color: v2LabelColor())),
        //_getAirportText(arrivalAirport, arrivalCode),
        _getAirportText(context, gblSearchParams.searchDestination, gblSearchParams.searchDestinationCode,bWantWide),
        new Divider(
          height: 0.0,
        ),
      ],
    );
  }

  Widget getFlyFrom(BuildContext context, String title, {bool bWantWide = true, bool bold = false} ) {
      return new Column(
          mainAxisSize: MainAxisSize.max,
        // mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
              v2Label(title),
            //_getAirportText(departureAirport, departureCode),
            _getAirportText(context, gblSearchParams.searchOrigin, gblSearchParams.searchOriginCode, bWantWide, bold: bold),
            new Divider(
              height: 0.0,
            ),
          ]);
  }


Future<String> loadAsset() async {
  return await rootBundle.loadString('lib/assets/data/testdata.json');
}

Widget showAirport(String fullName){
  if( fullName.contains('(')) {
    String airport = fullName.split('(')[0];
    String code = fullName.split('(')[1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(translate(airport.trim()), textScaleFactor: 1.5,
          style: TextStyle(fontWeight: FontWeight.bold),),
        Padding(padding: EdgeInsets.only(left: 5)),
        Text(code.replaceAll(')', ''),),
      ],
    );
  } else {
    return Text(fullName);
  }
}
