import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';
import 'dart:developer';

bool LogginOn = false;

class TrText extends StatelessWidget {
  final String labelText;
  final TextStyle style;
  final String variety;
  final bool noTrans;
  final TextAlign textAlign;
  final double textScaleFactor;
  final int maxLines;

  TrText(this.labelText,  {this.style, this.variety, this.noTrans, this.textAlign, this.textScaleFactor, this.maxLines});

  build(BuildContext context) {
    var txt = labelText;

    if( gblLangMap != null && noTrans != true) {
      if (gblLanguage != 'en' || gblSettings.wantEnglishTranslation ) {
        var testTxt = '';
        if( variety == 'title' && gblIsLive == false) {
            if( gblLangMap['Test Mode: '] != null && gblLangMap['Test Mode: '].isNotEmpty ) {
              testTxt = gblLangMap['Test Mode: '];
            } else {
              testTxt = 'Test Mode: ';
            }
        }


        var txt2 = gblLangMap[labelText];
        if (txt2 != null &&
            txt2.toString().isNotEmpty) {
          txt = testTxt + txt2;
        } else {
          //var msg = 'need trans for "$txt"';
          var msg = ' "$txt": ""';
          //print(msg);
          if( LogginOn) log(msg);
        }
      }
    }

    if( variety != null &&  variety.isNotEmpty) {
      double width = MediaQuery.of(context).size.width;
      Color clr = style.color;
      double fSize = style.fontSize ;

      switch (variety) {
        case 'airport':
          // scale text to fit half width
          if( txt.length > 18) {
            if( width < 380 ) {
              fSize = 8.0;
            } else if( width < 360)  {
              fSize = 10.0;
            }
          } else if( txt.length > 12) {
            if( width < 380 ) {
             fSize = 12.0;
            } else if( width < 360)  {
              fSize = 14.0;
            }
          }
          break;
      }
      return Text( txt ,style: TextStyle(color: clr, fontSize:  fSize), textAlign: textAlign, textScaleFactor: textScaleFactor, maxLines: maxLines,);
    } else {
      return Text( txt ,style: style, textAlign: textAlign, textScaleFactor: textScaleFactor, maxLines: maxLines,);
    }
  }
}
String translate( String str ) {
 /* if (gblLanguage == 'en') {
    return str;
  }*/

  if( gblLangMap != null && gblLangMap[str] != null && gblLangMap[str].isNotEmpty ) {
    return gblLangMap[str];
  }
  var msg = ' "$str": ""';
  //print(msg);
  if( LogginOn) log(msg);
  return str;
}
