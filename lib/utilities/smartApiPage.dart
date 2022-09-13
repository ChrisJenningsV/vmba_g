import 'package:flutter/material.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/data/models/providers.dart' as PaymentProvider;

import '../components/trText.dart';
import '../data/globals.dart';
import '../data/models/pnr.dart';
import '../menu/menu.dart';

class SmartApiPage extends StatefulWidget {
  SmartApiPage({
    Key key,
    this.mmbAction,
    this.pnrModel,
    this.provider
  }) : super(key: key);

  final PnrModel pnrModel;
  final mmbAction;
  final PaymentProvider.Provider provider;

  @override
  SmartApiPageState createState() => SmartApiPageState();
}

class SmartApiPageState extends State<SmartApiPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  final formKey = new GlobalKey<FormState>();
  bool _displayProcessingIndicator;
  String _displayProcessingText;

  @override
  initState() {
    super.initState();
    _displayProcessingIndicator = true;
    _displayProcessingText = '';
  }

  @override
  Widget build(BuildContext context) {
    if( gblError != null && gblError.isNotEmpty) {
      return Scaffold(
        key: _key,
        appBar: appBar(context, 'Payment',),
        endDrawer: DrawerMenu(),
        body: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TrText(
                    'Payment Error', style: TextStyle(fontSize: 16.0)),
              ),
            ],
          ),
        ),
      );
    }
    if (_displayProcessingIndicator) {
      return Scaffold(
        key: _key,
        appBar: new AppBar(
          //brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: new TrText('Payment',
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
        ),
        endDrawer: DrawerMenu(),
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
    }
    // no error
    return Scaffold(
      key: _key,
      appBar: appBar(context, 'Payment',) ,
      endDrawer: DrawerMenu(),
      body:Form(
        key: formKey,
        child: new SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              children: _getBody(),
            ),
          ),
        ),
      ),
    );

  }

  List <Widget> _getBody() {
    List<Widget> list= [];
    list.add(Text('Body'));
    return list;
  }
}
