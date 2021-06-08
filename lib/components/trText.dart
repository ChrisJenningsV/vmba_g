import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';

class TrText extends StatelessWidget {
  final String labelText;
  TextStyle style;
  String variety;
  bool noTrans;

  TrText(this.labelText,  {this.style, this.variety, this.noTrans});

  build(BuildContext context) {
    var txt = labelText;

    if( gblLangMap != null && noTrans != true) {
      if (gblLanguage != 'en') {
        var testTxt = '';
        if( variety == 'title' && gblIsLive == false) {
            if( gblLangMap['Test Mode: ']) {
              testTxt = gblLangMap['Test Mode: '];
            } else {
              testTxt = 'Test Mode: ';
            }
        }


        var txt2 = gblLangMap[txt];
        if (txt2 != null &&
            txt2.toString().isNotEmpty) {
          txt = testTxt + txt2;
        } else {
          var msg = 'need trans for $txt';
          print(msg);
        }
      }
    }

    if( variety != null &&  variety.isNotEmpty) {
      double width = MediaQuery.of(context).size.width;
      Color clr = style.color;
      double fSize = 16.0;

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
      return Text( txt ,style: TextStyle(color: clr, fontSize:  fSize));
    } else {
      return Text( txt ,style: style);
    }
  }
}
String translate( String str ) {
  if( gblLangMap != null ) {
    return gblLangMap[str];
  }
  return str;
}
