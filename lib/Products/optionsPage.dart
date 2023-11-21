import 'package:flutter/material.dart';
import 'package:vmba/Products/widgets/productsWidget.dart';

import '../Helpers/bookingHelper.dart';
import '../components/vidButtons.dart';
import '../data/globals.dart';
import '../data/models/models.dart';
import '../data/models/pnr.dart';
import '../home/home_page.dart';
import '../menu/menu.dart';
import '../payment/choosePaymentMethod.dart';
import '../utilities/helper.dart';
import '../utilities/widgets/CustomPageRoute.dart';
import '../utilities/widgets/appBarWidget.dart';

class OptionsPageWidget extends StatefulWidget {
  OptionsPageWidget({Key key= const Key("opt_key"), required this.newBooking}) : super(key: key);
  final NewBooking newBooking;

  _OptionsWidgetState createState() => _OptionsWidgetState();
}

class _OptionsWidgetState extends State<OptionsPageWidget> {
  GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  initState() {
    super.initState();
    commonPageInit('OPTIONS');
  }

  @override
  Widget build(BuildContext context) {
    //Show dialog
    //print('build');

/*
    return WillPopScope(
        onWillPop: _onWillPop,
*/
    return
      CustomWillPopScope(
          action: () {

            print('pop');
            if( gblSettings.canGoBackFromOptionsPage) {
              Navigator.pop(context);
              setState(() {
                //product.is_favorite = isFavorite;
              });
            } else {
              onWillPop(context);
            }
          },
          onWillPop: true,
        child:  Scaffold(
        key: _key,
        appBar: appBar(context, 'Options',
            curStep: 4,
            newBooking: widget.newBooking,
            imageName: gblSettings.wantPageImages ? 'options' : ''),
//      extendBodyBehindAppBar: gblSettings.wantCityImages,
        endDrawer: DrawerMenu(),
        floatingActionButton: vidWideActionButton(context,'Continue', onComplete, icon: Icons.check, offset: 35.0 ) ,
        body:getSummaryBody(context, widget.newBooking,  _body, statusGlobalKeyOptions),
    ));
  }
  Future<bool> _onWillPop() async {
    return onWillPop(context);
  }

  Widget _body(NewBooking newBooking) {
    return

    SizedBox(
      height: 700,
      child:    ListView(
          //scrollDirection: Axis.vertical,
        //shrinkWrap: true,
        children: [
          ProductsWidget(
            newBooking: widget.newBooking,
            pnrModel: gblPnrModel as PnrModel, wantTitle: false,
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


  onComplete(BuildContext context, dynamic p) {
    try {
      if( !gblActionBtnDisabled && gblNoNetwork == false ) {
        gblPaymentMsg = '';
        Navigator.push(
            context,
            //MaterialPageRoute(
            CustomPageRoute(
                builder: (context) =>
                    ChoosePaymenMethodWidget(
                      newBooking: widget.newBooking,
                      pnrModel: gblPnrModel!,
                      isMmb: false,)
              //CreditCardExample()
            ));
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}