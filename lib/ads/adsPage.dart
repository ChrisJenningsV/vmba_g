import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
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
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton:   Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: gblSystemColors.primaryButtonColor,
              ),
          onPressed:() {
            gblIsAds = true;
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/FlightSearchPage', (Route<dynamic> route) => false);},
          child: TrText('Accept', style: new TextStyle(color: gblSystemColors.primaryButtonTextColor),)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.grey,
              ),
              onPressed:() {
                gblIsAds = false;
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/HomePage', (Route<dynamic> route) => false);
              },
              child: TrText('Cancel', style: new TextStyle(color: Colors.black),)),

        ]),
        body: Row( children: <Widget>[
          Expanded( child: WebViewWidget(
    title: 'Air Discount Scheme',
        url: gbl_settings.adsTermsUrl)),

    ]));  }
  }