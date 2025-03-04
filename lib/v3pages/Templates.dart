import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/vrsCommands.dart';
import '../data/globals.dart';
import '../utilities/helper.dart';
import 'package:http/http.dart' as http;

Future getHomepage() async {
  logit('getHomepage');
  if( gblHomeCardList == null ) {
    String jsonString =  await rootBundle.loadString('lib/assets/$gblAppTitle/json/home.json');

    final Map<String, dynamic> map = json.decode(jsonString);
    logit('getHomepage - loaded');
    if( map['root'] != null ) {
      gblHomeCardList = new PageListHolder.fromJson(map['root']);
    } else {
      gblHomeCardList = new PageListHolder.fromJson(map);

    }
  }
}

class PageListHolder {
  Map? pages;
  //List<CustomePage>? pages;
  String version ='';

  PageListHolder.fromJson(Map<String, dynamic> json) {
    try {
      if (json['version'] != null) version = json['version'];

      if (json['pages'] != null) {
        pages = new Map();
        //new List<Country>();
        json['pages'].forEach((n, v) {
          pages![n] = new CustomPage.fromJson(v);
        });
      }
    } catch (e) {
      logit(e.toString());
    }
  }

}

class CustomPage {
  List<CardTemplate>? cards;
  String pageName = '';
  CardText? title;
  double topPadding = 40;
  double bottomPadding = 10;
  Color? backgroundColor = Colors.white;
  String backgroundImage = '';
  bool wantBackground = true;
  BottomNav? bottomNav;


  CustomPage({this.cards});

  CustomPage.fromJson(Map<String, dynamic> json) {
    try {
      if (json['topPadding'] != null)
        topPadding = double.parse(json['topPadding']);
      if (json['bottomPadding'] != null)
        bottomPadding = double.parse(json['bottomPadding']);
      if (json['backgroundColor'] != null)
        backgroundColor = lookUpColor(json['backgroundColor'].toString());
      if (json['backgroundImage'] != null)
        backgroundImage = json['backgroundImage'];
      if( json['wantBackground'] != null ) wantBackground = parseBool(json['wantBackground']);

      if (json['title'] != null) {
        if (json['title'] is Map) {
          title = CardText.fromJson('Home', json['title']);
        } else {
          title = new CardText('Home', text: json['title']);
        }

      }

      if (json['cards'] != null) {
        cards = [];
        //new List<Country>();
        if (json['cards'] is List) {
          json['cards'].forEach((v) {
            CardTemplate c = new CardTemplate.fromJson(v);
            if (c.title != null) {
//          logit('ttl ${c.title!.text} bgclr ${c.title!.backgroundColor}');
            }
            cards?.add(c);
          });
        } else {
          CardTemplate c = new CardTemplate.fromJson(json['cards']);
          cards?.add(c);
        }
      }
      if (json['bottomNav'] != null) {
        bottomNav = new BottomNav.fromJson(json['bottomNav']);
      }
    } catch (e) {
      logit('CustomPage ${e.toString()}');
    }
  }


}

class BottomNav {
  bool display = false;

  BottomNav.fromJson(Map<String, dynamic> json) {
    if (json['display'] != null) display = parseBool(json['display']);
  }

}

class CardTemplate extends LinkTemplate  {

  IconData? icon;
  String image='';
  String format='';
  String shape='';
  String price = '';
  double height = 0;
  double fontSize = 0;
  bool expanded = true;
  double cornerRadius= 10;
  Color? backgroundClr;
  Color? textClr;
  CardBodyTemplate? body;

  List<CardTemplate>? cards;
  List<LinkTemplate>? links;


  CardTemplate();

  CardTemplate.fromJson(Map<String, dynamic> json) : super.fromJson(json) {

    try {
      if (json['card_type'] != null) card_type = json['card_type'];
      //logit('HomeCard.fromJson $card_type');
      if( card_type == 'photoLink'){
        //logit('HomeCard.fromJson $card_type');
      }

      if (json['expanded'] != null) expanded = parseBool(json['expanded']);
      if (json['format'] != null) format = json['format'];
      if (json['shape'] != null) shape = json['shape'];
      if (json['price'] != null) price = json['price'];
      if (json['icon'] != null && json['icon'] != '' &&
          json['icon'] != 'none') {
        icon = getIconFromName(json['icon'].toString());
      }
      if (json['image'] != null) image = json['image'];
      if (json['backgroundClr'] != null) backgroundClr = lookUpColor(json['backgroundClr']);
      if (json['textClr'] != null) textClr = lookUpColor(json['textClr']);
      if (json['url'] != null) url = json['url'];
      if (json['height'] != null) height = double.parse(json['height']);
      if (json['fontSize'] != null) fontSize = double.parse(json['fontSize']);
      if (json['cornerRadius'] != null) {
        if (int.parse(json['cornerRadius']) < 50) {
          cornerRadius = double.parse(json['cornerRadius']);
        }
      }

      if (json['cards'] != null) {
        cards = [];
        //new List<Country>();
        json['cards'].forEach((v) {
          cards?.add(new CardTemplate.fromJson(v));
        });
      }
      if (json['links'] != null) {
        links = [];
        //new List<Country>();
        if (json['links'] is List) {
          json['links'].forEach((v) {
            links?.add(new LinkTemplate.fromJson(v));
          });
        } else {
          links?.add(new LinkTemplate.fromJson(json['links']));

        }

      }
      if( title != null ) title!.card_type = card_type;
    } catch(e) {
      logit('HomeCard.fromJson ${e.toString()}');
      }

    }
  }

  class CardBodyTemplate{

  }

