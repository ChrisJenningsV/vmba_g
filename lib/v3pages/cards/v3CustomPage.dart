


import 'package:flutter/material.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/v3pages/cards/searchCard.dart';
import 'package:vmba/v3pages/cards/v3Card.dart';

import '../../components/trText.dart';
import '../../components/vidCards.dart';
import '../../data/globals.dart';
import '../../menu/contact_us_page.dart';
import '../../menu/menu.dart';
import '../../mmb/myBookingsPage.dart';
import '../../utilities/helper.dart';
import '../../utilities/navigation.dart';
import '../../utilities/widgets/colourHelper.dart';
import '../homePageHelper.dart';
import '../loggedInHomePage.dart';
import '../v3BottomNav.dart';
import '../v3Theme.dart';
import '../v3UnlockPage.dart';
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
  CustomPage? homePage;
  if (gblHomeCardList != null && gblHomeCardList!.pages != null && gblHomeCardList!.pages!.length > 0) {
    if (gblHomeCardList!.pages![pageName] == null) {
      /* list.add(Text(' Page $pageName not found'));
      return list;
    }*/
    }
     homePage = gblHomeCardList!.pages![pageName];

    }
    Widget body = Text('Loading...');
    if( homePage != null ){
      body = getCustomPageBody(context, homePage as CustomPage , doCallback);
    }

    return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        ),
        endDrawer: new DrawerMenu(),
        bottomNavigationBar: getV3BottomNav(context),
        //drawer: DrawerMenu(),
        body: body
    );
  }


Widget getCustomPageBody(BuildContext context, CustomPage homePage, void Function() doCallback) {
  ImageProvider image = Image
      .asset('lib/assets/images/bg.png')
      .image;

  if( homePage.backgroundImage != null && homePage.backgroundImage !='' ){
    NetworkImage backgroundImage = NetworkImage(
        '${gblSettings.gblServerFiles}/pageImages/${homePage.backgroundImage}');
    image = Image(
      image:
      backgroundImage,
      fit: BoxFit.cover,).image;
  }

   if (homePage.pageName == 'newinstall') {
      NetworkImage backgroundImage = NetworkImage(
          '${gblSettings.gblServerFiles}/pageImages/newinstall.png');
      image = Image(
        image:
        backgroundImage,
        fit: BoxFit.cover,).image;
  }

    return Container(
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
                //color: homePage!.backgroundColor,
              ),

              child: Column(
                children:
                getCustomPage(context, homePage, doCallback),

              ),
            ))
    );
  }



  List<Widget> getCustomPage(BuildContext context, CustomPage homePage, // String pageName,
      void Function() doCallback) {
    List<Widget> list = [];
    TextStyle ts = TextStyle();


   /* if (gblHomeCardList != null && gblHomeCardList!.pages!.length > 0) {
      if (gblHomeCardList!.pages![pageName] == null) {
        list.add(Text(' Page $pageName not found'));
        return list;
      }*/

     // CustomPage homePage = gblHomeCardList!.pages![pageName];


      list.add(Padding(padding: EdgeInsets.only(top: homePage.topPadding)));

      if (homePage.title != null && homePage.title!.text != '') {
        ts = homePage.title!.getStyle();
        String sTitle = homePage.title!.text;
        if( gblPassengerDetail != null ){
          sTitle = sTitle.replaceAll('[[firstname]]', gblPassengerDetail!.firstName);
        } else {
          sTitle = sTitle.replaceAll('[[firstname]]', gblSettings.defaultTraveller);
        }

        list.add(Text(
          sTitle,
          style: ts,
        ));
      }

      list.add(Padding(padding: EdgeInsets.all(homePage.bottomPadding)));

      if (homePage.cards != null && homePage.cards!.length > 0) {
        homePage.cards!.forEach((card) {
          if( card.title != null ) {
            ts = card.title!.getStyle();
          }
          switch (card.card_type.toUpperCase()) {
            case 'FLIGHTSEARCH':
              list.add(v3ExpanderCard(
                  context, card,FlightSearchBox(), ts: ts));
              break;
            case 'FLIGHTSCHEDULE':
              list.add(v3ExpanderCard(
                  context, card,Text('body'), ts: ts));
              break;
            case 'NEWUSERLOGIN':
              list.add(v3ExpanderCard(
                  context, card, getUnlockDlg(context, doCallback, isStep1: true), ts: ts, wantIcon: false));
              break;
            case 'UPCOMING':
              list.add(v3ExpanderCard(
                  context, card, getUpcoming(context, doCallback), ts: ts));
              break;
            case 'FQTVLOGIN':
              list.add(v3ExpanderCard(
                  context, card, FqtvLoginBox(), ts: ts));
              break;
            case 'MYBOOKINGS':
              list.add(Container(
                  child: getMiniMyBookingsPage(context, (){ doCallback(); })));
              break;
            case 'CARDSLIDER':
              list.add(getCard(
                  context, card, getSlides(context, card, doCallback), ts: ts));
              break;
            case 'DIVIDER':
              list.add(
                  Padding( padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Divider(color: card.backgroundClr, height: 2,))
              );
              break;
            case 'PHOTOLIST':
              list.add(getCard(
                  context, card,  getPhotoList(context, card.cards, doCallback), ts: ts));
              break;
            case 'LINKLIST':
              list.add(getCard(
                  context, card, getLinks(context, card.cards, doCallback),  ts: ts));
              break;
            case 'BUTTONLIST':
              list.add(Container(
                  child: getLinks(context, card.cards, doCallback)));
              break;
            case 'ICONLINK':
              list.add(getLinkButton(context, card, false, doCallback));
              break;
            case 'PHOTOLINK':
              list.add(getSlide(context, card, true));
              break;
            default:
              logit('card type ${card.card_type} no found');
              break;
          }
        });
      }
    //}
    return list;
  }

