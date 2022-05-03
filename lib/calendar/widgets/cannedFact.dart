import 'package:flutter/material.dart';
import 'package:vmba/data/models/availability.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/components/trText.dart';

class CannedFactWidget extends StatelessWidget {
  final List<Flt> flt;
  CannedFactWidget({this.flt});

  @override
  Widget build(BuildContext context) {
    if (flt.first.fltdet.canfac != null && flt.first.fltdet.canfac.fac != '') {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.info_outline),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          actions: <Widget>[
                            new TextButton(
                              child: new TrText("OK"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                          title: new TrText('Additional Info'),
                          content: SingleChildScrollView(
                            child: Wrap(
                              children: additionalInfoWidget(
                                  flt.first.fltdet.canfac.fac.trim()),
                            ),
                          ));
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Row(
                    children: <Widget>[
                      TrText("Additional Info",
                          style: new TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w300)),
                      Icon(Icons.expand_more)
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider()
        ],
      );
    } else {
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  List<Widget> additionalInfoWidget(String text) {
    List<Widget> widgets = [];
    // List<Widget>();
    if (text.contains('&lt;a href="')) {
      String startText = text.split('&lt;a href="')[0];
      String endText = text.split('&lt;/a&gt;')[1];
      String url = text.split('&lt;a href="')[1].split('"')[0];
      String linkText = text
          .toLowerCase()
          .split('&gt;&lt;u&gt;')[1]
          .toLowerCase()
          .split('&lt;/u&gt;&lt;/a&gt;')[0];

      textSpliter(startText).forEach((widget) {
        widgets.add(widget);
      });

      widgets.add(appLinkWidget(
          url,
          Text(linkText,
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w700,
              ))));
      textSpliter(endText).forEach((widget) {
        widgets.add(widget);
      });
    } else {
      widgets.add(Text(text));
    }

    return widgets;
  }
}
