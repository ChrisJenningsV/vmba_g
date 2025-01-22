import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/v3pages/v3Theme.dart';
import '../components/showDialog.dart';
import '../components/trText.dart';
import '../components/vidButtons.dart';
import '../data/globals.dart';
import '../data/smartApi.dart';
import '../flightSearch/widgets/citylist.dart';
import '../flightSearch/widgets/journey.dart';
import '../utilities/helper.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/appBarWidget.dart';
import '../v3pages/controls/V3Constants.dart';


class FlightStatusPageWidget extends StatefulWidget {
  FlightStatusPageWidget();
  // : super(key: key);

  FlightStatusPageWidgetState createState() =>
      FlightStatusPageWidgetState();
}

class FlightStatusPageWidgetState extends State<FlightStatusPageWidget>  with TickerProviderStateMixin {
  late bool _loadingInProgress;
  late bool _showResults;

  TabController? _tabViewController ;

  @override void initState() {
    _loadingInProgress = true;
    _showResults = false;
    gblSearchParams.searchDestination = 'Select Destination';
    gblSearchParams.searchOrigin = 'Select Origin';
    gblOrigin = '';
    gblDestination ='';

    loadData();
  }


  @override
  Widget build(BuildContext context) {
    return

      new Scaffold(
        backgroundColor: Colors.grey.shade50, //v2PageBackgroundColor(),
        appBar: appBar(context, _showResults ? 'Flight Status Results' : 'Flight Status Search', PageEnum.editPax,
          //imageName: gblSettings.wantPageImages ? widget.formParams.formName : '',
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                if( _showResults ){
                  _showResults = false;
                  setState(() {

                  });
                } else {
                  Navigator.pop(context);
                }
              },
            )
          ],
        ),
        extendBodyBehindAppBar: gblSettings.wantPageImages,
        //endDrawer: DrawerMenu(),
        body: _body(),
      );
  }

  Widget _body() {
    if (_loadingInProgress) {
      return getProgressMessage('Loading...', '');
    }
    if( gblError != ''){

    }
    if( _showResults){
      return getResults();
    }

/*
    List<FlightStatus>? fs;
    var set;
    var sorted;
    if( gblFlightStatuss != null && gblFlightStatuss!.flights.length > 0 ){
      set = Set<String>();
      fs = gblFlightStatuss!.flights.where((element) => set.add(element.departureAirport)).toList();
      sorted = set.toList();
      sorted.sort();
    }
*/
    //List<FlightStatus>? sorted =  gblFlightStatuss!.getSortedList();
    return Container(
      color: Colors.white,
      child: Column(
      children: [
        Image.network('${gblSettings.gblServerFiles}/pageImages/flightStatus.png',
            errorBuilder: (BuildContext context, Object obj,
                StackTrace? stackTrace) {
              return Text('', style: TextStyle(color: Colors.red));
            }
        ), //
        DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const TabBar(tabs: [
                Tab(child: Text("Route",style: TextStyle(color: Colors.black87),), ),
                Tab(child: Text("Flight No",style: TextStyle(color: Colors.grey),), ),
              ]),
              SizedBox(
                //Add this to give height
                height: MediaQuery.of(context).size.height * 0.50,
                child: TabBarView(children: [
                  getRouteView(),
                  getFltNoView(),
                ]),
              ),
            ],
          ),
        ),
      ],
    )
    );

  }

  Widget getResults(){

    var set = Set<String>();
    var fs = gblFlightStatuss!.flights.where((element) => element.departureAirport == gblOrigin && element.schArrivalAirport == gblDestination ).toList();
    var sorted = fs.toList();
    //sorted.sort();


    return Container(
      padding: EdgeInsets.all(0),
        child:
         ListView.builder(
          //padding: EdgeInsets.all(0),
          //physics:AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: sorted == null ? 0 : sorted.length ,
            itemBuilder: (BuildContext context, i) {


      return new ListTile(
        //minVerticalPadding: 0,
//        tileColor: Colors.white ,
          contentPadding: EdgeInsets.all(0),
          dense: false,
          visualDensity: VisualDensity(vertical: -2),
          title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (i==0) ?  getTitle()
                    : Container(),
                getFlight(sorted[i], i),
               // Padding(padding: EdgeInsets.all(3) ),
              ]
          ),
          onTap: () {
            //Navigator.pop(context, '${routes![i]}');
          });
    }
    )
        ) ;
  }


  Widget getFlight(FlightStatus fs, int index ){
    String status = '';
    if(fs.arrivalStatus == 'As Scheduled'){
      status = fs.departureStatus;
    } else {
      status = fs.arrivalStatus;
    }

    List<Widget> fltList = [];
    fltList.add(Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

        VTitleText('$index ${fs.flightCode}', size: TextSize.large,)
    ]));
    fltList.add(Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text('${fs.schDepartureTime} -  ${fs.schArrivalTime}'),
    ]));

    fltList.add(Divider(color: Colors.black54, thickness: 1,));

    Color clr = Colors.green;
    if( status.contains('Sched')){
      clr = Colors.black54;
    } else if( status.contains('Exp')){
      clr = Colors.blue;
    } else if( status.contains('Can')){
      clr = Colors.red;
    }
    fltList.add(Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$status', style: TextStyle(color: clr, fontWeight: FontWeight.bold),),
      ],
    ));


    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          //borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border(
            top: BorderSide(color: Colors.grey, width: 1),
            left: BorderSide(color: Colors.grey, width: 1),
            right: BorderSide(color: Colors.grey, width: 1),
            bottom: BorderSide(color: Colors.grey, width: 1),
          ),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
            children: fltList)
    );
  }

  Widget getTitle() {
    return Container(
        color: Colors.black12,
        padding: EdgeInsets.all(5),
        child: Column(
          
        children: [
        Row(children: [Text('From: ${cityCodetoAirport(gblOrigin)}', style: TextStyle(color: Colors.black87),)]),
        Row(children: [Text('To: ${cityCodetoAirport(gblDestination)}', style: TextStyle(color: Colors.black87),)])
      ])
    );
  }

  Widget getRouteView(){
    return Container(
      padding: EdgeInsets.all(10),
        child: Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        new GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CitiesScreen(isFlightStatus: true)),
            );
            // print('$result');
            _handleDeptureSelectionChanged('$result');
          },
          child: getFlyFrom(context, 'Departs')
        ),
        new Padding(
          padding: EdgeInsets.only(bottom: 5),
        ),
        new GestureDetector(
          onTap: () async {
            //departureCode == 'null' || departureCode == ''
            gblSearchParams.searchOriginCode == 'null' || gblSearchParams.searchOriginCode == ''
                ? print('Pick departure city first')
                : await arrivalSelection(context);
          },
          child: getFlyTo(context, setState, 'Arrives', false),
        ),
        Padding(padding: EdgeInsets.all(15)),
        vidWideActionButton(context,'Find Flights',
            disabled: (gblDestination == '' || gblOrigin == '') ? true : false,
            _onPressed,
            icon: Icons.check,
            offset: 0 ),
      ],
    ));
  }
  void _onPressed(BuildContext context, dynamic p) {
      if( gblDestination != '' && gblOrigin != '') {
        _showResults = true;
        setState(() {

        });
      }
  }
  Future arrivalSelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CitiesScreen(filterByCitiesCode: gblSearchParams.searchOriginCode, isFlightStatus: true)),
    );
    _handleArrivalSelectionChanged('$result');
  }
  void _handleArrivalSelectionChanged(String newValue) {
    if (newValue != null && newValue != "null") {

      gblSearchParams.searchDestinationCode = newValue.split('|')[0];
      gblDestination = gblSearchParams.searchDestinationCode;
      gblSearchParams.searchDestination = newValue.split('|')[1];

      setState(() {});
    }
  }
  void _handleDeptureSelectionChanged(String newValue) {
    if (newValue != "null") {
      gblSearchParams.searchOriginCode = newValue.split('|')[0];
      gblOrigin = gblSearchParams.searchOriginCode;
      gblSearchParams.searchOrigin = newValue.split('|')[1];

      // clear selected ar
      gblDestination = '';
      gblSearchParams.searchDestination = 'Select Destination';

      setState(() {
//        widget.onChanged!(route);

      });
    }
  }
  Widget getFltNoView(){
    return Text("FltNo Body");
  }

  Future<void> loadData() async {
    String data = '';
    gblError = '';
    try {
      String reply = await callSmartApi('GETFLIGHTSTATUS', data);
      Map<String, dynamic> map = json.decode(reply);
      gblFlightStatuss = new FlightStatuss.fromJson(map);

      _loadingInProgress = false;
      setState(() {

      });
    } catch(e) {
      _loadingInProgress = false;
      setState(() {

      });
      showVidDialog(context, 'Error', e.toString(), type: DialogType.Error);
    }
  }


}