class LinkTemplate {
  String url='';
  CardAction? action;
  String destination='';
  CardText? title;
  String card_type='';

  LinkTemplate();
  LinkTemplate.fromJson(Map<String, dynamic> json) {
    //logit('HomeCardLink.fromJson');
    try {
      if (json['action'] != null) {
        action = CardAction.fromJson(json['action']);
      }
      if (json['destination'] != null) destination = json['destination'];

      if (json['title'] != null) {
        if (json['title'] is Map) {
          title = CardText.fromJson(card_type, json['title']);
//          logit('ttl ${title!.text} bgclr ${title!.backgroundColor}');
        } else {
          title = new CardText(card_type, text: json['title']);
        }
        title!.card_type = card_type;
      }
    } catch(e) {
      logit('HomeCardLink.fromJson ${e.toString()}');
    }

    }
  }


class CardAction {
  String function = '';
  String pageName = '';
  String fileName = '';
  String url='';

  CardAction();

  CardAction.fromJson(Map<String, dynamic> json) {
    try {
      if (json['function'] != null) function = json['function'];
      if (json['pageName'] != null) pageName = json['pageName'];
      if (json['fileName'] != null) fileName = json['fileName'];
      if (json['url'] != null) url = json['url'];
     } catch (e) {
        logit('CardAction ' + e.toString());
    }

  }
}

class CardText {
  Color? color ;
  Color? backgroundColor;
  String text = '';
  String card_type='';
  FontWeight fontWeight =FontWeight.normal;
  double fontSize = 0;

  CardText(this.card_type, {this.text=''});

  CardText.fromJson(String card_type, Map<String, dynamic> json) {
    try {
      this.card_type = card_type;
      if (json['text'] != null) text = json['text'];
      if (json['fontSize'] != null) fontSize = double.parse(json['fontSize']);

      if (json['fontWeight'] != null) {
        if (json['fontWeight'].toString().toUpperCase().contains('BOLD')) {
          fontWeight = FontWeight.bold;
        } else
        if (json['fontWeight'].toString().toUpperCase().contains('100')) {
          fontWeight = FontWeight.w100;
        } else
        if (json['fontWeight'].toString().toUpperCase().contains('200')) {
          fontWeight = FontWeight.w200;
        } else
        if (json['fontWeight'].toString().toUpperCase().contains('300')) {
          fontWeight = FontWeight.w300;
        } else
        if (json['fontWeight'].toString().toUpperCase().contains('400')) {
          fontWeight = FontWeight.w400;
        } else
        if (json['fontWeight'].toString().toUpperCase().contains('500')) {
          fontWeight = FontWeight.w500;
        } else
        if (json['fontWeight'].toString().toUpperCase().contains('600')) {
          fontWeight = FontWeight.w600;
        } else
        if (json['fontWeight'].toString().toUpperCase().contains('700')) {
          fontWeight = FontWeight.w700;
        } else
        if (json['fontWeight'].toString().toUpperCase().contains('800')) {
          fontWeight = FontWeight.w800;
        } else
        if (json['fontWeight'].toString().toUpperCase().contains('900')) {
          fontWeight = FontWeight.w900;
        }
      }
      if (json['color'] != null) {
        if (json['color'].toString().startsWith('#')) {
          color = json['color'].toString().toColor();
        } else {
          // look up color name
          color = lookUpColor(json['color'].toString());
        }
      }
      if (json['backgroundColor'] != null) {
        //logit('fromJ $text got bgClr ${json['backgroundColor']}');

        if (json['backgroundColor'].toString().startsWith('#')) {
          backgroundColor = json['backgroundColor'].toString().toColor();
        } else {
          backgroundColor = lookUpColor(json['backgroundColor'].toString());
        }
        //logit('fromJ $text got bgClr $backgroundColor');
      }
    } catch(e){
      logit(' ${e.toString()}');
    }

    }

  TextStyle getStyle(){
    double fontS = 0;
    Color clr = Colors.black;
    FontWeight fw =FontWeight.normal;

    // set defaults
    switch(card_type.toUpperCase()){
      case 'HOME':
        fontS = 30;
        clr = gblSystemColors.v3TitleColor as Color;
        if( color != null ) clr = color as Color;
        break;
      case 'FLIGHTSEARCH':
        fontS = 20;
        clr = Colors.grey;
        break;
      case 'FLIGHTSCHEDULE':
        fontS = 20;
        clr = Colors.grey;
        break;
      case 'CARDSLIDER':
        fontS = 20;
        clr = Colors.grey;
        if( color != null ) clr = color as Color;
        break;
      case 'PHOTOLINK':
        fontS = 20;
        clr = Colors.black;
        break;
      case 'BUTTON':
        fontS = 20;
        clr = gblSystemColors.primaryButtonTextColor as Color;
        if( color != null ) clr = color as Color;
        break;

      default:
        fontS = 20;
        clr = Colors.grey;
        break;
    }
    if(fontSize != 0) fontS = fontSize;
//    if( color != null ) clr = color as Color;
    TextStyle ts = TextStyle(fontSize: fontS, color: clr);

    return ts;
  }
}

