import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/v3pages/v3Theme.dart';
import '../components/showDialog.dart';
import '../components/trText.dart';
import '../components/vidButtons.dart';
import '../data/globals.dart';
import '../data/CommsManager.dart';
import '../flightSearch/widgets/citylist.dart';
import '../flightSearch/widgets/journey.dart';
import '../menu/icons.dart';
import '../utilities/helper.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/appBarWidget.dart';
import '../v3pages/cards/v3FormFields.dart';
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
  String resultsFor = '';
  late TabController _controller;

//  TabController? _tabViewController ;

  @override void initState() {
    _loadingInProgress = true;
    _showResults = false;
    gblSearchParams.searchDestination = 'Select Destination';
    gblSearchParams.searchOrigin = 'Select Origin';
    gblOrigin = '';
    gblDestination ='';
    _controller = TabController(length: 4, vsync: this);
  //  _tabViewController = new TabController(vsync: this, length: 2);
  /*  _tabViewController!.addListener(() {
      setState(() {
        _showResults = false;
      });
      logit("Selected Index: " + _tabViewController!.index.toString());
    });*/
    loadData();
  }


  @override
  Widget build(BuildContext context) {
    List <Widget> tabs = [];
    List <Widget> tabViews = [];

    tabs.add(TrText('Arrivals'));
    tabs.add(TrText('Departures'));
    tabs.add(TrText('Route'));
    tabs.add(TrText('Flight No'));

    tabViews.add(getRouteView('a'));
    tabViews.add(getRouteView('d'));
    tabViews.add(getRouteView('r'));
    tabViews.add(getFltNoView() );


    return

      new Scaffold(
        backgroundColor: Colors.grey.shade50, //v2PageBackgroundColor(),
        appBar: appBar(context, _showResults ? 'Flight Status' : 'Flight Status', PageEnum.editPax,
          //imageName: gblSettings.wantPageImages ? widget.formParams.formName : '',
          toolbarHeight: 60,
          bottom:  new PreferredSize(
            preferredSize: new Size.fromHeight(30.0),
            child: new Container(
              height: 20.0, child: TabBar(
                onTap: (index){
                  logit('OnTab i=$index');
                  _showResults = false;
                  setState(() {

                  });
                  //_controller!.animateTo((index ));
                },
                indicatorColor: gblSystemColors.tabUnderlineColor == null ? Colors.black : gblSystemColors.tabUnderlineColor,
                isScrollable: true,
                labelColor: gblSystemColors.headerTextColor,
                tabs: tabs,
                controller: _controller),
            ),
          ),
        actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                  Navigator.pop(context);
              },
            )
          ],
        ),
        extendBodyBehindAppBar: gblSettings.wantPageImages,
        //endDrawer: DrawerMenu(),
        body: TabBarView(
          controller: _controller,
          children: tabViews,
        ),
      );
  }



  Widget getResults(String brew ){

    var set = Set<String>();
    List<FlightStatus> fs;
    bool byRoute = true;
    int index = _controller!.index;
    if( index > 0 ) byRoute = false;


    if( brew == 'a' ) {
      fs = gblFlightStatuss!.flights.where((element) =>
      element.schArrivalAirport == gblOrigin).toList();
    } else if( brew == 'a' || brew == 'd') {
      fs = gblFlightStatuss!.flights.where((element) =>
      element.departureAirport == gblOrigin ).toList();
    } else if (brew == 'r') {
      fs = gblFlightStatuss!.flights.where((element) =>
          element.departureAirport == gblOrigin &&
          element.schArrivalAirport == gblDestination).toList();
    } else {
      String fltNo = _fltNoEditingController.text;
      gblFltNo = fltNo;
      fs = gblFlightStatuss!.flights.where((element) => element
          .flightNumber == fltNo).toList();

    }
    var sorted = fs.toList();
    //sorted.sort();

//    return  Text('results');
    List<DataRow> list = [];
    List <DataColumn> cols = [];
    cols.add(DataColumn( label: Container( color: Colors.black, child: Text('Flight',)),));
    if( brew == 'a') {
      cols.add(DataColumn(
        label: Container(color: Colors.black, child: Text('Departs',)),));
    }
    if(  brew == 'r') {
      cols.add(DataColumn(
        label: Container(color: Colors.black, child: Text('Route',)),));
    }
    cols.add(DataColumn( label: getnamedIcon('takeOff', color: Colors.white),));
    if( brew == 'd' ) {
      cols.add(DataColumn(
        label: Container(color: Colors.black, child: Text('Arrives',)),));
    }
    cols.add(DataColumn( label: getnamedIcon('landing', color: Colors.white),));
    cols.add(DataColumn( label: Container( color: Colors.black, child: Text('Status',)),));

    list = [];
    String dDate = '';
    fs.forEach((flight) {
      if(flight.departureAirportName == flight.schArrivalAirportName ) {
        // ignore
      } else {
        String depTime = '';
        String depDate = '';
        String arTime = '';
        String arDate = '';
        if (flight.schDepartureTime != '' &&
            flight.schDepartureTime.contains(' ')) {
          depTime = flight.schDepartureTime.split(' ')[0];
          depDate = flight.schDepartureTime.split(' ')[1].replaceAll('-', '');
        }
        if (flight.schArrivalTime != '' &&
            flight.schArrivalTime.contains(' ')) {
          arTime = flight.schArrivalTime.split(' ')[0];
          arDate = flight.schArrivalTime.split(' ')[1].replaceAll('-', '');
        }
        if( dDate == '') dDate = depDate;
        List<DataCell> cells = [];
        cells.add(DataCell(Text(flight.airlineCode + flight.flightNumber)));
        if( brew == 'a' ) {
          cells.add(DataCell(Text(flight.departureAirportName)));
        }
        if(  brew == 'r') {
          cells.add(DataCell(
            Column(
              children: [
                Text(flight.departureAirportName),
                Text(flight.schArrivalAirportName)
                ]
          ))
          );
        }
        if( dDate != depDate) {
          cells.add(DataCell(Column( children: [Text(depTime), Text(depDate)])));
        } else {
          cells.add(DataCell(Text(depTime)));
        }
        if( brew == 'd' ) {
          cells.add(DataCell(Text(flight.schArrivalAirportName)));
        }
        if( dDate != arDate) {
          cells.add(DataCell(Column( children: [Text(arTime), Text(arDate)])));
        } else {
          cells.add(DataCell(Text(arTime)));
        }
        String status = '';
        if(flight.arrivalStatus == 'As Scheduled'){
          status = flight.departureStatus;
        } else {
          status = flight.arrivalStatus;
        }
        Color clr = Colors.green;
        if( status.contains('Sched')){
          clr = Colors.black54;
        } else if( status.contains('Exp')){
          clr = Colors.blue;
        } else if( status.contains('Can')){
          clr = Colors.red;
        }
        cells.add(DataCell(Text(status,style: TextStyle(color: clr),)));
        list.add(DataRow(cells: cells));
      }
    });

    return Container(
        height: 500,
        padding: EdgeInsets.only(top: 10),
        child: SingleChildScrollView( child:
             DataTable(
               horizontalMargin: 5.0,
               columnSpacing: 10.0,
               headingRowHeight: 40,
              headingTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
             //dataRowMaxHeight: 40,
             headingRowColor:   WidgetStateColor.resolveWith((states) => Colors.black),
        columns:  cols,
    rows: list

    ))
    );


    return
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
          Text('${fs.departureAirportName} -  ${fs.schArrivalAirportName}'),
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
    int index = _controller!.index;

    List<Widget> list = [];
    if( index == 0 ) {
      list.add(Row(children: [Text('From: ${cityCodetoAirport(gblOrigin)}', style: TextStyle(color: Colors.black87),)]));
      list.add(Row(children: [Text('To: ${cityCodetoAirport(gblDestination)}', style: TextStyle(color: Colors.black87),)]));

    } else {
      list.add(Row(children: [Text('Flight No: $gblFltNo}', style: TextStyle(color: Colors.black87),)]));

    }

    return Container(
        color: Colors.black12,
        padding: EdgeInsets.all(5),
        child: Column(
          
        children: list
      )
    );
  }

  Widget getRouteView(String brew){

    List<Widget> searchBoxes = [];

    if( brew == 'd' || brew == 'r' || brew == 'a'){
      searchBoxes.add(GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CitiesScreen(isFlightStatus: true)),
            );
            // print('$result');
            _handleDeptureSelectionChanged('$result');
          },
          child: getFlyFrom(context, brew == 'a'? 'Arrives' : 'Departs', bWantWide: false, bold: true)
      ));
    }
    if( brew == 'r') {
      searchBoxes.add( Padding(padding: EdgeInsets.only(bottom: 5),));
          searchBoxes.add( GestureDetector(
          onTap: () async {
        //departureCode == 'null' || departureCode == ''
        gblSearchParams.searchOriginCode == 'null' || gblSearchParams.searchOriginCode == ''
            ? print('Pick departure city first')
            : await arrivalSelection(context);
      },
    child: getFlyTo(context, setState, 'Arrives', false, bWantWide: false),
    ));
    }

    bool disabled = (gblOrigin == '') ? true : false;

    if( brew == 'r') disabled = (gblDestination == '' || gblOrigin == '') ? true : false;

    return Container(
      padding: EdgeInsets.all(10),
        child: Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(top: 100)),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: searchBoxes
        ),
        Padding(padding: EdgeInsets.only(top: 25)),
        vidWideActionButton(context,'Check Status',
            disabled: disabled,
            _onPressed,
            icon: Icons.check,
            offset: 0, param1: brew ),
        _showResults ? getResults(brew): Container()
      ],
    ));
  }
  void _onPressed(BuildContext context, dynamic brew) {
    //gblDestination != '' &&
      if((  gblOrigin != '' ) || _fltNoEditingController.text != '') {
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
  TextEditingController _fltNoEditingController = new TextEditingController();

  Widget getFltNoView(){
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 100)),


            Text("Enter Flight number without airline code or leading 0's"),
            Padding(padding: EdgeInsets.only(left: 10, right: 10),
              child:V3TextFormField(
                translate('Flt No'),
                _fltNoEditingController,
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(padding: EdgeInsets.all(15)),
            vidWideActionButton(context,'Find Flights',
                disabled: (_fltNoEditingController.text == '') ? true : false,
                _onPressed,
                icon: Icons.check,
                offset: 0 ),
            _showResults ? getResults('f'): Container()
          ],
        ));

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

