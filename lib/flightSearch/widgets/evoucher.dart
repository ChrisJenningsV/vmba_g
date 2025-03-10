
import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';

import '../../Helpers/settingsHelper.dart';
import '../../components/pageStyleV2.dart';

class EVoucherWidget extends StatefulWidget {
  EVoucherWidget({Key key= const Key("evoucher_key"), required this.evoucherNo, required this.onChanged}) : super(key: key);

  final ValueChanged<String> onChanged;
  final String evoucherNo;

  _EVoucherWidgetState createState() => _EVoucherWidgetState();
}

class _EVoucherWidgetState extends State<EVoucherWidget> {
  TextEditingController _textEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.evoucherNo != null) {
      _textEditingController.text = widget.evoucherNo;
    }
  }

  @override
  Widget build(BuildContext context) {
    _textEditingController.text = widget.evoucherNo;


      double screenWidth = MediaQuery.of(context).size.width;

      double fSize;
      if( screenWidth < 380 ) {
        fSize = 14.0;
      } else {
        fSize = 18.0;
      }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        v2Label(translate('Promo Code')),
        TextField(
          controller: _textEditingController,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
              border: InputBorder.none, hintText: translate('Enter your code')),
          style: new TextStyle(
            // fontSize: fSize,
            fontWeight: FontWeight.w300,
          ),
        ),
       ],
    );
  }
}
