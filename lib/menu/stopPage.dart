import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/utilities/widgets/webviewWidget.dart';
import 'package:vmba/components/trText.dart';

class StopPageWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (gblSettings.stopUrl != null && gblSettings.stopUrl.isNotEmpty) {
      return Row(children: <Widget>[ Expanded(child: WebViewWidget(
          title: 'App Suspended',
          canNotClose: 'true',
          url: gblSettings.stopUrl))
      ]);
    } else {
      return  Scaffold(
          body: Container(
            color: Colors.white, constraints: BoxConstraints.expand(),
            child: Center(
              child:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TrText('App susspended, please try again later'),
                  ),
                ],
              ),
            ),
          ));

    }
  }
}
