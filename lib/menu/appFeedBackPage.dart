import 'package:flutter/material.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/settingsData.dart';
import 'package:vmba/resources/app_config.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

class AppFeedBackPage extends StatefulWidget {
  AppFeedBackPage({Key key, this.version}) : super(key: key);
  final String version;

  _AppFeedBackPageState createState() => _AppFeedBackPageState();
}

class _AppFeedBackPageState extends State<AppFeedBackPage> {
  List<Widget> render() {
    List<Widget> widgets = [];
    // List<Widget>();
    String email;

    email = gbl_settings.appFeedbackEmail;

    textSpliter(
            'We’re interested in how we can improve our app. Please email specific app feedback to')
        .forEach((widget) {
      widgets.add(widget);
    });
    widgets.add(appLinkWidget(
        'mailto:' + email + '?subject=AppFeedback ' + widget.version,
        Text(email,
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));

    return widgets;
  }

  bool _displayProcessingIndicator;
  String _displayProcessingText = 'Changing settings...';
  GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  initState() {
    super.initState();
    _displayProcessingIndicator = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_displayProcessingIndicator) {
      return Scaffold(
        key: _key,
        appBar: new AppBar(
          leading: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Image.asset(
                  'lib/assets/${gblAppTitle}/images/appBarLeft.png',
                  color: Color.fromRGBO(255, 255, 255, 0.1),
                  colorBlendMode: BlendMode.modulate)),
          brightness: gbl_SystemColors.statusBar,
          backgroundColor:
          gbl_SystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gbl_SystemColors.headerTextColor),
          title: new TrText('App Feedback',
              style: TextStyle(
                  color:
                  gbl_SystemColors.headerTextColor)),
        ),
        body: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(_displayProcessingText),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Image.asset(
                  'lib/assets/${gblAppTitle}/images/appBarLeft.png',
                  color: Color.fromRGBO(255, 255, 255, 0.1),
                  colorBlendMode: BlendMode.modulate)),
          brightness: gbl_SystemColors.statusBar,
          backgroundColor:
          gbl_SystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gbl_SystemColors.headerTextColor),
          title: TrText('App Feedback',
              style: TextStyle(
                  color:
                  gbl_SystemColors.headerTextColor)),
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
            children: <Widget>[
              Wrap(
                children: render(),
              ),
              Padding(
                padding: EdgeInsets.all(8),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TrText('App version: ' + widget.version),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onLongPress: () async {
                    setState(() {
                      _displayProcessingIndicator = true;
                    });
                    await updateSettings();
                  },
                  child: null,
                  onPressed: () {},
                ),
              )
            ],
          ),
        ),
      );
    }
    // });
  }

  void processCompleted() {
    setState(() {
      _displayProcessingIndicator = false;
    });
  }

  Future updateSettings() async {
    Repository.get().getUserProfile().then((userProfileRecordList) async {
      String firstName;
      if (userProfileRecordList.length > 0) {
        firstName = userProfileRecordList
            .firstWhere((v) => v.name == 'firstname')
            .value;
        if (firstName == 'TEST') {
          GobalSettings.shared.setToTest();
          await Repository.get().getSettingsFromApi();
          await Repository.get()
              .database
              .saveAllSettings(gbl_settings);
        } else if (firstName == 'LIVE') {
          GobalSettings.shared.setToLive();
          await Repository.get().getSettingsFromApi();
          await Repository.get()
              .database
              .saveAllSettings(gbl_settings);
        } else if (firstName == 'CLEAR') {
          await Repository.get().database.deleteAllSettings();
        }
      } else {
        processCompleted();
      }
    }).then((_) => processCompleted());
  }
}
