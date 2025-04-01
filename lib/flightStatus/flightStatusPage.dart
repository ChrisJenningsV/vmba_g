import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/Managers/imageManager.dart';
import 'package:vmba/functions/text.dart';
import 'package:vmba/v3pages/v3Theme.dart';
import '../Helpers/settingsHelper.dart';
import '../components/showDialog.dart';
import '../components/trText.dart';
import '../components/vidButtons.dart';
import '../data/globals.dart';
import '../Managers/commsManager.dart';
import '../flightSearch/widgets/citylist.dart';
import '../flightSearch/widgets/journey.dart';
import '../menu/menu.dart';
import '../utilities/helper.dart';
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
    return

      new Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: v2PageBackgroundColor(), // Colors.grey.shade50, //
        endDrawer: DrawerMenu(),
        appBar: appBar(context, _showResults ? 'Flight Status' : 'Flight Status', PageEnum.editPax , 'FLIGHTSTATUS'),
        extendBodyBehindAppBar: false,
        //endDrawer: DrawerMenu(),
        body: ImageManager.getBodyWithBackground(context,
          'FLIGHTSTATUS',
          _body()/*tabViews*/,
            null),
        );

  }

  Widget _body(){
    List <Widget> tabs = [];
    List <Widget> tabViews = [];

    tabs.add(Container( padding: EdgeInsets.only(top: 5), height: 25, color: Colors.transparent, child:titleText('Departures',)));
    tabs.add(Container(  padding: EdgeInsets.only(top: 5), height: 25, color: Colors.transparent, child:titleText('Arrivals')));
    tabs.add(Container(  padding: EdgeInsets.only(top: 5), height: 25,color: Colors.transparent, child:titleText('Route')));
    tabs.add(Container(  padding: EdgeInsets.only(top: 5), height: 25,color: Colors.transparent, child:titleText('Flight No')));

    tabViews.add(getRouteView('d'));
    tabViews.add(getRouteView('a'));
    tabViews.add(getRouteView('r'));
    tabViews.add(getFltNoView() );

    return Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            width: MediaQuery.sizeOf(context).width,
            color: Colors.black,
            padding: EdgeInsets.only(top: 5, bottom: 5),
            height: 40.0, child: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
                color: Colors.red,
              ),
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
          Container(
              height: MediaQuery.of(context).size.height -160,
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                //dragStartBehavior: DragStartBehavior.down,
                //  viewportFraction: 1.0,
                controller: _controller,
                children:  tabViews,
              )
          )
        ]);
  }

  List<DataRow> getRows(String brew) {
    List<DataRow> list = [];
  String dDate = '';
    List<FlightStatus> fs = [];
    bool byRoute = true;
    int index = _controller!.index;
    if( index > 0 ) byRoute = false;


    if( brew == 'a' ) {
      fs = gblFlightStatuss!.flights.where((element) =>
        element.schArrivalAirport == gblOrigin && element.serviceTypeCode == 'J').toList();
    } else if( brew == 'd') {
      fs = gblFlightStatuss!.flights.where((element) =>
      element.departureAirport == gblOrigin  && element.serviceTypeCode == 'J').toList();
    } else if (brew == 'r') {
      fs = gblFlightStatuss!.flights.where((element) =>
      element.departureAirport == gblOrigin &&
          element.schArrivalAirport == gblDestination  && element.serviceTypeCode == 'J').toList();
    } else {
      String fltNo = _fltNoEditingController.text.toUpperCase();
      if( fltNo != '' ) {
        gblFltNo = fltNo.replaceAll(gblSettings.aircode, '');
        gblFltNo = gblFltNo.replaceAll(new RegExp(r'^0+(?=.)'), '');

        if (gblFlightStatuss != null) {
          fs = gblFlightStatuss!.flights.where((element) =>
          element.flightNumber == gblFltNo  && element.serviceTypeCode == 'J').toList();
         }
        logit('got ${fs.length} flights');
      }
    }
    //var sorted = fs.toList();


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
      cells.add( DataCell(Padding(padding: EdgeInsets.only(left: 10) , child: stText(flight.airlineCode + flight.flightNumber))));
      if( brew == 'a' ) {
        cells.add(DataCell(stText(flight.departureAirportName)));
      }
      if(  brew == 'r' || brew == 'n') {
        cells.add(DataCell(
            Column(
                children: [
                  stText(flight.departureAirportName),
                  stText(flight.schArrivalAirportName)
                ]
            ))
        );
      }
      if( dDate != depDate) {
        cells.add(DataCell(Column( children: [stText(depTime), smText(depDate)])));
      } else {
        cells.add(DataCell(stText(depTime)));
      }
      if( brew == 'd' ) {
        cells.add(DataCell(stText(flight.schArrivalAirportName)));
      }
      if( dDate != arDate) {
        cells.add(DataCell(Column( children: [stText(arTime), smText(arDate)])));
      } else {
        cells.add(DataCell(stText(arTime)));
      }
      String status = '';
      if(flight.arrivalStatus == 'As Scheduled'){
        status = flight.departureStatus;
      } else {
        status = flight.arrivalStatus;
      }
      Color clr = Colors.green.shade200;
      if( status.contains('Sched')){
        clr = Colors.black26;
      } else if( status.contains('Exp')){
        clr = Colors.blue.shade200;
      } else if( status.contains('Can')){
        clr = Colors.red.shade200;
      }
      cells.add(DataCell(
          Padding(padding: EdgeInsets.only(right: 5),
              child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: clr,
            borderRadius:BorderRadius.circular(5.0),
          ),
          child: Row(
              children: [statText(status,)])
        ))
      ));
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
     /* label: Expanded(
        flex: 2,
        child: txt));
*/
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
    cols.add(getColDef(1,'Flight', 15 * width /100, leftPad: 10));

    if( brew == 'a') {
      cols.add(getColDef(2,'Departs', 28 * width /100,));
    }
    // a = 40
    if(  brew == 'r' || brew == 'n') {
      cols.add(getColDef(2,'route', 35 * width /100,));
    }
   // if(  brew == 'r' || brew == 'n' || brew == 'd') {
      cols.add(getColDef(3, 'T/O', 12 * width / 100,));
