
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/contactDetails/contactDetailsPage.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';

import '../Helpers/settingsHelper.dart';
import '../components/showDialog.dart';
import '../utilities/helper.dart';
import '../v3pages/controls/V3Constants.dart';

//ignore: must_be_immutable
class DangerousGoodsWidget extends StatefulWidget {
  bool preLoadDetails = false;
  final PassengerDetail? passengerDetailRecord;
  final NewBooking? newBooking;
  final PnrModel? pnr;
  final int journeyNo;
  final int paxNo;

  DangerousGoodsWidget({Key key= const Key("dangerous_key"), this.preLoadDetails=false, this.passengerDetailRecord, this.newBooking, this.pnr, this.paxNo=1, this.journeyNo=1})
      : super(key: key);

  //final LoadDataType dataType;

  DangerousGoodsWidgetState createState() => DangerousGoodsWidgetState();
}

class DangerousGoodsWidgetState extends State<DangerousGoodsWidget> {
  bool _buttonEnabled=true;
  bool continuePass=true;

  @override void initState() {
    _buttonEnabled = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: appBar(
        context,
        'Dangerous Goods', PageEnum.dangerousGoods,
      ),
      //endDrawer: DrawerMenu(),
      body: SingleChildScrollView( child:_body()),
    );
  }

  Widget _body() {
    List<Widget> list = [];

    list.add(Text(''));
    list.add(TrText('The following is a non-exhaustive list of Prohibited Items'));

    double height = gblIsIos ? 350 : 500;
    double width = gblIsIos ? 220 : 250;
    if( gblSettings.dagerousdims != '' ){
      // format {"iOSw": "220", "iOSh": "350", "aNDw": "400", "aNDh": "500"}
      Map dimMap = json.decode(gblSettings.dagerousdims.toUpperCase());
      if( gblIsIos) {
        height = double.parse(dimMap['IOSH']);
        width = double.parse(dimMap['IOSW']);
      } else {
        height = double.parse(dimMap['ANDH']);
        width = double.parse(dimMap['ANDW']);
      }
    }


    //list.add(Padding(padding: EdgeInsets.only(top: 60)));
  list.add( Image(
      image: NetworkImage('${gblSettings.gblServerFiles}/pageImages/dangerousgoods.jpg'),
      height: height,
      width: width,
      fit: BoxFit.fill,
    ));

  list.add(CheckboxListTile(
    title: TrText("I confirm that I have read and understood this notice and there are no Dangerous Goods or Prohibited Items in my hand luggage or checked-in baggage."),
    value: _buttonEnabled,
    onChanged: (newValue) {
      setState(() {
        _buttonEnabled = newValue!;
      });
    },
    controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
  ));

    list.add(ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0)),
          foregroundColor: _buttonEnabled ? gblSystemColors.primaryButtonColor : Colors.grey.shade200),
      onPressed: () async {
        if( _buttonEnabled == true ) {
          if( widget.newBooking != null ) {
            logit('has newBooking - go to CDW');
            if( widget.newBooking == null){
              logit('widget.newBooking == null');
              showAlertDialog(context, 'Alert', 'NB Error in data');
            }
            if( widget.passengerDetailRecord == null ){
              logit('widget.passengerDetailRecord == null');
              showAlertDialog(context, 'Alert', 'PDR Error in data');

            }
            var _error = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ContactDetailsWidget(
                          newbooking: widget.newBooking!,
                          preLoadDetails: widget.preLoadDetails,
                          passengerDetailRecord: widget.passengerDetailRecord!,
                        )));
            print(_error);
          } else {
            logit('no newBooking');
            continuePass = true;
            Navigator.pop(context, continuePass);
          }
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check,
            color: Colors.white,
          ),
          TrText(
            'CONTINUE',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ));


    return  Column(
      children: list,
    );
  }
}

