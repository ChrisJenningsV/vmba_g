import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vmba/Managers/imageManager.dart';
import 'package:vmba/v3pages/v3Theme.dart';
import '../Helpers/settingsHelper.dart';
import '../components/showDialog.dart';
import '../components/trText.dart';
import '../components/vidButtons.dart';
import '../data/globals.dart';
import '../Managers/commsManager.dart';
import '../flightSearch/widgets/citylist.dart';
import '../flightSearch/widgets/journey.dart';
import '../menu/icons.dart';
import '../menu/menu.dart';
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
    gblCurPage = 'FLIGHTSTATUS';
    gblSearchParams.searchDestination = 'Select Destination';
    gblSearchParams.searchOrigin = 'Select Airport';

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
        backgroundColor: v2PageBackgroundColor(), // Colors.grey.shade50, //
        endDrawer: DrawerMenu(),
        appBar: appBar(context, _showResults ? 'Flight Status' : 'Flight Status', PageEnum.editPax,
          //imageName: gblSettings.wantPageImages ? widget.formParams.formName : '',
          toolbarHeight: 160,
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
                labelColor: Colors.black,
                tabs: tabs,
                controller: _controller),
            ),
          ),
/*
        actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                  Navigator.pop(context);
              },
            )
          ],
*/
        ),
        extendBodyBehindAppBar: false,
        //endDrawer: DrawerMenu(),
        body: ImageManager.getBodyWithBackground(
          gblCurPage,
          TabBarView(
          physics: NeverScrollableScrollPhysics(),
          //dragStartBehavior: DragStartBehavior.down,
          viewportFraction: 1.0,
          controller: _controller,
          children: tabViews,
        ),
        )
      );
  }

  List<DataRow> getRows(String brew) {
    List<DataRow> list = [];
  String dDate = '';
    List<FlightStatus> fs;
    bool byRoute = true;
    int index = _controller!.index;
    if( index > 0 ) byRoute = false;


    if( brew == 'a' ) {
      fs = gblFlightStatuss!.flights.where((element) =>
      element.schArrivalAirport == gblOrigin).toList();
    } else if( brew == 'd') {
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
      cells.add( DataCell(Padding(padding: EdgeInsets.only(left: 10) , child: Text(flight.airlineCode + flight.flightNumber))));
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
      Color clr = Colors.green.shade200;
      if( status.contains('Sched')){
        clr = Colors.black54;
      } else if( status.contains('Exp')){
        clr = Colors.blue.shade200;
      } else if( status.contains('Can')){
        clr = Colors.red.shade200;
      }
      cells.add(DataCell(
        Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: clr,
            borderRadius:BorderRadius.circular(25.0),
          ),
          child: Text(status,)))
      );
      list.add(DataRow(cells: cells));
    }
  });
  return list;
}

  DataColumn getColDef( int colNo, String label , double width, {double? leftPad}){
    Widget txt = Text(label,);
    if( leftPad != null ){
      txt = Padding(padding: EdgeInsets.only(left: leftPad), child: Text(label));
    }

    return DataColumn(
      label: Container(
          width: width,
          color: colColor,
          child: txt),
    );
  }

  Color colColor = Colors.white;
  List <DataColumn> getCols(String brew){
    double width = MediaQuery.sizeOf(context).width;
    List <DataColumn> cols = [];

    // 20%
    double colWidth = width /5;
    cols.add(getColDef(1,'Flight', colWidth, leftPad: 10));


    if( brew == 'a') {
//      cols.add(DataColumn(label: Container(color: colColor, child: Text('Departs',)),));
      // 30%
      double colWidth = 2.5 * width /10;
      cols.add(getColDef(2,'Departs', colWidth,));
    }
    if(  brew == 'r') {
      cols.add(DataColumn(
        label: Container(color: colColor, child: Text('Route',)),));
    }
    cols.add(DataColumn( label: getNamedIcon('takeOff', color: Colors.black),));
    if( brew == 'd' ) {
      cols.add(DataColumn(
        label: Container(color: colColor, child: Text('Arrives',)),));
    }
    cols.add(DataColumn( label: getNamedIcon('landing', color: Colors.black),));
    cols.add(DataColumn( label: Container( color: colColor, child: Text('Status',)),));

    return cols;
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

    if( gblFlightStatuss == null ){
      return Container(
        height: 400,
        child: TrText('Loading...'),
      );
    }

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
    } else {
      searchBoxes.add(Padding(padding: EdgeInsets.only(left: 100)));
    }

    bool disabled = (gblOrigin == '') ? true : false;

    if( brew == 'r') disabled = (gblDestination == '' || gblOrigin == '') ? true : false;


    return
      ConstrainedBox(
          constraints: BoxConstraints.expand(
              width: MediaQuery.of(context).size.width
          ),
          child:
          SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child:
          Column(
              children: [
          Row(mainAxisAlignment: brew == 'a' ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
          children: searchBoxes),
          Container(
            margin: EdgeInsets.fromLTRB(5, 2, 5, 2),
            decoration: BoxDecoration(
                border: Border.all(
                 // color: Colors.red,
                ),
                borderRadius: BorderRadius.circular(10),
              boxShadow: [
              BoxShadow(
              color: Colors.grey,
              //  gblSystemColors.primaryHeaderColor.withOpacity(0.5), //Colors.blue.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 9), // changes position of shadow
            )],
              color: Colors.white
            ),
              child:
                DataTable(
                  columnSpacing: 0,
              headingTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//              headingRowColor:   WidgetStateColor.resolveWith((states) => Colors.red),
                dataRowColor: WidgetStateColor.resolveWith((states) => Colors.white),
              horizontalMargin: 0,
                    //columnSpacing: 5,
                    columns: getCols(brew) ,
                    rows: getRows(brew)
                )
              )
                ])
            )
      );
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
        height: 500,
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
            /*_showResults ? getResults('f'):*/ Container()
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

