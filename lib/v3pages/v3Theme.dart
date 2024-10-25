import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Helpers/settingsHelper.dart';
import '../components/trText.dart';
import '../data/globals.dart';
import '../utilities/helper.dart';
import 'homePageHelper.dart';

class V3Theme {
  V3Theme();

  late V3Calendar calendar = new V3Calendar();
  late V3Generic generic = new V3Generic();
  late V3BottomNavBar bottomNavBar = new V3BottomNavBar();
  String version = '';

  V3Theme.fromJson(Map<String, dynamic> json) {
    if(json['version'] != null ) version = json['version'];

    if( json['calendar'] != null ) calendar = V3Calendar.fromJson(json['calendar']);
    if( json['generic'] != null ) generic = V3Generic.fromJson(json['generic']);
    if( json['bottomNavBar'] != null ) bottomNavBar = V3BottomNavBar.fromJson(json['bottomNavBar']);
  }

}

class V3Input {
  V3Input();

}

class V3BottomNavBar{
  V3BottomNavBar();

  V3BottomNavBar.fromJson(Map<String, dynamic> json) {
   // if (json['setStatusBarColor'] != null) setStatusBarColor = bool.parse(json['setStatusBarColor']);
    //if( json['centerTitleText'] != null) centerTitleText = bool.parse(json['centerTitleText']);
  }
}
class V3NavBarButton {

}

class V3Generic {
  V3Generic();
  bool setStatusBarColor = false;
  bool centerTitleText = false;
  bool? actionButtonIcons;
  Color? actionButtonColor;
  double? actionButtonRadius;
  double? actionButtonPadding;
  bool actionButtonShadow = false;

  V3Generic.fromJson(Map<String, dynamic> json) {
    if (json['setStatusBarColor'] != null) setStatusBarColor = bool.parse(json['setStatusBarColor']);
    if( json['centerTitleText'] != null) centerTitleText = bool.parse(json['centerTitleText']);
    if( json['actionButtonIcons'] != null) actionButtonIcons = bool.parse(json['actionButtonIcons']);
    if( json['actionButtonShadow'] != null) actionButtonShadow = bool.parse(json['actionButtonShadow']);
    if( json['actionButtonColor'] != null ) actionButtonColor = lookUpColor(json['actionButtonColor']);
    if( json['actionButtonRadius'] != null ) actionButtonRadius = double.tryParse(json['actionButtonRadius']);
    if( json['actionButtonPadding'] != null ) actionButtonPadding = double.tryParse(json['actionButtonPadding']);

  }
}


class V3Calendar {

  V3Calendar();

  // set default colors
  Color backColor = Color.fromRGBO(0XF0, 0xF0, 0xF0, 1);
  Color textColor = Colors.black;
  Color selectableColor = Color.fromRGBO(0XCA, 0xCA, 0xCA, 0.5);
  Color disabledColor = Color.fromRGBO(0XE0, 0xE0, 0xE0, 0.5);

  late Color selectedBackColor = Colors.red;
  late Color selectedTextColor = Colors.white;

  V3Calendar.fromJson(Map<String, dynamic> json) {
      if(json['backColor'] != null ) backColor = lookUpColor(json['backColor']);
      if(json['textColor'] != null ) textColor = lookUpColor(json['textColor']);
      if(json['selectedBackColor'] != null ) selectedBackColor = lookUpColor(json['selectedBackColor']);
      if(json['selectedTextColor'] != null ) selectedTextColor = lookUpColor(json['selectedTextColor']);
      if(json['selectableColor'] != null ) selectableColor = lookUpColor(json['selectableColor']);
      if(json['disabledColor'] != null ) disabledColor = lookUpColor(json['disabledColor']);
  }
}

Future<void> loadTheme() async {
  try {
    // load theme from json file (Asset or server)
    String jsonString = await rootBundle.loadString(
        'lib/assets/$gblAppTitle/json/theme.json');

    final Map<String, dynamic> map = json.decode(jsonString);
    gblV3Theme = V3Theme.fromJson(map);

    // try network file
    try {
      loadNetTheme('theme.json');
    } catch(e) {
    }
  } catch(e) {
    // use defaults
    gblV3Theme = new V3Theme();
  }

}
Future<void> loadNetTheme(String fileName) async {
  final jsonString = await http.get(Uri.parse('${gblSettings.gblServerFiles}$fileName'), headers: {HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.acceptEncodingHeader: 'gzip,deflate,br'}); // , HttpHeaders.acceptCharsetHeader: "utf-8"

  // need to use byte and decode here otherwise special characters corrupted !
  String data = utf8.decode(jsonString.bodyBytes);
  if( data.startsWith('{')) {
    try {
      final Map<String, dynamic> map = json.decode(data);
      gblV3Theme = V3Theme.fromJson(map);
    } catch(e) {
      gblErrorTitle = 'Error loading home.json';
    }

  } else {
 //   logit('home file data error ' + data.substring(0,20));
  }
}

