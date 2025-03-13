import 'package:flutter/material.dart';

import '../components/showDialog.dart';
import '../components/trText.dart';
import '../controllers/vrsCommands.dart';
import '../data/globals.dart';
import '../menu/contact_us_page.dart';
import '../utilities/helper.dart';
import 'Templates.dart';
import 'cards/v3CustomPage.dart';

class V3HomePage extends StatefulWidget {
  V3HomePage({this.ads=false,});

  final bool ads;

  @override
  State<StatefulWidget> createState() => new V3HomePageState();
}

class V3HomePageState extends State<V3HomePage>{
  bool _displayProcessingIndicator = false;
  String bgImage = 'lib/assets/images/bg.png';
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
return  getCustomScaffoldPage(context, gblFqtvLoggedIn ? 'fqtvhome' : 'home', (){
  setState(() {
});
});

  }

Widget getSlide( CardTemplate card, bool topLevel) {


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

