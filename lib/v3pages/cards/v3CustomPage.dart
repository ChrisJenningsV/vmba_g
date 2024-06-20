


import 'package:flutter/material.dart';
import 'package:vmba/v3pages/cards/searchCard.dart';
import 'package:vmba/v3pages/cards/v3Card.dart';

import '../../components/vidCards.dart';
import '../../data/globals.dart';
import '../../menu/contact_us_page.dart';
import '../../menu/menu.dart';
import '../../mmb/myBookingsPage.dart';
import '../../utilities/helper.dart';
import '../homePageHelper.dart';
import '../v3BottomNav.dart';
import 'FqtvLogin.dart';


class V3CustomPage extends StatefulWidget {
  V3CustomPage({this.name='', this.mainBackGroundImage });

  final String name;
  AssetImage?  mainBackGroundImage;

  @override
  State<StatefulWidget> createState() => new V3CustomPageState();
}

class V3CustomPageState extends State<V3CustomPage> {

  @override void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    CustomPage? homePage;
    if (gblHomeCardList != null && gblHomeCardList!.pages!.length > 0) {
      homePage = gblHomeCardList!.pages![widget.name];
    }

    return getCustomScaffoldPage(context, widget.name, () {
      setState(() {

      });
    });

 /*   return
      Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          endDrawer: new DrawerMenu(),
          bottomNavigationBar: getV3BottomNav(context),
//drawer: DrawerMenu(),
          body: SingleChildScrollView(
              child: Container(
                color: homePage != null ? homePage!.backgroundColor : Colors
                    .white,
                margin: EdgeInsets.only(top: 24),
                padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                *//*            decoration: BoxDecoration(
                  image: DecorationImage(
                      image: widget.mainBackGroundImage as AssetImage,
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topLeft )
              ),*//*
                child: Column(
                    children: getCustomPage(context, widget.name, doCallback)
                ),
              )));*/
  }
  void doCallback() {
    setState(() {

    });
  }
}
Widget getCustomScaffoldPage(BuildContext context, String pageName, void Function() doCallback) {
  if (gblHomeCardList != null && gblHomeCardList!.pages!.length > 0) {
    if (gblHomeCardList!.pages![pageName] == null) {
      /* list.add(Text(' Page $pageName not found'));
      return list;
    }*/
    }
    CustomPage homePage = gblHomeCardList!.pages![pageName];
    ImageProvider image = Image.asset('lib/assets/images/bg.png').image;
    if( homePage.backgroundImage != ''){
      if( homePage.backgroundImage.contains('http')){
        NetworkImage backgroundImage = NetworkImage(
            '${homePage.backgroundImage}');
        image = Image(
          image:
          backgroundImage,
          fit: BoxFit.cover,).image;

      }else {
        NetworkImage backgroundImage = NetworkImage(
            '${gblSettings.gblServerFiles}/${homePage.backgroundImage}');
        image = Image(
          image:
          backgroundImage,
          fit: BoxFit.cover,).image;

      }

    }

    return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        ),
        endDrawer: new DrawerMenu(),
        bottomNavigationBar: getV3BottomNav(context),
        //drawer: DrawerMenu(),
        body: Container(
          //          margin: EdgeInsets.only(top: 24),
            width: MediaQuery
                .of(context)
                .size
                .width,
            child:

            SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(top: 24),
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),

                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: image, //mainBackGroundImage,
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topLeft),
                    color: homePage!.backgroundColor,
                  ),

                  child: Column(
                    children:
                    getCustomPage(context, pageName, doCallback),

                  ),
                ))
        )
    );
  }
  else {
    return Text(' Page $pageName not found');
  }

}

  List<Widget> getCustomPage(BuildContext context, String pageName,
      void Function() doCallback) {
    List<Widget> list = [];
    TextStyle ts = TextStyle();


    if (gblHomeCardList != null && gblHomeCardList!.pages!.length > 0) {
      if (gblHomeCardList!.pages![pageName] == null) {
        list.add(Text(' Page $pageName not found'));
        return list;
      }

      CustomPage homePage = gblHomeCardList!.pages![pageName];


      list.add(Padding(padding: EdgeInsets.only(top: homePage.topPadding)));

      if (homePage.title != null && homePage.title!.text != '') {
        ts = homePage.title!.getStyle();

        list.add(Text(
          homePage.title!.text,
          style: ts,
        ));
      }

      list.add(Padding(padding: EdgeInsets.all(homePage.bottomPadding)));

      if (homePage.cards != null && homePage.cards!.length > 0) {
        homePage.cards!.forEach((card) {
          ts = card.title!.getStyle();

          switch (card.card_type.toUpperCase()) {
            case 'FLIGHTSEARCH':
              list.add(v3ExpanderCard(
                  context, card,FlightSearchBox(), ts: ts));
              break;
/*            case 'FQTVSUMMARY':
              list.add(v3ExpanderCard(
                  context, card,FqtvSummaryBox(), ts: ts));*/
              break;
            case 'FLIGHTSCHEDULE':
              list.add(v3ExpanderCard(
                  context, card,Text('body'), ts: ts));
              break;
            case 'FQTVLOGIN':
              list.add(v3ExpanderCard(
                  context, card, FqtvLoginBox(), ts: ts));
              break;
            case 'MYBOOKINGS':
              list.add(v3ExpanderCard(
                  context, card,getMiniMyBookingsPage(context),ts: ts));
              break;
            case 'CARDSLIDER':
              list.add(v3ExpanderCard(
                  context, card, getSlides(context, card.cards, doCallback), ts: ts));
              break;
            case 'LINKLIST':
              list.add(v3ExpanderCard(
                  context, card, getLinks(context, card.cards, doCallback),  ts: ts));
              break;
            case 'PHOTOLINK':
              list.add(getSlide(context, card, true));
              break;
          }
        });
      }
    }
    return list;
  }

  Widget getSlides(BuildContext context, List<HomeCard>? cards, void Function() doCallback) {
    List<Widget> list = [];
    if (cards != null) {
      cards.forEach((card) {
        switch (card.card_type) {
          case 'photoLink':
            list.add(getSlide(context, card, false));
            break;
          case 'iconLink':
            list.add(getLink(context, card, false, doCallback));
            break;
        }
      });
    }


    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          /* decoration: BoxDecoration(
  image: DecorationImage(
  image: mainBackGroundImage, fit: BoxFit.fill)),*/
          child: Row(
              children: list
          ),
        ));
  }

  Widget getLinks(BuildContext context, List<HomeCard>? cards, void Function() doCallback) {
    List<Widget> list = [];
    if (cards != null) {
      cards.forEach((card) {
        switch (card.card_type) {
          case 'photoLink':
            list.add(getSlide(context, card, false));
            break;
          case 'iconLink':
            list.add(getLink(context, card, false, doCallback));
            break;
        }
      });
    }
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          child: Column(
              children: list
          ),
        ));
  }

  Widget getSlide(BuildContext context, HomeCard card, bool topLevel) {
    if (card.title!.color == null) card.title!.color = Colors.white;

    if( card.format != '' && card.format.toLowerCase() == 'fill'){
      return InkWell(
          onTap: () {
            if (card.url != null && card.url != '') {
              Navigator.push(context,
                  SlideTopRoute(page: CustomPageWeb(card.title!.text, card.url)));
            }
          },

              child: Container(
          width: MediaQuery.of(context).size.width,
         // height: 400,
          child:Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,  // add this
                    children: <Widget>[
/*
                ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
        child:
*/
        Image.network(
            'https://customertest.videcom.com/LoganAir/AppFiles/${card.image}',
            // width: 300,
           // height: 150,
            fit:BoxFit.fill

        ),
      //)
        ],
      )
          )
      );
    }

    return Card(
      child: InkWell(
        onTap: () {
          if (card.url != null && card.url != '') {
            Navigator.push(context,
                SlideTopRoute(page: CustomPageWeb(card.title!.text, card.url)));
          }
        },
        child: Container(
          height: card.height == 0 ? 120 : card.height,
          width: (topLevel) ? null : 120,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            //color: gblSystemColors.seatPlanColorUnavailable,
            borderRadius:
            new BorderRadius.all(new Radius.circular(5.0)),
            image: _getImage(card, topLevel),
          ),
          alignment: Alignment.bottomCenter,
          child:
          Text(card.title!.text, style: card.title!.getStyle()),
        ),
      ),

    );
  }

  DecorationImage? _getImage(HomeCard card, bool topLevel){
    return DecorationImage(
      image: NetworkImage(
          'https://customertest.videcom.com/LoganAir/AppFiles/${card.image}'),
      fit: BoxFit.none, // (topLevel) ? BoxFit.fitWidth : BoxFit.fitWidth, // BoxFit.fitHeight,
      alignment: Alignment.topCenter,
    );
  }

  Widget getLink(BuildContext context, HomeCard card, bool topLevel,void Function() doCallback) {
    if (card.title!.color == null) card.title!.color = Colors.black;
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: () async {
            if (card.action != null) {
              if (card.action!.url != null && card.action!.url != '') {
                Navigator.push(context,
                    SlideTopRoute(page: CustomPageWeb(
                        card.title!.text, card.action!.url)));
              } else if (card.action!.function != null &&
                  card.action!.function != '') {
                switch (card.action!.function.toUpperCase()) {
                  case 'CUSTOMPAGE':
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) =>
                            V3CustomPage(name: card.action!.pageName)));
                    break;
                  case 'LOADCUSTOMPAGE':
                    await initHomePage(card.action!.fileName);
                    doCallback();
/*
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                    V3CustomPage( name: card.action!.pageName)));
*/
                    break;
                }
              }
            }
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
            height: card.height == 0 ? 60 : card.height,
            // width: (topLevel)? null : 120,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              //color: gblSystemColors.seatPlanColorUnavailable,
              borderRadius:
              new BorderRadius.all(new Radius.circular(5.0)),

            ),
            //alignment: Alignment.bottomCenter,
            child:
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        getIcon(card),
                        Padding(padding: EdgeInsets.all(3)),
                        Text(card.title!.text, style: card.title!.getStyle()),
                      ]),
                  Padding(padding: EdgeInsets.all(3)),
                  Icon(Icons.chevron_right, size: 20,)
                ]
            ),
          ),

        ));
  }

  Widget getIcon(HomeCard card) {
    if (card.icon != null) {
      //
      // return Icon(card.icon);
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey.shade300,
        child: IconButton(
          icon: Icon(
            card.icon,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
      );
    }
    return Container();
  }
