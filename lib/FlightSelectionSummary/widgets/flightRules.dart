import 'package:flutter/material.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

import '../../utilities/helper.dart';
import '../../utilities/widgets/bullet_widget.dart';

class FlightRulesWidget extends StatefulWidget {
  final List<FQItin> fQItin;
  final List<Itin> itin;
  FlightRulesWidget({this.fQItin = const [], this.itin = const []});

  _FlightRulesState createState() => _FlightRulesState();
}

class _FlightRulesState extends State<FlightRulesWidget> {
  String fareIDs = '';
  bool _displayProcessingIndicator = true;
 // List<String> fareRulesPerSegment = [];
  List<List> fareRulesPerSegment = [];
  // List<String>();
  //List<List> fareRules = [];
  // List<List>();

  @override
  initState() {
    super.initState();
    _displayProcessingIndicator = true;
    loadRules();
  }

  loadRules() {
    getFareRulesIds().then((_) => _dataLoaded());
  }

  getFareRulesIds() async {
    String _fareID;
    String _segment;

    for (FQItin f in widget.fQItin) {
      _segment = f.seg;
      _fareID = f.fQI
          .replaceAll('S', '')
          .replaceAll('I', "")
          .replaceAll("T", "")
          .replaceAll("O", "")
          .trim();
      await Repository.get()
          .getFareRules(_fareID)
          .then((result) {
        int seg = int.parse(_segment);
        logit('rules for $seg fareID $_fareID');
        while( seg > fareRulesPerSegment.length){
          List<String> list = [];
          fareRulesPerSegment.add(list);
        }
        logit(' add to seg ${seg-1} cur len= ${fareRulesPerSegment.length} body=${result.body}');
        fareRulesPerSegment[seg -1].addAll(result.body!);
        /*if( result.body == null || result.body == '' || result.body!.length == 0 ) {
          fareRulesPerSegment[seg -1].add('no fare rules for segment $seg');
        } else {

          String str = result.body![0];
          if( str.contains('<br>')) {
            List<String> str2 = str.split('<br>');
            fareRulesPerSegment[seg - 1].addAll(
                str2);
          } else {
            fareRulesPerSegment[seg - 1].add(
                str); // result.body as List<String>
          }
        }*/
      });

      /* .then((_) {
        fareRules.add(fareRulesPerSegment);*/
    }
  }

  /*getFareRulesIds() async {
    String _fareID;

    for (FQItin f in widget.fQItin) {
      _fareID = f.fQI
          .replaceAll('S', '')
          .replaceAll('I', "")
          .replaceAll("T", "")
          .replaceAll("O", "")
          .trim();
      await Repository.get()
          .getFareRules(_fareID)
          .then((result) => fareRulesPerSegment.addAll(result.body))
          .then((_) {
        fareRules.add(fareRulesPerSegment);
      });
    }
  }
*/
  _dataLoaded() {
    setState(() {
      _displayProcessingIndicator = false;
    });
  }

  Widget displayRules() {
    List<Widget> rulesWidget = [];

    if(  fareRulesPerSegment.length == 0 ) {
      rulesWidget.add(TrText('No rules found'));
    } else {
      fareRulesPerSegment.asMap().forEach((index, list) {
        rulesWidget.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Text(
                'Journey ${index + 1}: ${widget.itin[index].depart} ${widget
                    .itin[index].arrive} (${widget.itin[index]
                    .classBandDisplayName})',
                style:
                new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
          ),
        );
        //list.forEach((element) {
        List<String> copyList = [];
        list.forEach((element) {
          copyList.add(element.replaceAll('- ', ''));
        });
        rulesWidget.add(
            BulletList(copyList));
      });
          }
        //});
    // List<Widget>();
 /*   fareRules.asMap().forEach((index, segment) {
      rulesWidget.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
              'Journey ${index + 1}: ${widget.itin[index].depart} ${widget.itin[index].arrive} (${widget.itin[index].classBandDisplayName})',
              style:
                  new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
        ),
      );

*//*
      segment.forEach((rule) {
        rulesWidget.add(Text(rule));
      });
*//*
      rulesWidget.add(BulletList(segment));

    });*/


    return SingleChildScrollView(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rulesWidget,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_displayProcessingIndicator) {
      return Scaffold(
          appBar: AppBar(
            //brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: TrText("Flight Rules",
                style: TextStyle(
                    color: gblSystemColors
                        .headerTextColor)),
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TrText('Getting the flight rules'),
                )
              ],
            ),
          ));
    } else {
      return Scaffold(
        appBar: AppBar(
          //brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: TrText("Flight Rules",
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
        body: displayRules(),
      );
    }
  }
}