//    } else {
  //    cols.add(getColDef(3, 'Take Off', 15 * width / 100,));
    //}
    // a = 55
    //cols.add(DataColumn( label: getNamedIcon('takeOff', color: Colors.black),));
    if( brew == 'd' ) {
      cols.add(getColDef(3,'Arrives', 30 * width /100,));
/*      cols.add(DataColumn(
        label: Container(color: colColor, child: Text('Arrives',)),));*/
    }
    if(  brew == 'r' || brew == 'n') {
      cols.add(getColDef(2,'Land', 10 * width /100,));
    } else {
     cols.add(getColDef(2,'Landing', 15 * width /100,));
    }
    // a = 70
    //cols.add(DataColumn( label: getNamedIcon('landing', color: Colors.black),));
    cols.add(getColDef(2,'Status', 27* width /100,));
    //cols.add(DataColumn( label: Container( color: colColor, child: Text('Status',)),));
    // a = 100

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
          child: getFlyFrom(context, brew == 'a'? 'Arrives' : 'Departs', bWantWide: (brew=='r') ? false : true, bold: true)
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
            mainAxisSize: MainAxisSize.max,
              children: [

                // search
          Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            margin: EdgeInsets.fromLTRB(5, 2, 5, 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                  color: Colors.white
              ),
          child:
              Row(mainAxisAlignment: brew == 'a' ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
              children: searchBoxes),
          ),

          // data table
          Container(
            margin: EdgeInsets.fromLTRB(5, 2, 5, 2),
            decoration: BoxDecoration(
                border: Border.all(
                 // color: Colors.red,
                ),
                borderRadius: BorderRadius.circular(10),
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

    return ConstrainedBox(
        constraints: BoxConstraints.expand(
            width: MediaQuery.of(context).size.width
        ),
        child:
        SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child:
            Column(
                mainAxisSize: MainAxisSize.max,
                children: [

                  // search
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    margin: EdgeInsets.fromLTRB(5, 2, 5, 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        color: Colors.white
                    ),
                    child:
                    Row(
                     // mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      v2Label(translate("Enter Flight number")),
                      TextField(
                        textAlign: TextAlign.start,
                        //keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.black),
                        controller: _fltNoEditingController,
                        decoration: InputDecoration(
                            hintText: 'LM0123',
                            isDense: true,
                            constraints: BoxConstraints(
                                maxWidth: 60
                            )
                        ),
                      )
                    ]),
                        vidActionButton(context,'Find Flights',
                            /*disabled: (_fltNoEditingController.text == '') ? true : false,*/
                            _onPressed,                            ),
                        /*_showResults ? getResults('f'):*/ Container()
                      ],
                    )),

                  // data table
                  Container(
                      margin: EdgeInsets.fromLTRB(5, 2, 5, 2),
                      decoration: BoxDecoration(
                          border: Border.all(
                            // color: Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white
                      ),
                      child: /*Text('data')*/
                      DataTable(
                          columnSpacing: 0,
                          headingTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          dataRowColor: WidgetStateColor.resolveWith((states) => Colors.white),
                          horizontalMargin: 0,
                          //columnSpacing: 5,
                          columns: getCols('n') ,
                          rows: getRows('n')
                      )
                  )
                ])
        )
    );

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
Widget titleText(String text){
  return Text(translate(text), style: TextStyle(fontSize: 14, color: Colors.white),);
}


Widget stText(String text){
  if( text.length > 8){
    return Text(text, textScaler: TextScaler.linear(0.8),);
  }
  return Text(text, style: TextStyle(fontSize: 12),);
}
Widget smText(String text){
  return Text(text, style: TextStyle(fontSize: 10),);
}

Widget statText(String text){
  if( text.length > 12){
    return Text(text, textScaler: TextScaler.linear(0.8),);
  }
  return Text(text, style: TextStyle(fontSize: 12),);
}