class FlightStatuss {

  List<FlightStatus> flights = [];

  FlightStatuss.fromJson(Map<String, dynamic> json) {
    if( json['Flights'] != null ) {
      json = json['Flights'];
      if (json['Flight'] != null) {
        flights = [];
        // new List<Itin>();
        if (json['Flight'] is List) {
          json['Flight'].forEach((v) {
            flights.add(new FlightStatus.fromJson(v));
          });
        } else {
          flights.add(new FlightStatus.fromJson(json['Flight']));
        }
      } else {
        flights = [];
      }
    }
  }

  List<String>? getSortedDestList(String departCityCode){
    Set<String> set;
    var sorted;
    if( gblFlightStatuss != null && gblFlightStatuss!.flights.length > 0 ){
      set = Set<String>();
      gblFlightStatuss!.flights.forEach((element) {
        if( element.departureAirport == departCityCode && element.schArrivalAirport != departCityCode){
          set.add(element.schArrivalAirport);
        }
      });
      sorted = set.toList();
      sorted!.sort();
      // fs.sort();
    }
    return sorted;
  }

  List<String>? getSortedList() {
    List<FlightStatus>? fs;
    Set<String> set;
    var sorted;
    if( gblFlightStatuss != null && gblFlightStatuss!.flights.length > 0 ){
      set = Set<String>();
      fs = gblFlightStatuss!.flights.where((element) => set.add(element.departureAirport)).toList();
      sorted = set.toList();
      sorted!.sort();
     // fs.sort();
    }
    return sorted;
  }
}