Color lookUpColor(String colorName){
  if( colorName.startsWith('#')){
    // hex color, format #F0F0F0 (#<red><green><blue>
    int r = int.parse(colorName.substring(1,3),radix: 16);
    int g = int.parse(colorName.substring(3,5),radix: 16);
    int b = int.parse(colorName.substring(5,7),radix: 16);
    return Color.fromRGBO(r, g, b, 1);
  }

  switch (colorName.toUpperCase()){
    case 'TRANSPARENT':
      return Colors.transparent;
    case 'RED':
      return Colors.red;
    case 'PINK':
      return Colors.pink;
    case 'BLACK':
      return Colors.black;
    case 'WHITE':
      return Colors.white;

  case 'PURPLE':
    return Colors.purple;
  case 'DEEPPURPLE':
    return Colors.deepPurple;
  case 'INDIGO':
    return Colors.indigo;
  case 'BLUE':
    return Colors.blue;
  case 'LIGHTBLUE':
    return Colors.lightBlue;
  case 'CYAN':
    return Colors.cyan;
  case 'TEAL':
    return Colors.teal;
  case 'GREEN':
    return Colors.green;
  case 'LIGHTGREEN':
    return Colors.lightGreen;
  case 'LIME':
    return Colors.lime;
  case 'YELLOW':
    return Colors.yellow;
  case 'AMBER':
    return Colors.amber;
  case 'ORANGE':
    return Colors.orange;
  case 'DEEPORANGE':
    return Colors.deepOrange;
    case 'BROWN':
      return Colors.brown;
    case 'GREY':
      return Colors.grey;
    case 'BLUEGREY':
      return Colors.blueGrey;

  }
  return Colors.red;
}

IconData getIconFromName(String name) {
  switch(name.toUpperCase()){
    case 'SEARCH':
      return Icons.search;
    case 'CITY':
      return Icons.location_city;
    case 'PLANE':
      return Icons.airplanemode_active;
    case 'PEOPLE':
      return Icons.people;
    case 'PERSON':
      return Icons.person;
    case 'PEN':
      return Icons.edit;
    case 'EMAIL':
      return Icons.email_outlined;
    case 'GROUP':
      return Icons.groups_outlined;
    case 'PNR':
      return Icons.view_timeline_outlined;
    case 'TICKET':
      return Icons.airplane_ticket_outlined;
    case 'BUS':
      return Icons.airport_shuttle_outlined;
    case 'BUS2':
      return Icons.directions_bus_filled_outlined;
    case 'TRAIN':
      return Icons.directions_railway_filled_outlined;
    case 'BOAT':
      return Icons.directions_boat_filled_outlined;
    case 'BIKE':
      return Icons.directions_bike;
    case 'PLANES':
      return Icons.connecting_airports_outlined;
    case 'ANCHOR':
      return Icons.anchor;
    case 'BAG':
      return Icons.cases_outlined;
    case 'CHILD':
      return Icons.child_friendly;
    case 'LOGIN':
      return Icons.login;
    case 'QUESTION':
      return Icons.question_mark;
    case 'INFO':
      return Icons.info_outline;
    case 'PHONE':
      return Icons.contact_phone_outlined;
    case 'NEWS':
      return Icons.newspaper;
    case 'HOTEL':
      return Icons.night_shelter_outlined;
    case 'HOME':
      return Icons.home;
    case 'NIGHTLIFE':
      return Icons.nightlife;

  }
  return Icons.question_mark;
}

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

Future<void> initHomePage(String fileName) async {
    logit('Open homepage ${gblSettings.gblServerFiles}$fileName');
    final jsonString = await http.get(Uri.parse('${gblSettings.gblServerFiles}$fileName'), headers: {HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.acceptEncodingHeader: 'gzip,deflate,br'}); // , HttpHeaders.acceptCharsetHeader: "utf-8"

  // need to use byte and decode here otherwise special characters corrupted !
  String data = utf8.decode(jsonString.bodyBytes);
  if( data.startsWith('{')) {
    try {
    final Map<String, dynamic> map = json.decode(data);
    gblHomeCardList = new PageListHolder.fromJson(map);
    //gblHomeCardList = new CustomePage.fromJson(map);

      logit('got home json file');
    } catch(e) {
      setError( e.toString() );
      gblErrorTitle = 'Error loading home.json';
      logit(e.toString());
    }

  } else {
    logit('home file data error ' + data.substring(0,20));
  }
}

