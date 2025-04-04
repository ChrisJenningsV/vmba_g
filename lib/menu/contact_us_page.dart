import 'package:flutter/material.dart';
import 'package:vmba/menu/customerfiles/contact_us/contact_us.dart' as Default;
import 'package:vmba/menu/customerfiles/contact_us/contact_us_lm.dart' as LM;
import 'package:vmba/menu/customerfiles/contact_us/contact_us_si.dart' as SI;
import 'package:vmba/menu/customerfiles/contact_us/contact_us_t6.dart' as T6;
import 'package:vmba/data/globals.dart';
import 'package:vmba/utilities/widgets/webviewWidget.dart';
import 'package:vmba/components/trText.dart';

import '../utilities/widgets/appBarWidget.dart';


class ContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: getAppBarLeft('CONTACTUS'),
        backgroundColor: gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: TrText('Contact Us',
            style: TextStyle(
                color: gblSystemColors.headerTextColor)),
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
                return LM.ContactUs();

              case 'SI':
                return SI.ContactUs();
              case 'T6':
                return T6.ContactUs();
              default:
                return Default.ContactUs();
            }
          }())),
    );
  }
}
class ContactUsPageWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row( children: <Widget>[ Expanded( child: VidWebViewWidget(
        title: 'Contact Us',
        url: gblSettings.contactUsUrl))]);
  }
}


class CustomPageWeb extends StatelessWidget {
  CustomPageWeb(this.title, this.url);
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Row( children: <Widget>[ Expanded( child: VidWebViewWidget(
        title: title,
        url: url))]);
  }
}