class FlightStatus {
  String airlineCode = '';
  String arrivalStatus = '';
  String departureAirport = '';
  String departureAirportName = '';
  String depdiff = '';
  String departureStatus = '';
  String flightCode = '';
  String flightNumber = '';
  String schArrivalAirport = '';
  String schArrivalAirportName = '';
  String schArrivalTime = '';
  String schDepartureTime = '';
  String schdeptime = '';
  String serviceTypeCode = '';
  String suffix = '';



  FlightStatus.fromJson(Map<String, dynamic> json) {
    if( json['Airline'] != null) airlineCode = json['Airline'];
    if( json['ArrFlightStatus'] != null) arrivalStatus = json['ArrFlightStatus'];
    if( json['DepartureAirport'] != null) departureAirport = json['DepartureAirport'];
    if( json['DepartureAirportName'] != null) departureAirportName = json['DepartureAirportName'];
    if( json['depdiff'] != null) depdiff = json['depdiff'];
    if( json['DepFlightStatus'] != null) departureStatus = json['DepFlightStatus'];
    if( json['FlightCode'] != null) flightCode = json['FlightCode'];
    if( json['FlightNumber'] != null) flightNumber = json['FlightNumber'];
    if( json['SchArrivalAirport'] != null) schArrivalAirport = json['SchArrivalAirport'];
    if( json['SchArrivalAirportName'] != null) schArrivalAirportName = json['SchArrivalAirportName'];
    if( json['SchArrivalTime'] != null) schArrivalTime = json['SchArrivalTime'];
    if( json['SchDepartureTime'] != null) schDepartureTime = json['SchDepartureTime'];
    if( json['schdeptime'] != null) schdeptime = json['schdeptime'];
    if( json['ServiceTypeCode'] != null) serviceTypeCode = json['ServiceTypeCode'];
    if( json['Suffix'] != null) suffix = json['Suffix'];
  }
}

