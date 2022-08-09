import 'package:flutter/material.dart';
import '../components/vidGraphics.dart';
import '../data/models/pnr.dart';

import '../data/repository.dart';
import '../utilities/widgets/bullet_widget.dart';


class FareRulesView extends StatefulWidget {
  final List<FQItin> fQItin;
  final List<Itin> itin;
  FareRulesView({this.fQItin, this.itin});

  String currencyCode;
  _FareRulesState createState() => _FareRulesState();
}

class _FareRulesState extends State<FareRulesView> {
  String fareIDs;
  bool _displayProcessingIndicator = true;
  List<String> fareRulesPerSegment = [];
  //List<List> fareRules = [];



  @override
  Widget build(BuildContext context) {
    if (_displayProcessingIndicator) {
      return vidProcessing('Getting the flight rules');
    } else {
      List<Widget> rulesWidget = [];
      // List<Widget>();
      fareRulesPerSegment.asMap().forEach((index, segment) {
        rulesWidget.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
                'Journey ${index + 1}: ${widget.itin[index].depart} ${widget.itin[index].arrive} (${widget.itin[index].classBandDisplayName})',
                style:
                new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
          ),
        );

        rulesWidget.add(BulletList(segment.replaceAll('- ', '').split('<br>')));

      });
      return SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rulesWidget,
        ),
      );    }
  }


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

    for (FQItin f in widget.fQItin) {
      _fareID = f.fQI
          .replaceAll('S', '')
          .replaceAll('I', "")
          .replaceAll("T", "")
          .replaceAll("O", "")
          .trim();
      await Repository.get()
          .getFareRules(_fareID)
          .then((result) => fareRulesPerSegment.addAll(result.body));
         /* .then((_) {
        fareRules.add(fareRulesPerSegment);*/
      }
    }


  _dataLoaded() {
    setState(() {
      _displayProcessingIndicator = false;
    });
  }

}
