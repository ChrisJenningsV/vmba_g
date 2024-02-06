
import 'package:flutter/material.dart';
import 'package:vmba/components/vidButtons.dart';

import '../components/trText.dart';
import '../components/vidCards.dart';
import '../utilities/helper.dart';

class GiftVoucherCard extends StatefulWidget {
  GiftVoucherCard();
  GiftVoucherCardState createState() => GiftVoucherCardState();

}

class GiftVoucherCardState extends State<GiftVoucherCard> {
  TextEditingController _vNoTextEditingController =  TextEditingController();
  TextEditingController _vPinTextEditingController =  TextEditingController();

  @override
  initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];



    Row r = Row(
      children: [
        new SizedBox(
            width: 100,
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
      /*  new TextFormField(
          decoration: getDecoration(
              translate('Security Code')),
          controller: _vPinTextEditingController,
          keyboardType: TextInputType.number,
          onSaved: (value) {
            if (value != null) {
            }
          },
        ),*/

      ],
    );

    list.add( Container( child: r,));
    list.add(vidWideActionButton(context, 'Apply', (p0, p1) { }));
   // list.add(Text('body'));
    return vidExpanderCard(context, 'Gift Voucher', true, Icons.card_giftcard, list);
  }
}


