import 'package:flutter/material.dart';
import 'package:vmba/menu/customerfiles/faqs/faqs_lm.dart' as LM;
import 'package:vmba/menu/customerfiles/faqs/faqs_si.dart' as SI;
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/utilities/widgets/webviewWidget.dart';

import '../utilities/widgets/appBarWidget.dart';

class FAQsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: getAppBarLeft(),
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
            case 'SI':
              return SingleChildScrollView( child: SI.Faqs());
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
    return Row( children: <Widget>[ Expanded( child: VidWebViewWidget(
        title: 'FAQs',
        url: gblSettings.faqUrl))]);
  }
  }