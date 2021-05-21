import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/utilities/widgets/webviewWidget.dart';

class AdsPage extends StatefulWidget {
  AdsPage();

  @override
  _AdsPageState createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar:
        appBar(context, 'Air Discount Scheme',
        ),
        body: Row( children: <Widget>[
          Expanded( child: WebViewWidget(
    title: 'FAQs',
        url: gbl_settings.adsTermsUrl)),
          ElevatedButton(
              onPressed:() {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/MyBookingsPage', (Route<dynamic> route) => false);},
              child: TrText('Accept'))
    ]));  }
  }