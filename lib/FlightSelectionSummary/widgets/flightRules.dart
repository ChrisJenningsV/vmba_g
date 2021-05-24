import 'package:flutter/material.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/data/globals.dart';

class FlightRulesWidget extends StatefulWidget {
  final List<FQItin> fQItin;
  final List<Itin> itin;
  FlightRulesWidget({this.fQItin, this.itin});

  _FlightRulesState createState() => _FlightRulesState();
}

class _FlightRulesState extends State<FlightRulesWidget> {
  String fareIDs;
  bool _displayProcessingIndicator = true;
  List<String> fareRulesPerSegment = [];
  // List<String>();
  List<List> fareRules = [];
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

  _dataLoaded() {
    setState(() {
      _displayProcessingIndicator = false;
    });
  }

  Widget displayRules() {
    List<Widget> rulesWidget = [];
    // List<Widget>();
    fareRules.asMap().forEach((index, segment) {
      rulesWidget.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
              'Journey ${index + 1}: ${widget.itin[index].depart} ${widget.itin[index].arrive} (${widget.itin[index].classBandDisplayName})',
              style:
                  new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
        ),
      );
      segment.forEach((rule) {
        rulesWidget.add(Text(rule));
      });
    });
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
            brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: Text("Flight Rules",
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
                  child: Text('Getting the flight rules'),
                )
              ],
            ),
          ));
    } else {
      return Scaffold(
        appBar: AppBar(
          brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: Text("Flight Rules",
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
