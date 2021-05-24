import 'package:flutter/material.dart';
import 'package:vmba/menu/customerfiles/faqs/faqs_lm.dart' as LM;
import 'package:vmba/menu/customerfiles/faqs/faqs_si.dart' as SI;
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/utilities/widgets/webviewWidget.dart';

class FAQsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Image.asset(
                'lib/assets/$gblAppTitle/images/appBarLeft.png',
                color: Color.fromRGBO(255, 255, 255, 0.1),
                colorBlendMode: BlendMode.modulate)),
        brightness: gblSystemColors.statusBar,
        backgroundColor: gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: TrText('FAQs',
            style: TextStyle(
                color:
                gblSystemColors.headerTextColor)),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 16, 8, 8),
        child: (() {
          switch (gblSettings.aircode) {
            case 'LM':
              return SingleChildScrollView( child: LM.Faqs());
              break;
            case 'SI':
              return SingleChildScrollView( child: SI.Faqs());
              break;
/*            case 'T6':
              return T6.Faqs();
              break;
              */
            default:
              return Text("Error");
          }
        }()),
      ),
    );
  }
}

class FAQsPageWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row( children: <Widget>[ Expanded( child: WebViewWidget(
        title: 'FAQs',
        url: gblSettings.faqUrl))]);
  }
  }