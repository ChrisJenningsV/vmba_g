import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/utilities/widgets/webviewWidget.dart';
import 'package:vmba/components/trText.dart';

import '../utilities/widgets/appBarWidget.dart';

class StopPageWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (gblSettings.stopUrl != null && gblSettings.stopUrl.isNotEmpty) {
      return Row(children: <Widget>[ Expanded(child: VidWebViewWidget(
          title: (gblSettings.stopTitle != null) ? gblSettings.stopTitle : translate('App Suspended'),
          canNotClose: 'true',
          url: gblSettings.stopUrl))
      ]);
    } else {
      return  Scaffold(
          appBar: appBar(context, (gblSettings.stopTitle != null) ? gblSettings.stopTitle :'App Suspended',),
          body: Container(
            color: Colors.white, constraints: BoxConstraints.expand(),
            child: Center(
              child:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TrText(gblSettings.stopMessage != null ? gblSettings.stopMessage : translate('App susspended, please try again later')),
                  ),
                  new TextButton(
                    child: new Text(
                      translate('Update Now'),
                      style: TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: gblSystemColors.primaryButtonColor,
                        side: BorderSide(
                            color: gblSystemColors.textButtonTextColor, width: 1),
                        primary: gblSystemColors.primaryButtonTextColor),
                    onPressed: () {
                      LaunchReview.launch();
                    },
                  ),

                ],
              ),
            ),
          ));

    }
  }
}
