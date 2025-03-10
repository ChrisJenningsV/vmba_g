
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/Managers/imageManager.dart';
import 'package:vmba/calendar/calendarFunctions.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/v3pages/v3BottomNav.dart';
import 'package:vmba/v3pages/v3Theme.dart';

import '../components/showDialog.dart';
import '../components/trText.dart';
import '../components/vidCards.dart';
import '../controllers/vrsCommands.dart';
import '../data/globals.dart';
import '../data/repository.dart';
import '../dialogs/genericFormPage.dart';
import '../menu/contact_us_page.dart';
import '../menu/menu.dart';
import '../utilities/helper.dart';
import '../utilities/navigation.dart';
import 'Templates.dart';
import 'cards/searchCard.dart';
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

Widget getUpcoming(BuildContext context,CardTemplate card, void Function() doCallback) {
  if( gblTrips == null || gblTrips!.trips == null || gblTrips!.trips!.length == 0){
    return VTitleText('No upcoming trips', translate: true,);

  }
  String destin = gblTrips!.trips!.first.destin; //cityCodetoAirport(gblTrips!.trips!.first.destin);
  //String destin = cityCodetoAirport(gblTrips!.trips!.first.depart);
  List<Widget> list = [];
  String departs = '';
  String lands = '';

  if( gblNextPnr != null ){

      list.add(Row( children: [VHeadlineText('Booking Reference: ${gblNextPnr!.pNR.rLOC}', color: card.textClr, size: TextSize.small,)]));
      list.add(Row( children: [VHeadlineText('${gblTrips!.trips!.first.fltNo}', color: card.textClr, size: TextSize.small,)]));
      departs = gblNextPnr!.pNR.itinerary.itin.first.depTime.substring(0, 5);
      lands = gblNextPnr!.pNR.itinerary.itin.first.arrTime.substring(0, 5);
  }
  // Booking reference

  list.add(
    Row(
      children: [
        VHeadlineText(cityCodetoAirport(gblTrips!.trips!.first.depart) + ' ' + departs, color: card.textClr, size: TextSize.small, ),
        Icon(Icons.flight_takeoff, size: 25, color: card.textClr,),
        VHeadlineText(cityCodetoAirport(gblTrips!.trips!.first.destin )+ ' ' + lands, color: card.textClr, size: TextSize.small)
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
          children: [
            vidWideActionButton(context, 'Setttings', (context, d){
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
