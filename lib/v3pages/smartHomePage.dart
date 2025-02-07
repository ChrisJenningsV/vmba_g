import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/v3pages/v3BottomNav.dart';

import '../components/showDialog.dart';
import '../components/trText.dart';
import '../components/vidCards.dart';
import '../controllers/vrsCommands.dart';
import '../data/globals.dart';
import '../data/models/vrsRequest.dart';
import '../data/repository.dart';
import '../menu/contact_us_page.dart';
import '../menu/menu.dart';
import '../utilities/helper.dart';
import 'homePageHelper.dart';
import 'cards/searchCard.dart';
import 'cards/v3CustomPage.dart';

class SmartHomePage extends StatefulWidget {
  SmartHomePage();

  @override
  State<StatefulWidget> createState() => new SmartHomePageState();
}

class SmartHomePageState extends State<SmartHomePage>{
  bool _displayProcessingIndicator = false;
  late AssetImage  mainBackGroundImage;
  late CustomPage homePageList;
  CustomPage? homePage;

  @override void initState() {
    initJson();
    gblSearchParams.init();

    super.initState();
  }
  @override
  void didChangeDependencies() {
    try {
      super.didChangeDependencies();
     // mainBackGroundImage = AssetImage(bgImage);
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

    // get custom page
 /*   if (homePage != null ) {
      return Column(
          children:getCustomPage(context, homePage as CustomPage , (){

      })
      );
    }*/
    return  getCustomScaffoldPage(context, gblFqtvLoggedIn ? 'fqtvhome' : 'home', (){
      setState(() {
      });
    });

  }

  Widget getSlide( HomeCard card, bool topLevel) {


    if( card.title!.color == null) card.title!.color = Colors.white;
    return Card(
      child: InkWell(
        onTap:() {
          if( card.url!= null && card.url!=''){
            Navigator.push(context,
                SlideTopRoute(page: CustomPageWeb(card.title!.text, card.url)));
          }
        },
        child: Container(
          height: card.height == 0 ? 120 : card.height,
          width: (topLevel)? null : 120,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            //color: gblSystemColors.seatPlanColorUnavailable,
            borderRadius:
            new BorderRadius.all(new Radius.circular(5.0)),
            image: DecorationImage(
              image: NetworkImage('https://customertest.videcom.com/LoganAir/AppFiles/${card.image}'),
              fit: (topLevel) ? BoxFit.fitWidth : BoxFit.fitHeight,
              alignment: Alignment.topCenter,
            ),
          ),
          alignment: Alignment.bottomCenter,
          child:
          Text(card.title!.text, style: card.title!.getStyle()),
        ),
      ),

    );
  }

  initJson()  async {

    try {
      logit('smartHomePage: initJson');

      // get default home
      getHomepage();

      // get geo home
      if (gblCurLocation != null &&
          gblLoadedHomeCountry != gblCurLocation!.country) {
        // use smart api to load home page JSON
        await loadLocationHome();
  /*      LoadHomePageRequest rq = LoadHomePageRequest(
            country: gblCurLocation!.country as String,
            countryCode: gblCurLocation!.isoCountryCode as String,
            county: gblCurLocation!.subAdministrativeArea as String,
            city: gblCurLocation!.locality as String
        );

        String data = json.encode(rq);
        gblHomeCardList = null;
        String rx = await callSmartApi('LOADHOMEPAGE', data);
        gblLoadedHomeCountry = gblCurLocation!.country as String;
        logit('smartHomePage: loaded home');
        final Map<String, dynamic> map = json.decode(rx);
        gblHomeCardList = new PageListHolder.fromJson(map['root']);*/
        if (gblHomeCardList != null && gblHomeCardList!.pages!['home'] != null) {
          logit('smartHomePage: got home');
          _displayProcessingIndicator = false;
          homePage = gblHomeCardList!.pages!['home'];
          setState(() {

          });
        } else {
          // use default
          String jsonString =  await rootBundle.loadString('lib/assets/json/DefaultHome.json');
          final Map<String, dynamic> map = json.decode(jsonString);
          gblHomeCardList = new PageListHolder.fromJson(map['root']);
          logit('smartHomePage: use local home');
          _displayProcessingIndicator = false;
          homePage = gblHomeCardList!.pages!['home'];
          setState(() {

          });
        }

      } else {
        logit('no location data');
      }
    } catch(e) {
      logit('SmartHome  ${e.toString()}');
    }
  }

}

