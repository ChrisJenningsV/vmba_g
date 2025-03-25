
import 'package:flutter/material.dart';

import '../data/globals.dart';
import '../data/models/dialog.dart';
import '../dialogs/smartDialog.dart';

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

  static Widget getBodyWithBackground(BuildContext context,  String pageName, Widget body, DialogDef? curDialog) {
    List<Widget> list = [];

    //logit( 'getBWB p:$gblCurPage');

    // n.b. browser back may cause arrival here with wrong pagename
    if (gblSettings.imageBackgroundPages.contains(pageName)) {
      AssetImage img = AssetImage('lib/assets/$gblAppTitle/images/pagebg.png');
      list.add(Container(
          decoration: BoxDecoration(
              color: gblSettings.darkSiteEnabled ? Colors.black : null,
              image: DecorationImage(
                //colorFilter: gblSettings.darkSiteEnabled ? new ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop) : null,
                  image: img, fit: BoxFit.fill))));
    }
    list.add(body);
    double wb = View.of(context).viewInsets.bottom;
    //logit( 'wb = $wb');

    if (wb == 0.0) {
      if ((curDialog != null && curDialog!.pageFoot != null &&
          curDialog!.pageFoot.length > 0)) {
        list.add(Positioned(
          left: 0,
          bottom: 0,
          child: wrapFootField(context, curDialog!, curDialog!.pageFoot.first, () {}, isPageBottom: true),) );
      /*  list.add(Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: wrapFootField(
                context, curDialog!, curDialog!.pageFoot.first, () {}),
          ),
        ));*/
      }
    }

    return Stack(
      children: list,
    );

  }


}