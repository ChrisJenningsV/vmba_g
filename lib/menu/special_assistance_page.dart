import 'package:flutter/material.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

import '../utilities/widgets/appBarWidget.dart';

class SpecialAssistancePage extends StatelessWidget {
  List<Widget> render() {
    List<Widget> widgets = [];
    // List<Widget>();

    textSpliter(
            translate('If you need a little more help when travelling, we’ll do our best to ensure that help is on hand. Please call us on'))
        .forEach((widget) {
      widgets.add(widget);
    });
    widgets.add(appLinkWidget(
        'tel',
        '0344-000-0000',
        Text('0344 000 0000 ',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));
    textSpliter('to arrange assistance or email').forEach((widget) {
      widgets.add(widget);
    });

    widgets.add(appLinkWidget(
        'mailto',
        'customercare@videcom.com?subject=assistance',
        Text('customercare@videcom.com',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));
    // widgets.add(
    //   Padding(
    //     padding: EdgeInsets.all(8),
    //   ),
    // );
    // textSpliter(
    //         'We require at least 48 hours’ notice to ensure everything is arranged prior to your arrival at the airport.')
    //     .forEach((widget) {
    //   widgets.add(widget);
    // });
    return widgets;
  }

  List<Widget> renderSI() {
    List<Widget> widgets = [];
    // List<Widget>();

    textSpliter(
            'If you need a little more help when travelling, we’ll do our best to ensure that help is on hand. Please call us on')
        .forEach((widget) {
      widgets.add(widget);
    });
    widgets.add(appLinkWidget(
        'tel',
          '01234-589200',
        Text('01234 589200 ',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));
    textSpliter('to arrange assistance or email').forEach((widget) {
      widgets.add(widget);
    });

    widgets.add(appLinkWidget(
        'mailto',
          'customercare@blueislands.com',
        Text('customercare@blueislands.com',
            style: TextStyle(
              decoration: TextDecoration.underline,
            )),
      queryParameters: {'subject':'assistance'}
    ));

    return widgets;
  }

  List<Widget> renderLM() {
    List<Widget> widgets = [];
    // List<Widget>();

    textSpliter(
            'If you need a little more help when travelling, we’ll do our best to ensure that help is on hand. Please call us on')
        .forEach((widget) {
      widgets.add(widget);
    });
    widgets.add(appLinkWidget(
        'tel',
        '0344-800-2855',
        Text('0344 800 2855 ',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));
    textSpliter('to arrange assistance or email').forEach((widget) {
      widgets.add(widget);
    });

    widgets.add(appLinkWidget(
        'mailto',
        'bookings@loganair.co.uk',
        Text('bookings@loganair.co.uk',
            style: TextStyle(
              decoration: TextDecoration.underline,
            )),
      queryParameters: {'subject':'assistance'}
    )
    );
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: getAppBarLeft('ASSISTANCE'),
        backgroundColor: gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: Text('Special Assistance',
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
        child: Column(
            children: (() {
          switch (gblSettings.aircode) {
            case 'LM':
              return <Widget>[
                Wrap(
                  children: renderLM(),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                ),
                Text(
                    'We require at least 48 hours’ notice to ensure everything is arranged prior to your arrival at the airport.'),
              ];

            case 'SI':
              return <Widget>[
                Wrap(
                  children: renderSI(),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                ),
                Text(
                    'We require at least 48 hours’ notice to ensure everything is arranged prior to your arrival at the airport.'),
              ];
            case 'T6':
              return <Widget>[
                Padding(
                  padding: EdgeInsets.all(8),
                ),
              ];
            default:
              return <Widget>[
                Wrap(
                  children: render(),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                ),
                Text(
                    'We require at least 48 hours’ notice to ensure everything is arranged prior to your arrival at the airport.'),
              ];
          }
        }())),
      ),
    );
  }
}
