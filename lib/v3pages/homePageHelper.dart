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
    String jsonString = await await rootBundle.loadString('lib/assets/$gblAppTitle/json/home.json');

    final Map<String, dynamic> map = json.decode(jsonString);
    gblHomeCardList = new PageListHolder.fromJson(map);
  }
}

class PageListHolder {
  Map? pages;
  //List<CustomePage>? pages;
  String version ='';

  PageListHolder.fromJson(Map<String, dynamic> json) {
    if( json['version'] != null ) version =  json['version'];

    if (json['pages'] != null) {
      pages = new Map();
      //new List<Country>();
      json['pages'].forEach((n, v) {
        pages![n] =new CustomPage.fromJson(v);
      });
    }
  }

}

class CustomPage {
  List<HomeCard>? cards;
  String pageName = '';
  CardText? title;
  double topPadding = 40;
  double bottomPadding = 10;
  Color? backgroundColor = Colors.white;
  String backgroundImage = '';

  CustomPage({this.cards});

  CustomPage.fromJson(Map<String, dynamic> json) {
    if( json['topPadding'] != null ) topPadding =  double.parse(json['topPadding']);
    if( json['bottomPadding'] != null ) bottomPadding =  double.parse(json['bottomPadding']);
    if( json['backgroundColor'] != null ) backgroundColor = lookUpColor( json['backgroundColor'].toString());
    if( json['backgroundImage'] != null ) backgroundImage = json['backgroundImage'];

    if( json['title'] != null ) {
      if( json['title'] is Map) {
        title = CardText.fromJson('Home', json['title']);
      } else {
        title = new CardText('Home', text: json['title']);
      }
    }

    if (json['cards'] != null) {
      cards = [];
      //new List<Country>();
      json['cards'].forEach((v) {
        HomeCard c = new HomeCard.fromJson(v);
        if( c.title != null ) {
          logit('ttl ${c.title!.text} bgclr ${c.title!.backgroundColor}');
        }
        cards?.add(c);
      });
    }
  }
}
class HomeCard extends HomeCardLink  {

  IconData? icon;
  String image='';
  double height = 0;
  double fontSize = 0;
  bool expanded = true;
  double cornerRadius= 10;

  List<HomeCard>? cards;
  List<HomeCardLink>? links;


  HomeCard();

  HomeCard.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if( json['card_type'] != null ) card_type = json['card_type'];

    /*if( json['title'] != null ) {
      if( json['title'] is Map) {
        title = CardText.fromJson(card_type, json['title']);
      } else {
        title = new CardText(card_type, text: json['title']);
      }
    }*/
    if( json['expanded'] != null ) expanded = parseBool(json['expanded']);
    if( json['icon'] != null && json['icon'] != '' &&  json['icon'] != 'none') {
      icon = getIconFromName(json['icon'].toString());
    }
      if( json['image'] != null ) image = json['image'];
      if( json['url'] != null ) url = json['url'];
      if( json['height'] != null ) height = double.parse(json['height']);
      if( json['fontSize'] != null ) fontSize = double.parse(json['fontSize']);
      if( json['cornerRadius'] != null ){
        if( int.parse(json['cornerRadius']) < 50) {
          cornerRadius = double.parse(json['cornerRadius']);
        }
      }

      if (json['cards'] != null) {
        cards = [];
        //new List<Country>();
        json['cards'].forEach((v) {
          cards?.add(new HomeCard.fromJson(v));
        });
      }
    if (json['links'] != null) {
      links = [];
      //new List<Country>();
      json['links'].forEach((v) {
        links?.add(new HomeCardLink.fromJson(v));
      });
    }
    }
  }

class HomeCardLink {
  String url='';
  CardAction? action;
  String destination='';
  CardText? title;
  String card_type='';

  HomeCardLink();

  HomeCardLink.fromJson(Map<String, dynamic> json) {
    if( json['action'] != null ) {
      action = CardAction.fromJson(json['action']);
    }
      if( json['destination'] != null ) destination = json['destination'];

      if( json['title'] != null ) {
        if( json['title'] is Map) {
          title = CardText.fromJson(card_type, json['title']);
          logit('ttl ${title!.text} bgclr ${title!.backgroundColor}');
        } else {
          title = new CardText(card_type, text: json['title']);
        }
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
    if (json['function'] != null) function = json['function'];
    if (json['pageName'] != null) pageName = json['pageName'];
    if (json['fileName'] != null) fileName = json['fileName'];
    if (json['url'] != null) url = json['url'];

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
    this.card_type = card_type;
    if (json['text'] != null) text = json['text'];
    if (json['fontSize'] != null) fontSize = double.parse(json['fontSize']);

      if( json['fontWeight'] != null ){
        if(json['fontWeight'].toString().toUpperCase().contains('BOLD')) {
          fontWeight = FontWeight.bold;
        } else if(json['fontWeight'].toString().toUpperCase().contains('100')) {
          fontWeight = FontWeight.w100;
        } else if(json['fontWeight'].toString().toUpperCase().contains('200')) {
          fontWeight = FontWeight.w200;
        } else if(json['fontWeight'].toString().toUpperCase().contains('300')) {
          fontWeight = FontWeight.w300;
        } else if(json['fontWeight'].toString().toUpperCase().contains('400')) {
          fontWeight = FontWeight.w400;
        } else if(json['fontWeight'].toString().toUpperCase().contains('500')) {
          fontWeight = FontWeight.w500;
        } else if(json['fontWeight'].toString().toUpperCase().contains('600')) {
          fontWeight = FontWeight.w600;
        } else if(json['fontWeight'].toString().toUpperCase().contains('700')) {
          fontWeight = FontWeight.w700;
        } else if(json['fontWeight'].toString().toUpperCase().contains('800')) {
          fontWeight = FontWeight.w800;
        } else if(json['fontWeight'].toString().toUpperCase().contains('900')) {
          fontWeight = FontWeight.w900;

        }
      }
      if (json['color'] != null){
        if( json['color'].toString().startsWith('#')) {
          color = json['color'].toString().toColor();
        } else {
          // look up color name
          color =lookUpColor( json['color'].toString());
        }
      }
      if( json['backgroundColor'] != null ) {
        logit('fromJ $text got bgClr ${json['backgroundColor']}');

        if( json['backgroundColor'].toString().startsWith('#')) {
          backgroundColor = json['backgroundColor'].toString().toColor();
        } else {
          backgroundColor = lookUpColor(json['backgroundColor'].toString());
        }
        logit('fromJ $text got bgClr $backgroundColor');
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
        break;
      case 'PHOTOLINK':
        fontS = 20;
        clr = Colors.white;
        break;
      default:
        fontS = 20;
        clr = Colors.grey;
        break;
    }
    if(fontSize != 0) fontS = fontSize;
    if( color != null ) clr = color as Color;
    TextStyle ts = TextStyle(fontSize: fontS, color: clr);

    return ts;
  }
}

Color lookUpColor(String colorName){
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