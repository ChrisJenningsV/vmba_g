
import 'package:flutter/material.dart';
import 'package:vmba/Helpers/settingsHelper.dart';
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

  static Color selectedBackground = wantHomePageV3() ? Colors.red : Colors.black;
  static Color selectedText =  Colors.white;
  static Color unselectedBackground = wantHomePageV3() ? Colors.transparent : Colors.white;
  static Color unselectedText = wantHomePageV3() ? Colors.white : Colors.black;

  void _toggleJourneyType(bool _isReturn) {
    widget.onChanged!(_isReturn);
  }
  @override
  void initState() {
    super.initState();
    selectedBackground = wantHomePageV3() ? Colors.red : gblSystemColors.accentButtonColor;
  }

  @override
  Widget build(BuildContext context) {

  if( wantHomePageV3()) {
    return Container(
      width: double.infinity,
      child: getButtons2(),
    );
  }
    return getButtons();

  }
  Widget getButtons2() {

    BorderRadius radius =  BorderRadius.all( Radius.circular(10.0));


    return
      Container(
          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
          width: MediaQuery.sizeOf(context).width,
          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey ) ,
              borderRadius: radius,
          ),
          child:
          Row(
            mainAxisSize:  MainAxisSize.max,
            mainAxisAlignment:MainAxisAlignment.spaceBetween,
            children: [
              new GestureDetector(
                child: new Container(
                  alignment: Alignment.center,
                  width: MediaQuery.sizeOf(context).width/2-18,
                  decoration: new BoxDecoration(
                      color: widget.isReturn
                          ? selectedBackground
                          : unselectedBackground, //_returnBackground,
                      borderRadius: radius),
                  padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                  child: new Text(translate('Return'),
                      style: new TextStyle(
                        color: widget.isReturn ? selectedText : unselectedText,
                      )),
                ),
                onTap: () => _toggleJourneyType(true),
              ),

              //wantHomePageV3() ? Padding(padding: EdgeInsets.all(2)) : Container(),

              new GestureDetector(
                child: new Container(
                    alignment: Alignment.center,
                    width: MediaQuery.sizeOf(context).width/2-18,
                    decoration: new BoxDecoration(
                        color: !widget.isReturn
                            ? selectedBackground
                            : unselectedBackground,
                        borderRadius: radius),
                    padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                    child: new Text(translate('One Way'),
                        style: new TextStyle(
                            color:
                            !widget.isReturn ? selectedText : unselectedText))),
                onTap: () => _toggleJourneyType(false),
              )
            ],
          ));
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
      width: wantHomePageV3() ? MediaQuery.sizeOf(context).width : null,

      decoration: BoxDecoration(
          border: wantHomePageV3() ? Border.all(color: Colors.grey )  : null,
          borderRadius: retRadius,
        boxShadow: wantHomePageV3() ? null : [BoxShadow(color: Colors.grey,
          blurRadius: 2.0,
          offset: Offset(0.5, 0.75))]
      ),
    child:
      Row(
      mainAxisSize:  wantHomePageV3() ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: wantHomePageV3() ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
        children: [
        new GestureDetector(
        child: new Container(
          alignment: Alignment.center,
          width: wantHomePageV3() ? MediaQuery.sizeOf(context).width/2-15 : null,
        decoration: new BoxDecoration(
        border: wantHomePageV3() ? null : Border.all(color:  gblSystemColors.accentButtonColor),
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

          //wantHomePageV3() ? Padding(padding: EdgeInsets.all(2)) : Container(),

    new GestureDetector(
    child: new Container(
      alignment: Alignment.center,
        width: wantHomePageV3() ? MediaQuery.sizeOf(context).width/2-15 : null,
    decoration: new BoxDecoration(
    border:  wantHomePageV3() ? null : Border.all(color: gblSystemColors.accentButtonColor),
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
