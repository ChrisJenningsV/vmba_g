

import 'package:flutter/material.dart';
import 'package:vmba/Products/widgets/productsWidget.dart';

import '../data/globals.dart';
import '../data/models/models.dart';
import '../home/home_page.dart';
import '../menu/menu.dart';
import '../payment/choosePaymentMethod.dart';
import '../utilities/widgets/appBarWidget.dart';

class OptionsPageWidget extends StatefulWidget {
  OptionsPageWidget({Key key, this.newBooking}) : super(key: key);
  final NewBooking newBooking;

  _OptionsWidgetState createState() => _OptionsWidgetState();
}

class _OptionsWidgetState extends State<OptionsPageWidget> {
  GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    //Show dialog
    //print('build');

    return new Scaffold(
        key: _key,
        appBar: appBar(context, 'Options',
            curStep: 4,
            newBooking: widget.newBooking,
            imageName: gblSettings.wantPageImages ? 'options' : null),
//      extendBodyBehindAppBar: gblSettings.wantCityImages,
        endDrawer: DrawerMenu(),
        body:getSummaryBody(context, widget.newBooking,  _body, statusGlobalKeyOptions),
    );
  }

  Widget _body(NewBooking newBooking) {
    return
/*
      Container(
      height: 700,
        padding: EdgeInsets.only(bottom: 50),
        child:
*/
    SizedBox(
      height: 700,
      child:    ListView(
          //scrollDirection: Axis.vertical,
        //shrinkWrap: true,
        children: [
          ProductsWidget(
            newBooking: widget.newBooking,
            pnrModel: gblPnrModel, wantTitle: false,
            wantButton: true,
            isMMB: false,
            //onComplete: onComplete,
          ),
/*
          Padding(padding: EdgeInsets.only(left: 10, right: 10),
              child: vidWideActionButton(context, 'Continue', onComplete))
*/
        ]));
    //);

  }


  onComplete(BuildContext context, dynamic p ) {
    try {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChoosePaymenMethodWidget(
                newBooking: widget.newBooking, pnrModel: gblPnrModel, isMmb: false,)
            //CreditCardExample()
          ));
    } catch (e) {
      print('Error: $e');
    }
  }
}