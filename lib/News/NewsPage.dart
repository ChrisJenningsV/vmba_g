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


class NewsPageWidget extends StatefulWidget {
  NewsPageWidget();
  // : super(key: key);

  NewsPageWidgetState createState() =>
      NewsPageWidgetState();
}

class NewsPageWidgetState extends State<NewsPageWidget>  with TickerProviderStateMixin {
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
        appBar: appBar(context, 'NEWS',
          PageEnum.news,
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
      return getResults();

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
/*
                (i==0) ?  getTitle()
                    : Container(),
                getFlight(sorted[i], i),
*/
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
      String reply = await callSmartApi('GETNEWS', data);
      Map<String, dynamic> map = json.decode(reply);
      News news = new News.fromJson(map['news']);

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


class News {

  List<NewsItem> items = [];
  String title = '';
  String description = '';
  String link = '';
  String image = '';

  News.fromJson(Map<String, dynamic> json) {
    if( json['title'] != null ) {
      title = getStringfromMap(json, 'title');
      if( json['description'] != null) description = getStringfromMap(json, 'description');
      if( json['link'] != null) link = getStringfromMap(json, 'link');
      // image is an object
//      if( json['image'] != null) image = getStringfromMap(json, 'image');

      if (json['items'] != null) {
        items = [];
        // new List<Itin>();
        if (json['items'] is List) {
          //List<Map<String, dynamic>> map = json['items'];
          json['items'].forEach((v) {
            Map m = v;
            items.add(new NewsItem.fromJson(v));
          });
        } else  if (json['items'] is Map) {
            //List<Map<String, dynamic>> map = json['items'];
            json['items'].forEach((v) {
              Map m = v;

              items.add(new NewsItem.fromJson(v));
            });
        } else {



          items.add(new NewsItem.fromJson(json['items']));
        }
      } else {
        items = [];
      }
    }
  }

  String getStringfromMap(Map json, String key){
    String result = json[key];
    return result;
  }

}

class NewsItem {
  String title = '';
  String description = '';
  String link = '';
  String guid = '';
  String pubDate = '';



  NewsItem.fromJson(Map<String, dynamic> json) {
    if( json['title'] != null) title = json['title'];
    if( json['description'] != null) description = json['description'];
    if( json['link'] != null) link = json['link'];
    if( json['guid'] != null) guid = json['guid'];
    if( json['pubDate'] != null) pubDate = json['pubDate'];
  }
}

