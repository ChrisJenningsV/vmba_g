import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/home/home_page.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:package_info/package_info.dart';
//import 'package:vmba/utilities/helper.dart';
import 'package:vmba/menu/stopPage.dart';
import 'package:vmba/menu/updatePage.dart';
import 'package:vmba/data/language.dart';

class RootPage extends StatefulWidget {
  RootPage();

  @override
  State<StatefulWidget> createState() => new RootPageState();
}

class RootPageState extends State<RootPage> {
  bool appInitalized = false;
  bool _displayProcessingIndicator;
  bool _displayFinalError;
  String _displayProcessingText;

  @override
  void initState() {
    super.initState();
    _displayProcessingIndicator = true;
    gblNoNetwork = false;
    _displayFinalError = false;
    _displayProcessingText = 'Loading settings...';

      loadData();
  }

  loadData() async {
    //initLangs();

    PackageInfo.fromPlatform()
        .then((PackageInfo packageInfo) =>
    packageInfo.version + '.' + packageInfo.buildNumber)
        .then((String version) async {
      gblVersion = version;
      gblIsIos = Platform.isIOS;
      // await Repository.get().init();
      await Repository.get().settings().catchError((e) {
        setState(() {
          _displayProcessingText = 'Error loading : ' + e.toString();
          _displayFinalError = true;
          _displayProcessingIndicator = false;
        });
        return;
      });
      Repository.get().initFqtv();
    }
      );

        Repository.get().initCities().then((_) {
              Repository.get()
                  .initRoutes()
                  .then((_) => setState(() {
                        _displayProcessingIndicator = false;
                      }))
                  .catchError((e) {
                setState(() {
                  _displayProcessingIndicator = false;
                });
              }).then((_) {});
              setState(() {
                _displayProcessingText = 'Loading routes...';

              });
            }).catchError((e) {
              setState(() {
                _displayProcessingText = 'Error loading routes: ' + e.toString() ;
                _displayFinalError = true;
                _displayProcessingIndicator = false;
              });
            });

    //Repository.get().initFqtv();
  }

  @override
  Widget build(BuildContext context) {

    if (_displayFinalError || (gblError != null && gblError.isNotEmpty) ) {
      return Scaffold(
          body: Container(
            color: Colors.white, constraints: BoxConstraints.expand(),
            child: Center(
              child:
             Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TrText(_displayProcessingText + gblError, style: TextStyle(fontSize: 14.0)),
                  ),
                ],
              ),
            ),
          ));
    } else if (_displayProcessingIndicator) {
        return Scaffold(
            body: Container(
              color: Colors.white, constraints: BoxConstraints.expand(),
              child: Center(
                child:
               Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('lib/assets/$gblAppTitle/images/loader.png'),
                    CircularProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TrText(_displayProcessingText),
                    ),
                  ],
                ),
              ),
            ));
    } else {
      // check special actions
      switch (gblAction) {
        case 'LIVE':
          break;
        case 'TEST':
          break;
        case 'LOGIN':
          break;
        case 'UPDATE':
          return new UpdatePage();
          break;
        case 'SUSSPEND':
        case 'STOP':
          return new StopPageWeb();
          break;
      }

      return new HomePage();
    }
  }
}
