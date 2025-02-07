
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vmba/components/vidButtons.dart';

import '../components/showDialog.dart';
import '../components/trText.dart';
import '../components/vidCards.dart';
import '../controllers/vrsCommands.dart';
import '../data/globals.dart';
import '../data/models/models.dart';
import '../data/models/vouchers.dart';
import '../data/repository.dart';
import '../utilities/helper.dart';

class GiftVoucherCard extends StatefulWidget {
  GiftVoucherCard();
  GiftVoucherCardState createState() => GiftVoucherCardState();

}

class GiftVoucherCardState extends State<GiftVoucherCard> {
  TextEditingController _vNoTextEditingController =  TextEditingController();
  TextEditingController _vNoPinEditingController =  TextEditingController();

  @override
  initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];



    Row r = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        new SizedBox(
            width: 200,
            child: TextFormField(
          decoration: getDecoration(
              translate('Voucher Number')),
              controller: _vNoTextEditingController,
              keyboardType: TextInputType.number,
          onSaved: (value) {
            if (value != null) {
            }
          },
        )),
    new SizedBox(
    width: 100,
    child:  TextFormField(
          decoration: getDecoration(
              translate('Security Code')),
          controller: _vNoPinEditingController,
          keyboardType: TextInputType.number,
          onSaved: (value) {
            if (value != null) {
            }
          },
        )),

      ],
    );

    list.add( Container( child: r, padding: EdgeInsets.all(5),));
    list.add(Container( child:vidWideActionButton(context, 'Apply', onApplyPressed )
    , padding: EdgeInsets.only(left: 25, right: 25),));
   // list.add(Text('body'));
    return vidExpanderCard(context, 'Gift Voucher', true, Icons.card_giftcard, list);
  }


void onApplyPressed(BuildContext p0, dynamic p1) async {
  // to apply send
  // VD/abc123/112233~X
  // ERROR: VOUCHER NOT FOUND
  // VoucherNumber	      SecurityCode
  // 68 22 20 00 00 035	  75 57 51
  String txt = _vNoTextEditingController.text;
  String pin = _vNoPinEditingController.text;

  String cmd='VD/$txt/$pin~X';
  String reply =  await runVrsCommand(cmd);
  try {
  if( reply.contains('ERROR')){
    showVidDialog(context, 'Gift Voucher Error ', reply);
  } else {
    Map<String, dynamic> map = json.decode(reply);
    Map<String, dynamic> map2 = map['fopvouchers'];
    FopVouchers fopVouchers = new FopVouchers.fromJson(map2);

    showSnackBar('Voucher applied ', context);
  }
  } catch(e) {
    setError( e.toString());
  }
}

}