Widget V3CityDivider(){
  if( gblSettings.wantCityDividers == false ) return Container();
  return Divider(height: 15, thickness: 1,);
}
Widget V3Divider(){
  return Divider(height: 15, thickness: 1,);
}

Widget V3VertDivider({Color? color}) {

  return SizedBox(
    //height: 50,
    child: Center(
      child: Container(
        height: 50,
        margin: EdgeInsetsDirectional.only(start: 3, end: 3),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color == null ? Colors.black: color ,
                width: v2BorderWidth(),
            ),
            //left: BorderSide(color: v2BorderColor(), width: v2BorderWidth()),
          ),
        ),
      ),
    ),
  );
}


Row V3ItemPriceRow(String title, String code, double amount){
  return V3ItemRow(title, formatPrice(code, amount));
}
Row V3ItemRow(String title, String text){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      TrText(title),
      Text(text),
    ],
  );
}
late TextStyle  _displayLarge;
late TextStyle  _displayMedium;
late TextStyle  _displaySmall;
late TextStyle  _headlineMedium;
late TextStyle  _headlineLarge;
late TextStyle  _headlineSmall;
late TextStyle  _titleLarge;
late TextStyle  _titleMedium;
late TextStyle  _titleSmall;
late TextStyle  _labelLarge;
late TextStyle  _labelMedium;
late TextStyle  _labelSmall;
late TextStyle  _bodyMedium;
late TextStyle  _bodyLarge;
late TextStyle  _bodySmall;
bool _thimesInited = false;
void initThemes(BuildContext context) {
  if( _thimesInited == true ) return;
  _thimesInited = true;

  _displayLarge = Theme.of(context).textTheme.displayLarge!;
  _displayMedium = Theme.of(context).textTheme.displayMedium!;
  _displaySmall = Theme.of(context).textTheme.displaySmall!;
  _headlineLarge = Theme.of(context).textTheme.headlineLarge!;
  _headlineMedium = Theme.of(context).textTheme.headlineMedium!;
  _headlineSmall = Theme.of(context).textTheme.headlineSmall!;
  _titleLarge = Theme.of(context).textTheme.titleLarge!;
  _titleMedium = Theme.of(context).textTheme.titleMedium!;
  _titleSmall = Theme.of(context).textTheme.titleSmall!;
  _labelLarge = Theme.of(context).textTheme.labelLarge!;
  _labelMedium = Theme.of(context).textTheme.labelMedium!;
  _labelSmall = Theme.of(context).textTheme.labelSmall!;
  _bodyLarge = Theme.of(context).textTheme.bodyLarge!;
  _bodyMedium = Theme.of(context).textTheme.bodyMedium!;
  _bodySmall = Theme.of(context).textTheme.bodySmall!;
}

TextStyle v3LabelSmall(){
  return _labelSmall;
}

enum TextSize { small, medium, large }


class VBodyText extends Text {
  TextSize size;
  Color? color;
  bool wantTranslate;

  VBodyText(super.data, {this.size = TextSize.medium, this.color, this.wantTranslate = false});

  build(BuildContext context){
    TextStyle style;

    switch( this.size){
      case TextSize.small:
        style = _bodySmall;
        break;
      case TextSize.large:
        style = _bodyLarge;
        break;

      default:
        style = _bodyMedium;
        break;
    }
    if(color != null  ) {
      style = style.copyWith(color: color);
    }
    String text = data as String ;
    if( wantTranslate) text = translate(text);
    return Text(text, style: style,);
  }
}
class VHeadlineText extends Text {
  TextSize size;
  Color? color;
  bool wantTranslate;
  VHeadlineText(super.data, {this.size = TextSize.medium, this.color, this.wantTranslate = true});

  build(BuildContext context){
    TextStyle style;
    String text = data as String ;
    if( wantTranslate) text = translate(text);

    switch( this.size){
      case TextSize.small:
        style = _headlineSmall;
        break;
      case TextSize.large:
        style = _headlineLarge;
        break;

      default:
        style = _headlineMedium;
        break;
    }
    if(color != null  ) {
      style = style.copyWith(color: color);
    }
    return Text(text, style: style,);
  }
}
class VTitleText extends Text {
  TextSize size;
  Color? color;
  bool translate;

  VTitleText(super.data, {this.size = TextSize.medium, this.color, this.translate = false});

  build(BuildContext context){
    TextStyle style;

    switch( this.size){
      case TextSize.small:
        style = _titleSmall;
        break;
      case TextSize.large:
        style = _titleLarge;
        break;

      default:
        style = _titleMedium;
        break;
    }
    if(color != null  ) {
      style = style.copyWith(color: color);
    }
    return Text(data!, style: style,);
  }
}
class VButtonText extends Text {
  Color? color;
  bool wantTranslate;
  VButtonText(super.data, { this.color, this.wantTranslate = true});

  build(BuildContext context){
    TextStyle style;
    String text = data as String ;
    if( wantTranslate) text = translate(text);

    style = _titleMedium;
    if(color != null  ) {
      style = style.copyWith(color: color);
    }
    return Text(text, style: style,);
  }
}