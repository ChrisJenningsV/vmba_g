import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/globals.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/appBarWidget.dart';
import '../v3pages/controls/V3Constants.dart';


class HelpCentrePageWidget extends StatefulWidget {
  HelpCentrePageWidget();
  // : super(key: key);

  HelpCentrePageWidgetState createState() =>
      HelpCentrePageWidgetState();
}

class HelpCentrePageWidgetState extends State<HelpCentrePageWidget>  with TickerProviderStateMixin {
  late bool _loadingInProgress;
  late bool _showResults;
  String _platformVersion = 'Unknown';
  String androidChannelKey = 'eyJzZXR0aW5nc191cmwiOiJodHRwczovL2xvZ2FuYWlyY3JjYy56ZW5kZXNrLmNvbS9tb2JpbGVfc2RrX2FwaS9zZXR0aW5ncy8wMUpKOU1TQzZWWTkyNDdEVDdEUFgyWTA2Ni5qc29uIn0=';
  String iosChannelKey = 'eyJzZXR0aW5nc191cmwiOiJodHRwczovL2xvZ2FuYWlyY3JjYy56ZW5kZXNrLmNvbS9tb2JpbGVfc2RrX2FwaS9zZXR0aW5ncy8wMUpKOU1WTU4wNUZEV0hWWUtDWVJHNURBMy5qc29uIn0=';
  String zenDeskUrl = 'https://loganaircrcc.zendesk.com';
  String appId = "562cd5d9b480bf8fa9512352b900e0117680b0affd4278fb";
  String oAuthId = 'YOUR_O_AUTH_ID';
  //final _zendeskChatSupportPlugin = ZendeskChatSupport();


  TabController? _tabViewController;

  @override void initState() {
    _loadingInProgress = true;
    _showResults = false;
    loadData();
    initPlatformState();
//    initZendesk();
  }
/*
  Future<void> initZendesk() async {
    if (!mounted) {
      return;
    }
    await Zendesk.initialize( zenDeskUrl, appId);
  }
*/

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.

    try {
      oAuthId = gblNotifyToken;

/*
      platformVersion = await _zendeskChatSupportPlugin.getPlatformVersion() ?? 'Unknown platform version';

      _zendeskChatSupportPlugin.initialize(
        androidChannelKey: androidChannelKey,
        iosChannelKey: iosChannelKey,
        zenDeskUrl: zenDeskUrl,
        appId: appId,
        oAuthId: oAuthId,
      );
*/
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
//      _platformVersion = platformVersion;
    });
  }


  @override
  Widget build(BuildContext context) {
    return

      new Scaffold(
        backgroundColor: Colors.grey.shade50, //v2PageBackgroundColor(),
        appBar: appBar(context,
          _showResults ? 'Help Centre Results' : 'Help Centre',
          PageEnum.editPax,
          //imageName: gblSettings.wantPageImages ? widget.formParams.formName : '',
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                if (_showResults) {
                  _showResults = false;
                  setState(() {

                  });
                } else {
                  Navigator.pop(context);
                }
              },
            )
          ],
        ),
        extendBodyBehindAppBar: gblSettings.wantPageImages,
        //endDrawer: DrawerMenu(),
        body: _body(),
      );
  }

  Widget _body() {
    if (_loadingInProgress) {
      return getProgressMessage('Loading...', '');
    }
    return Container(
        //height: 400,
        color: Colors.white,
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 100)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // <-- Radius
                ),
                backgroundColor: Colors.red,
                elevation: 10,
                minimumSize: const Size.fromHeight(
                    40), // fromHeight use double.infinity as width and 40 is the height
              ),
              onPressed: () {
/*
                ZendeskHelpcenter.initialize(
                    appId: appId,
                    clientId: "mobile_sdk_client_e68bf24adb8618bed9b1",
                    nameIdentifier: gblNotifyToken,
                    urlString: zenDeskUrl

                );
*/
              },
              child: const Text('Initialize'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                backgroundColor: Colors.blue,
                elevation: 10,
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () {
/*
                ZendeskHelpcenter.showRequestList();
*/
                //ZendeskHelpcenter.showHelpCenter();
              },
              child: const Text(
                'Request List',
              ),
            ),
            Text('Running on: $_platformVersion\n'),
            ElevatedButton(
                onPressed: () async {
/*
                  await _zendeskChatSupportPlugin.isInitialize().then((value) {
                    logit("isInitialize: ${value}");
                    if (value) {
                      _zendeskChatSupportPlugin.show(titleName: "Chat",);
                    } else {
                      _zendeskChatSupportPlugin.initialize(
                        androidChannelKey: androidChannelKey,
                        iosChannelKey: iosChannelKey,
                        zenDeskUrl: zenDeskUrl,
                        appId: appId,
                        oAuthId: oAuthId,
                      );
                    }
                  });
*/
                },
                child: const Text("Start Chat")),
            const SizedBox(height: 20),
          ],
        )
    );
  }

  Future<void> loadData() async {
    String data = '';
    _loadingInProgress = false;
    setState(() {

    });
  }
}