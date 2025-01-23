import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zendesk_helpcenter/zendesk_helpcenter.dart';
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

  TabController? _tabViewController;

  @override void initState() {
    _loadingInProgress = true;
    _showResults = false;
    loadData();
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
                ZendeskHelpcenter.initialize(
                    appId: "562cd5d9b480bf8fa9512352b900e0117680b0affd4278fb",
                    clientId: "mobile_sdk_client_e68bf24adb8618bed9b1",
                    nameIdentifier: gblNotifyToken,
                    urlString: 'https://loganaircrcc.zendesk.com'

                );
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
                //ZendeskHelpcenter.showRequestList();
                ZendeskHelpcenter.showHelpCenter();
              },
              child: const Text(
                'Request List',
              ),
            ),
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