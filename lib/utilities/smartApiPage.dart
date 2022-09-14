import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/data/models/providers.dart' as PaymentProvider;

import '../components/trText.dart';
import '../data/globals.dart';
import '../data/models/pnr.dart';
import '../data/models/vrsRequest.dart';
import '../data/smartApi.dart';
import '../menu/menu.dart';

class SmartApiPage extends StatefulWidget {
  SmartApiPage({
    Key key,
    this.mmbAction,
    this.pnrModel,
    this.provider,
    this.onComplete
  }) : super(key: key);

  final PnrModel pnrModel;
  final mmbAction;
  final PaymentProvider.Provider provider;
  void Function(dynamic p) onComplete;

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
    initActions();
  }

  @override
  Widget build(BuildContext context) {
    if( gblError != null && gblError.isNotEmpty) {
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
          //endDrawer: DrawerMenu(),
          body: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            titlePadding: const EdgeInsets.all(0),
            title: Container(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                color: Colors.red,
                child: TrText("Payment Error")
            ),
            content: Row(
              children: <Widget> [
                Icon(Icons.close_rounded, color: Colors.red, size: 30,),
              Text(gblError),
              ]),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.grey.shade200) ,
                  child: TrText("OK", style: TextStyle(backgroundColor: Colors.grey.shade200, color: Colors.black),),
                  onPressed: () {
                    //Put your code here which you want to execute on Cancel button click.
                    if( widget.onComplete != null ){
                      widget.onComplete(false);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],

          )
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
        //endDrawer: DrawerMenu(),
        body: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
            color: Colors.green.shade200,
          child: TrText("Payment Progress")),
          content: dialogBody(),
        )
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

  Widget dialogBody() {
    return Center(
        heightFactor: 1,
        child:
        Stack(
          children:  [
            Positioned(
                left: 25,
                top: 25,
                child:
                CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 48,
                    child: Image.asset('lib/assets/$gblAppTitle/images/loader.png') //Icon(Icons.check),
                )),
            /*SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            color: Colors.grey,
           // value: 1,
          ),
        ),*/
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                color: Colors.yellow,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade100,
                // value: .5, // Change this value to update the progress
              ),
            ),
          ],
        )
    );
  }


  Future<void> initActions() async {

    switch (widget.provider.paymentType) {
      case 'ExternalPayment':
        break;
      case 'CreditCard':
        break;
      case 'FundTransferPayment':
        // do smart command
        PaymentRequest pay = new PaymentRequest();
        pay.rloc = widget.pnrModel.pNR.rLOC;
        pay.paymentType = widget.provider.paymentType;

        String data =  json.encode(pay);
        try {
          String reply = await callSmartApi('MAKEPAYMENT', data);
          Map map = json.decode(reply);
          PaymentReply payRs = new PaymentReply.fromJson(map);
        } catch(e) {
          gblError = e.toString();
         setState(() {

          });
        }
        break;
    }
  }
}
