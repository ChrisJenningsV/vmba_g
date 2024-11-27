


import 'package:flutter/material.dart';
import 'package:vmba/v3pages/v3BottomNav.dart';

import '../components/showDialog.dart';
import '../components/trText.dart';
import '../components/vidCards.dart';
import '../controllers/vrsCommands.dart';
import '../data/globals.dart';
import '../menu/contact_us_page.dart';
import '../menu/menu.dart';
import '../utilities/helper.dart';
import 'homePageHelper.dart';
import 'cards/searchCard.dart';
import 'cards/v3CustomPage.dart';

class NewInstallPage extends StatefulWidget {
  NewInstallPage({this.ads=false,});

  final bool ads;

  @override
  State<StatefulWidget> createState() => new NewInstallPageState();
}

class NewInstallPageState extends State<NewInstallPage>{
  bool _displayProcessingIndicator = false;
  String bgImage = 'lib/assets/images/newinstall.png';
  late AssetImage  mainBackGroundImage;
  late CustomPage homePageList;

  @override void initState() {
    initJson();
    gblSearchParams.init();

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
      logit(gblError);
  /*    showVidDialog(context, gblErrorTitle, gblError, onComplete:() {
        setError('');
        setState(() {});
      });*/
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
    return  getCustomScaffoldPage(context, 'newinstall', (){
      setState(() {
      });
    });

    /*return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
         elevation: 0,
         // foregroundColor: Colors.transparent,
         // title: Text('Home'),
        ),
        endDrawer: new DrawerMenu(),
        bottomNavigationBar: getV3BottomNav(context),
        //drawer: DrawerMenu(),
        body: Container(
//          margin: EdgeInsets.only(top: 24),
          width: MediaQuery.of(context).size.width,
          child:

        SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 24),
            padding: EdgeInsets.fromLTRB(15,  5, 15,  5),

              decoration: BoxDecoration(
          image: DecorationImage(
                      image: Image.asset('lib/assets/images/bg.png').image,//mainBackGroundImage,
                      fit: BoxFit.fitWidth ,
                      alignment: Alignment.topLeft )
              ),

            child: Column(
            children:
              getCustomPage(context, 'home', (){setState(() {

              });}),

          ),
        ))
    )
    );*/
  }

/*


Widget getSlides(List<HomeCard>? cards){
    List<Widget> list =[];
    if( cards != null ){
      cards.forEach((card) {
        switch (card.card_type){
          case 'photoLink':

            list.add(getSlide( card, false));
            break;
        }
      });
    }


  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
      child: Container(
      padding: EdgeInsets.fromLTRB(15,  5, 15,  5),
 */
/* decoration: BoxDecoration(
  image: DecorationImage(
  image: mainBackGroundImage, fit: BoxFit.fill)),*//*

  child: Row(
  children: list
  ),
  ));
}
*/

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

  initJson()  {
    getHomepage();
  }

}