Widget getCard(BuildContext context, HomeCard card,  Widget body,
    { bool wantIcon = true,  TextStyle ts= const TextStyle(color: Colors.grey, fontSize: 22) }) {

  if( card.shape != null && card.shape == 'square'){
    return squareCard( context, card, body, wantIcon: wantIcon,  ts: ts );
  }
  return v3ExpanderCard( context, card, body, wantIcon: wantIcon,  ts: ts );
}

Widget squareCard(BuildContext context, HomeCard card,  Widget body,
    { bool wantIcon = true,  TextStyle ts= const TextStyle(color: Colors.grey, fontSize: 22) }) {

  Color titleColor = Colors.grey.shade200;
  String sTitle = 'No Title';

  if( card.backgroundClr != null){
    titleColor = card.backgroundClr as Color;
  }

  if (card.title != null) {
    sTitle = card.title!.text;
  }
  if (gblPassengerDetail != null) {
    sTitle = sTitle.replaceAll('[[firstname]]', gblPassengerDetail!.firstName);
  }

  Widget title =       Container(
      color: titleColor,
      child: Row( children: [
        card.icon!= null ? Icon(
          card.icon,
          size: 30.0,
          color: ts.color,
        ) : Container(),
        Padding(padding: EdgeInsets.all(2)),
        Text(translate(sTitle),  style: ts,)
      ],));

  return Column(
    children: [
      title,
      body
    ]
  );

}
  Widget getSlides(BuildContext context, HomeCard card,  void Function() doCallback) {
    List<Widget> list = [];
    final cards = card!.cards;
    if (cards != null) {
      cards.forEach((card) {
        switch (card.card_type) {
          case 'photoLink':
            list.add(getSlide(context, card, false));
            break;
          case 'iconLink':
            list.add(getLinkButton(context, card, false, doCallback));
            break;
        }
      });
    }


    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          color: card.backgroundClr,
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          /* decoration: BoxDecoration(
  image: DecorationImage(
  image: mainBackGroundImage, fit: BoxFit.fill)),*/
          child: Row(
              children: list
          ),
        ));
  }
  Widget getListItem(BuildContext context, HomeCard card, void Function() doCallback){
    switch (card.card_type) {
      case 'photoLink':
        return getSlide(context, card, false);
        break;
      case 'iconLink':
          return getLinkButton(context, card, false, doCallback);
        break;
      case 'button':
        return getButton(context, card, false, doCallback);
        break;
    }
    return Text('Unknow type ${card.card_type}');

  }

  List<Widget> getLinkList(BuildContext context, List<HomeCard>? cards, void Function() doCallback){
    List<Widget> list = [];
    if (cards != null) {
      cards.forEach((card) {
        list.add(getListItem(context, card, doCallback));
      });
    }
    return list;
  }

