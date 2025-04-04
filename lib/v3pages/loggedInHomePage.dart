import 'package:flutter/material.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/v3pages/v3Theme.dart';

import '../components/showDialog.dart';
import '../components/trText.dart';
import '../controllers/vrsCommands.dart';
import '../data/globals.dart';
import '../data/models/pnr.dart';
import '../data/models/trips.dart';
import '../data/repository.dart';
import '../dialogs/genericFormPage.dart';
import '../utilities/helper.dart';
import '../utilities/navigation.dart';
import 'Templates.dart';
import 'cards/v3CustomPage.dart';

class LoggedInHomePage extends StatefulWidget {
  LoggedInHomePage();

  @override
  State<StatefulWidget> createState() => new LoggedInHomePageState();
}

class LoggedInHomePageState extends State<LoggedInHomePage>{
  bool _displayProcessingIndicator = false;
  String bgImage = 'lib/assets/images/newinstall.png';
  late AssetImage  mainBackGroundImage;
  late CustomPage homePageList;

  @override void initState() {
    initJson();
    gblSearchParams.init();
    _loadData();

    super.initState();
  }
  @override
  void didChangeDependencies() {
    try {
      super.didChangeDependencies();
      mainBackGroundImage = AssetImage(bgImage);
      precacheImage(mainBackGroundImage, context);
    } catch(e) {

    }
  }

  @override
  Widget build(BuildContext context) {

    if (gblError != '') {
      showVidDialog(context, gblErrorTitle, gblError, onComplete:() {
        setError('');
        setState(() {});
      });
    }

    if (_displayProcessingIndicator) {
      return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('lib/assets/$gblAppTitle/images/loader.png'),
                CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TrText('Loading...'),
                ),
              ],
            ),
          ));
    }

    // get page info
    if (gblHomeCardList != null && gblHomeCardList!.pages!.length > 0) {
      if (gblHomeCardList!.pages!['home'] == null) {

      }
    }
    return  getCustomScaffoldPage(context, 'loggedinhome', (){
      setState(() {
      });
    });
  }

  _loadData() async {
    _displayProcessingIndicator = true;

    await Repository.get().settings();

    if( gblLoginSuccessful ){
      // check pax and trip info
      if( gblTrips != null && gblTrips!.trips != null && gblTrips!.trips!.length > 0){

        if( gblPassengerDetail == null ) {
          gblPassengerDetail = new PassengerDetail( email:  '', phonenumber: '');
        }
          gblPassengerDetail!.firstName = gblTrips!.trips!.first.firstname;
          gblPassengerDetail!.lastName = gblTrips!.trips!.first.lastname;
          gblPassengerDetail!.title = gblTrips!.trips!.first.title;
          gblPassengerDetail!.phonenumber = gblTrips!.trips!.first.phone;

      }
    }
    _displayProcessingIndicator = false;

    setState(() {

    });
  }
  initJson()  {
    getHomepage();
  }

}

Widget getUpcoming(BuildContext context,CardTemplate card, Trip trip, void Function() doCallback) {
  if( trip == null ){
    return VTitleText('No upcoming trips', translate: true,);

  }
  String destin = trip.destin; //cityCodetoAirport(gblTrips!.trips!.first.destin);
  //String destin = cityCodetoAirport(gblTrips!.trips!.first.depart);
  List<Widget> list = [];
  String departs = '';
  String depart = trip.depart;
  String lands = '';
  Itin? firstFlt;
  bool found = false;
  gblNextPnr!.pNR.itinerary.itin.forEach((Itin flt ) {
    if (!found) {
      DateTime fltDt = DateTime.parse(flt.ddaygmt + ' ' + flt.dtimgmt);
      if (fltDt.isAfter(DateTime.now())) {
        firstFlt = flt;
        found = true;
      }
    }
  });
  if( gblNextPnr != null ){

      list.add(Row( children: [Text(translate('Booking Reference:') + ' ${gblNextPnr!.pNR.rLOC}', style: TextStyle(color: card.textClr))]));
      if( firstFlt != null ){
        list.add(Row(children: [
          Text('${firstFlt!.airID}${firstFlt!.fltNo}',
              style: TextStyle(color: card.textClr))
        ]));
        departs = firstFlt!.depTime.substring(0, 5);
        lands = firstFlt!.arrTime.substring(0, 5);
        depart = firstFlt!.depart;
        destin = firstFlt!.arrive;

      } else {
        list.add(Row(children: [
          Text('${gblTrips!.trips!.first.fltNo}',
              style: TextStyle(color: card.textClr))
        ]));
        departs = gblNextPnr!.pNR.itinerary.itin.first.depTime.substring(0, 5);
        lands = gblNextPnr!.pNR.itinerary.itin.first.arrTime.substring(0, 5);
      }
  }
  // Booking reference

  list.add(
    Row(
      children: [
        Text(cityCodetoAirport(depart) + ' ' + departs, style: TextStyle(color: card.textClr,) ),
        Padding(padding: EdgeInsets.only(left: 10, right: 10), child:Icon(Icons.flight_takeoff, size: 25, color: card.textClr,)),
        Text(cityCodetoAirport(destin )+ ' ' + lands, style: TextStyle(color: card.textClr,))
      ]
    ));


  return
     Container(
       padding: EdgeInsets.all(10),
  color: Colors.transparent,
  width: MediaQuery.of(context).size.width,

  child:Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,  // add this
  children: <Widget>[
    Column(
        children: list,
      ),
    ]
  ));

}

Widget getFinishSetup(BuildContext context, void Function() doCallback){
  List<Widget> list = [];
  list.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            vidActionButton(context, 'Settings', (context, d){
              navToSmartDialogHostPage(context, new FormParams(formName: 'NEWINSTALLSETTINGS',
                  formTitle: 'New Install Settings'));

            })
          ]
      ));

  return
    Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        // height: 400,
        alignment: Alignment.center,
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,  // add this
            children: <Widget>[
/*
              Image.network('${gblSettings.gblServerFiles}/cityImages/$destin.png',
                  fit:BoxFit.fill

              ),
*/
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: list,
              ),
            ]
        ));


}
