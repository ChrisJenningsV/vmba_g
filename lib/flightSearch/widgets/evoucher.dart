import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';

import '../../Helpers/settingsHelper.dart';
import '../../components/pageStyleV2.dart';
import '../../data/globals.dart';

class EVoucherWidget extends StatefulWidget {
  EVoucherWidget({Key key, this.evoucherNo, this.onChanged}) : super(key: key);

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

    if( wantPageV2()) {
      return v2BorderBox(context,  ' ' + translate('Promo Code'),
          TextField(
    controller: _textEditingController,
    onChanged: widget.onChanged,
    decoration: InputDecoration(
    border: InputBorder.none, hintText: translate('Enter your code')),
    style: new TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
    )));
          } else {

    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
    TrText('Promo Code',
    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
    TextField(
    controller: _textEditingController,
    onChanged: widget.onChanged,
    decoration: InputDecoration(
    border: InputBorder.none, hintText: translate('Enter your code')),
    style: new TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
    ),
    ),
    Container(
    child: new Divider(
    height: 0.0,
    ))
    ],
    );
    }
  }
}