Widget getPhotoList(BuildContext context, List<HomeCard>? cards, void Function() doCallback) {
  List<Widget> list = [];

  if (cards != null) {
    Widget? left;
    Widget? right;
    int index = 0;
    cards.forEach((card) {
      index++;
      if( index == 1) {
        left = getListItem(context, card, doCallback);
        right = null;
      } else {
        right = getListItem(context, card, doCallback);
        Row r = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            left as Widget,
            right as Widget
          ],
        );
        list.add(r);
        left = null;
        right = null;
        index = 0;
      }
    });
    // end of list - any left ?
    if( left != null){
      Row r = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          left as Widget,
        ],
      );
      list.add(r);

    }
  }


      return
      Container(
        color: Colors.white,
  child:
        Container(
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

  Widget getLinks(BuildContext context, List<HomeCard>? cards, void Function() doCallback) {
    List<Widget> list = getLinkList(context, cards, doCallback);

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
            if (card.action != null && card!.action!.url != '') {
              Navigator.push(context,
                  SlideTopRoute(page: CustomPageWeb(card!.action!.pageName, card!.action!.url)));
            }
          },

              child: Container(
          width: MediaQuery.of(context).size.width,
         // height: 400,
          child:Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,  // add this
                    children: <Widget>[
        Image.network(
            'https://customertest.videcom.com/LoganAir/AppFiles/${card.image}',
            // width: 300,
           // height: 150,
            fit:BoxFit.fitWidth

        ),
      //)
        ],
      )
          )
      );
    }

    if( card.title != null ) card.title!.card_type = card.card_type;

    Widget footer = Container(color: Colors.white,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(card.title!.text, style: card.title!.getStyle())
            ]));

    if( card.price != '' ){
      footer = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(top: 125)),
          Container(
          color: Colors.white,
                child:Row(
                    children: [Text(card.title!.text, style: card.title!.getStyle())])),
           Container(
             color: Colors.white,
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('from ', style: TextStyle(color: Colors.grey),),
                Text(card.price),
              ],
            )),
        ],
      );
    }

    return Card(
      child: InkWell(
        onTap: () {
          if (card.url != null && card.url != '') {
            Navigator.push(context,
                SlideTopRoute(page: CustomPageWeb(card.title!.text, card.url)));
          }
          if (card.action != null && card!.action!.url != '') {
            Navigator.push(context,
                SlideTopRoute(page: CustomPageWeb(card!.action!.pageName, card!.action!.url)));
          }
        },
        child: Container(
          height: card.height == 0 ? 170 : card.height,
          width: (topLevel) ? null : 170,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(
              width: 2.0,
              // assign the color to the border color
              color: Colors.red,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0x90000000),
                offset: Offset(0.0, 6.0),
                blurRadius: 5.0,
              ),
            ],
            borderRadius:
            new BorderRadius.all(new Radius.circular(5.0)),
            image: _getImage(card, topLevel),
          ),
          alignment: Alignment.bottomCenter,
          child:
              Container(
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child:   footer,
              )
        ),
      ),

    );
  }

  DecorationImage? _getImage(HomeCard card, bool topLevel){
    return DecorationImage(
      image: NetworkImage(
          'https://customertest.videcom.com/LoganAir/AppFiles/${card.image}'),
      fit: BoxFit.fitHeight, // (topLevel) ? BoxFit.fitWidth : BoxFit.fitWidth, // BoxFit.fitHeight,
      alignment: Alignment.topCenter,
    );
  }

Widget getButton(BuildContext context, HomeCard card, bool topLevel,void Function() doCallback) {
  EdgeInsets buttonPad = EdgeInsets.all(10);
  bool wantShadows = gblSettings.wantShadows;

  List<Widget> list = [];
  list.add(VButtonText(card.title!.text, color: card.textClr));

  return
        ElevatedButton(
            onPressed: () {
              if(gblActionBtnDisabled == false ) {
                doCallback();
              }
            },

            style: ElevatedButton.styleFrom(
                elevation: wantShadows ? null :0,
                backgroundColor: card.backgroundClr,
                foregroundColor: card.textClr,
                side: BorderSide(
                  width: 0,
                  color: Colors.transparent,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: getButtonRadius())),
            child: Padding(
              padding: buttonPad,
              child: Row(
                //mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children:  list
                ,
              ),
            )
    );
}



  Widget getLinkButton(BuildContext context, HomeCard card, bool topLevel,void Function() doCallback) {
    if (card.title!.color == null) card.title!.color = Colors.black;

    Widget caption;
    Color? bkClr;
    if( card.card_type == 'button') {
      card.title!.card_type = card.card_type;
      caption = Text(card.title!.text, style: TextStyle(color: card.textClr));
      bkClr = gblSystemColors.primaryButtonColor;
      if( card.backgroundClr != null) bkClr = card.backgroundClr;
    } else {
      caption = Row(
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
      );
    }


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
                  case 'PAGE':
                    if( card.action!.pageName.toUpperCase() == 'HOME') {
                      gblIsNewInstall = false;
                      gblContinueAsGuest = true;
                      gblIsNewInstall = false;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/HomePage', (Route<dynamic> route) => false);
                    }
                    break;
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
              color: bkClr,
              borderRadius:
              new BorderRadius.all(new Radius.circular(5.0)),

            ),
            //alignment: Alignment.bottomCenter,
            child: caption,
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
