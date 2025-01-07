
import 'package:flutter/material.dart';
import 'package:vmba/Helpers/settingsHelper.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/components/trText.dart';

import '../../data/globals.dart';

class JourneyTypeWidget extends StatefulWidget {
  JourneyTypeWidget({Key key= const Key("jtype_key"), this.isReturn = false, this.onChanged})
      : super(key: key);

  //final SystemColors systemColors;
  final bool isReturn;
  final ValueChanged<bool>? onChanged;

  _JourneyTypeWidgetState createState() => _JourneyTypeWidgetState();
}

class _JourneyTypeWidgetState extends State<JourneyTypeWidget> {

  static Color selectedBackground = Colors.black;
  static Color selectedText = Colors.white;
  static Color unselectedBackground = Colors.white;
  static Color unselectedText = wantHomePageV3() ? Colors.grey : Colors.black;

  void _toggleJourneyType(bool _isReturn) {
    widget.onChanged!(_isReturn);
  }
  @override
  void initState() {
    super.initState();
    selectedBackground = gblSystemColors.accentButtonColor;
  }

  @override
  Widget build(BuildContext context) {

  if( wantHomePageV3()) {
    return Container(
      width: double.infinity,
      child: getButtons(),
    );
  }
    return getButtons();

  }
  Widget getButtons() {
    EdgeInsets retPadding = EdgeInsets.fromLTRB(45.0, 5.0, 45.0, 5.0);
    EdgeInsets owPadding =  EdgeInsets.fromLTRB(45.0, 5.0, 45.0, 5.0);

    BorderRadius retRadius =  BorderRadius.only(topLeft: const Radius.circular(7.0),bottomLeft: const Radius.circular(7.0));
    BorderRadius owRadius =  BorderRadius.only( topRight: const Radius.circular(7.0),bottomRight: const Radius.circular(7.0));

    if( wantRtl()){
      retRadius = BorderRadius.only( topRight: const Radius.circular(7.0),bottomRight: const Radius.circular(7.0));
      owRadius =   BorderRadius.only(topLeft: const Radius.circular(7.0),bottomLeft: const Radius.circular(7.0));
    }
    if( wantHomePageV3()  ){
      retRadius = BorderRadius.all( Radius.circular(5.0));
      owRadius =   BorderRadius.all(Radius.circular(5.0));
      retPadding = EdgeInsets.fromLTRB(45.0, 10.0, 45.0, 10.0);
      owPadding =  EdgeInsets.fromLTRB(45.0, 10.0, 45.0, 10.0);
    }

    return
    Container(
      decoration: wantHomePageV3() ? null : BoxDecoration(boxShadow: [BoxShadow(color: Colors.grey,
          blurRadius: 2.0,
          offset: Offset(0.5, 0.75))]),
    child:
      Row(
      mainAxisSize:  MainAxisSize.min,
        mainAxisAlignment: wantHomePageV3() ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
        new GestureDetector(
        child: new Container(

        decoration: new BoxDecoration(
        border: new Border.all(color:  gblSystemColors.accentButtonColor),
    color: widget.isReturn
    ? selectedBackground
        : unselectedBackground, //_returnBackground,
    borderRadius: retRadius),
    padding: retPadding,
    child: new TrText('Return',
    style: new TextStyle(
    color: widget.isReturn ? selectedText : unselectedText,
    )),
    ),
    onTap: () => _toggleJourneyType(true),
    ),
    wantHomePageV3() ? Padding(padding: EdgeInsets.all(2)) : Container(),
    new GestureDetector(
    child: new Container(

    decoration: new BoxDecoration(
    border: new Border.all(color: gblSystemColors.accentButtonColor),
    color: !widget.isReturn
    ? selectedBackground
        : unselectedBackground,
    borderRadius: owRadius),
    padding: owPadding,
    child: new TrText('One Way',
    style: new TextStyle(
    color:
    !widget.isReturn ? selectedText : unselectedText))),
    onTap: () => _toggleJourneyType(false),
    )
    ],
    ));
  }
}
