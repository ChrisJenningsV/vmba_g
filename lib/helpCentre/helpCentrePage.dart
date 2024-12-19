import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        height: 400,
        color: Colors.white,
        child: Column(
          children: [
            Padding(padding: EdgeInsets.all(40)),
            Image.network('${gblSettings.gblServerFiles}/pageImages/helpcentre.png',
                errorBuilder: (BuildContext context, Object obj,
                    StackTrace? stackTrace) {
                  return Text('', style: TextStyle(color: Colors.red));
                }
            ), //

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