
import 'package:flutter/material.dart';

import '../data/globals.dart';
import '../utilities/helper.dart';

class ImageManager{
  static DecorationImage getNetworkImage(String url, {double? opacity}){
    return DecorationImage(
      opacity: 0.7,
      image: NetworkImage(url),
      fit: BoxFit.cover,
    );
  }

  static getPageBack() {

  }

  static Widget getBodyWithBackground( String pageName, Widget body){
    List<Widget> list = [];

    //logit( 'getBWB p:$gblCurPage');

    // n.b. browser back may cause arrival here with wrong pagename
    if( gblSettings.imageBackgroundPages.contains(pageName)){
      AssetImage img = AssetImage('lib/assets/$gblAppTitle/images/pagebg.png');
      list.add(Container(
          decoration: BoxDecoration(
              color: gblSettings.darkSiteEnabled ?Colors.black : null,
              image: DecorationImage(
                  //colorFilter: gblSettings.darkSiteEnabled ? new ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop) : null,
                  image: img, fit: BoxFit.fill))));
    }
    list.add(body);
    return Stack(
      children: list,
    );

  }


}