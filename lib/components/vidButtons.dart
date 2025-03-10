
import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/utilities/widgets/colourHelper.dart';
import 'package:vmba/v3pages/v3Theme.dart';

import '../Helpers/settingsHelper.dart';
import '../data/globals.dart';

Widget vidWideTextButton(BuildContext context, String caption, void Function({int? p1, int? p2, String? p3}) onPressed, {IconData? icon, int iconRotation=0,int p1 = 0 } ) {
  return Expanded( child: vidTextButton(context, caption, onPressed, icon: icon, iconRotation: iconRotation, p1: p1 ));
}

Widget vidTextButton(BuildContext context, String caption, void Function({int? p1, int? p2, String? p3}) onPressed,
    {IconData? icon, int iconRotation=0,int? p1,int? p2, String? p3, Color? color, bool minHeight = false } ) {

  Widget iconWidget = Container();
  Color textClr = gblSystemColors.textButtonTextColor;
  if( color != null ) textClr = color;

  if( icon != null) {
    if( iconRotation != null && iconRotation > 0 ) {
      iconWidget = RotatedBox(
          quarterTurns: iconRotation,
          child: Icon(
            icon,
            size: 20.0,
            color: Colors.grey,
          ));
    } else {
      iconWidget = Icon(
        icon,
        size: 20.0,
        color: Colors.grey,
      );
    }
  }

  ButtonStyle style =  TextButton.styleFrom(side: BorderSide(color:  textClr, width: 1),foregroundColor: textClr);
  if( minHeight){
    style =  TextButton.styleFrom(side: BorderSide(color:  textClr, width: 1),
        foregroundColor: textClr,
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        minimumSize: Size.zero,
    );
  }

  return
     TextButton(
      onPressed: () {
        if( gblActionBtnDisabled == false ) {
          gblActionBtnDisabled = true;
          onPressed(p1: p1, p2: p2, p3: p3);
        }
      } ,
      style: style,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TrText(
            caption,
            style: TextStyle(color: textClr),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5.0),
          ),
          iconWidget,
        ],
      ),
  );

}

BorderRadius getButtonRadius() {
  BorderRadius radius = BorderRadius.circular(30.0);
  if( gblV3Theme != null && gblV3Theme!.generic != null && gblV3Theme!.generic!.actionButtonRadius != null ){
    return BorderRadius.circular(gblV3Theme!.generic!.actionButtonRadius as double);
  }
  if(wantPageV2() ){
    radius = BorderRadius.circular(5.0);
  }
  return radius;
}

/*
  NEXT button at the bottom of most pages
 */
Widget vidWideActionButton(BuildContext context, String caption, void Function(BuildContext, dynamic) onPressed, 
    {IconData? icon, int iconRotation=0, var param1, double offset=0, bool wantIcon = true, bool availableOffline = false, bool disabled = false, double? pad} ) {

  List<Widget> list = [];
  EdgeInsets buttonPad = EdgeInsets.all(0);
  bool wantShadows = true;

  if( gblV3Theme != null && gblV3Theme!.generic != null  ){
    if( gblV3Theme!.generic!.actionButtonIcons != null) {
      wantIcon = gblV3Theme!.generic!.actionButtonIcons as bool;
    }

    if( pad != null ) {
      buttonPad = EdgeInsets.all(pad);
    } else if( gblV3Theme!.generic!.actionButtonPadding != null ){
      buttonPad = EdgeInsets.all(gblV3Theme!.generic!.actionButtonPadding as double);
    }
    if( gblV3Theme!.generic!.actionButtonShadow != null ){
      wantShadows = gblV3Theme!.generic!.actionButtonShadow;
    }
  }
  if( gblSettings.wantButtonIcons && !gblActionBtnDisabled && wantIcon) {
    list.add(Icon(
      Icons.check,
      color: (disabled || gblActionBtnDisabled) ? actionButtonDisabledTextColor() : Colors.white,
    ));
  }
  if( gblActionBtnDisabled ){
//    list.add(Text('D '));
/*
    list.add(Transform.scale(
      scale: 0.3,
      child: CircularProgressIndicator( color: Colors.white,),
    ));
    list.add(Padding(padding: EdgeInsets.all(2)));
*/
  }
  if(  wantHomePageV3() ) {
    list.add(VButtonText(caption,
        color: (disabled || gblActionBtnDisabled) ? actionButtonDisabledTextColor() : Colors.white,
        ));
  } else {
    list.add(TrText(caption,style: TextStyle(color: (disabled || gblActionBtnDisabled) ? actionButtonDisabledTextColor() : Colors.white),
    ));
  }

  EdgeInsets padding = EdgeInsets.only(left: offset);
  if( wantRtl()) {
    padding = EdgeInsets.only(right: offset);
  }


  return
    Padding(
      padding: padding,
  child:
    ElevatedButton(
    onPressed: () {
      if(gblActionBtnDisabled == false &&  disabled == false && availableOffline == true || gblNoNetwork == false) {
        onPressed(context, param1);
      }
    },

    style: ElevatedButton.styleFrom(
        elevation: wantShadows ? null :0,
        backgroundColor: (disabled || gblActionBtnDisabled) ? actionButtonDisabledColor() :  actionButtonColor( availableOffline: availableOffline),
        foregroundColor: (disabled || gblActionBtnDisabled) ? actionButtonDisabledTextColor() : null,
        side: BorderSide(
          width: (disabled || gblActionBtnDisabled) ? 2.0 : 0,
          color: (disabled || gblActionBtnDisabled) ? actionButtonDisabledTextColor() : (wantHomePageV3() ? Colors.transparent: Colors.white),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: getButtonRadius())),
    child: Padding(
      padding: buttonPad,
    child: Row(
      //mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children:  list
,
    ),
  )
    )
    );
//  return Expanded( child: vidActionButton( context, caption, onPressed,icon: icon, iconRotation: iconRotation ));
}

Widget vid3DActionButton(BuildContext context, String caption, void Function(BuildContext) onPressed, {IconData? icon, int iconRotation=0, bool isRectangular=false } ) {
  if( icon == null) {
    icon = Icons.check;
  }
  return ElevatedButton(
    onPressed: () {
      if( gblActionBtnDisabled == false ) {
        onPressed(context);
      }
    },
    style: ElevatedButton.styleFrom(
        backgroundColor: gblSystemColors.primaryButtonColor, //Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0))),
    child: Row(
      //mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          color: Colors.white,
        ),
        TrText(
          caption,
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}


class ButtonClickParams{
  int paxNo = 0;
  int journeyNo = 0;
  String action = '';


  ButtonClickParams({ this.paxNo=0, this.journeyNo=0, this.action=''});

}


Widget vidActionButton(BuildContext context, String caption, void Function(BuildContext, ButtonClickParams?) onPressed,
    {IconData? icon, int iconRotation=0, bool isRectangular=false,
      Color color= Colors.tealAccent,
      Color bkColor = Colors.tealAccent,
      Color? lineColor = null,
      String subCaption = '',
      ButtonClickParams? params} ) {

  double borderWidth = 2;
  if( color == Colors.tealAccent) color = gblSystemColors.primaryButtonTextColor as Color;
  if( bkColor == Colors.tealAccent) bkColor = actionButtonColor();
  if( lineColor == null) {
    lineColor = Colors.amber;
    borderWidth = 0;
  }
    ShapeBorder? shape;

    if( isRectangular == true ){
      shape = RoundedRectangleBorder(
          side: BorderSide(width: borderWidth,color: lineColor),
          borderRadius: BorderRadius.all(Radius.circular(5.0),)
      );
    }
    Widget label = TrText(
      caption,
      style: TextStyle(color: color),
    );
    if( subCaption != '' ){
      label =  Column(
        children: [
          TrText(
            caption,
            style: TextStyle(color: color),
          ),
          VBodyText(
            subCaption,
            color: color,
            size: TextSize.small,
          ),
      ]
      );

    }


    return Padding(
        padding: EdgeInsets.only(left: 35.0),
        child:
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          FloatingActionButton.extended(
              elevation: 0.0,
              shape: shape,
              isExtended: true,
              label: label,

              icon: gblSettings.wantButtonIcons ? Icon(Icons.check,
                  color: gblSystemColors.primaryButtonTextColor) : null ,
              backgroundColor: bkColor ,
              onPressed: () {
                if(gblActionBtnDisabled == false ) {
                  onPressed(context, params);
                }
              })
        ]));

}

Widget vidInfoButton(BuildContext context, {void Function(BuildContext)? onPressed}){
  return vidRoundButton(context, Icons.info_outline, onPressed);
}

Widget vidAddButton(BuildContext? context, {void Function(BuildContext?)? onPressed,   bool disabled = false}){
  Color clr = gblSystemColors.primaryButtonColor;
  if( disabled != null && disabled) {
    clr = Colors.grey;
  }
  return IconButton(
    icon: Icon(
      Icons.add_circle,
      color: clr,
    ),
    onPressed: () {
        //if( context != null ) {

          onPressed!(context);
        //}
    },
  );
  //return vidRoundButton(context, Icons.add_circle_outline, onPressed, btnClr: Colors.white);
}

Widget vidRemoveButton(BuildContext? context, {void Function(BuildContext, int, int)? onPressed, int paxNo = 0, int segNo = 0, bool disabled = false,
    Color? clrIn, IconData? icon, double? size }){

  Color clr = clrIn == null ? gblSystemColors.primaryButtonColor : clrIn;
      if( disabled != null && disabled) {
        clr = Colors.grey;
      }
  return IconButton(
    icon: Icon(
      icon == null ? Icons.remove_circle : icon,
      color: clr,
      size: size,
    ),
    onPressed: () {
      if( context != null ) {
        if (disabled == null || disabled == false) {
          onPressed!(context, paxNo, segNo,);
        }
      }
    },
  ); // return vidRoundButton(context, Icons.remove_circle_outline, onPressed, btnClr: Colors.white);
}


Widget vidIconButton(BuildContext? context, {void Function(BuildContext, int, int)? onPressed, int paxNo = 0, int segNo = 0, bool disabled = false,
  Color? clrIn, IconData? icon, double? size }){

  Color clr = clrIn == null ? gblSystemColors.primaryButtonColor : clrIn;
  if( disabled != null && disabled) {
    clr = Colors.grey;
  }
  return IconButton(
    constraints: BoxConstraints(maxWidth: 30),
    padding: EdgeInsets.fromLTRB(0, 7, 0, 5),
    visualDensity: VisualDensity.compact,
    icon: Icon(
      icon == null ? Icons.remove_circle : icon,
      color: clr,
      size: size,
    ),
    onPressed: () {
      if( context != null ) {
        if (disabled == null || disabled == false) {
          onPressed!(context, paxNo, segNo,);
        }
      }
    },
  ); // return vidRoundButton(context, Icons.remove_circle_outline, onPressed, btnClr: Colors.white);
}


Widget vidRightButton(BuildContext context, {void Function(BuildContext)? onPressed}){
  return IconButton(
    icon: Icon(
      Icons.chevron_right,
      color:  actionButtonColor(),
    ),
    onPressed: () {
      onPressed!(context);
    },
  ); // return vidRoundButton(context, Icons.remove_circle_outline, onPressed, btnClr: Colors.white);
}


Widget vidRoundButton(BuildContext context,IconData icon,  void Function(BuildContext)? onPressed,{Color btnClr = Colors.white}){
  if( btnClr == null ) {
    btnClr =  actionButtonColor();
  }

  return IconButton(
    icon: Icon(
      icon,
      //color: gblSystemColors.primaryButtonColor,
    ),
    onPressed: () {
      onPressed!(context);
    },
  ); // retur


  /*return ElevatedButton(
    onPressed:() => onPressed(context),
    style: ElevatedButton.styleFrom(
      primary: btnClr,
      shape: CircleBorder(),),
    child:
    Icon(icon, color: Colors.white,
    ),
  );*/
}

Widget vidLineButton(BuildContext context, Widget body, int index, void Function(BuildContext, int) onPressed) {
  return InkWell(
    splashColor: Colors.green,
    onTap:() => onPressed(context, index),
    child: body,
  );
}

class VidBlinkingButton extends StatefulWidget {
  final void Function(dynamic p)? onClick;
  final String title;
  final Color color;

  VidBlinkingButton({this.onClick, this.title='', this.color=Colors.white});

  @override
  _MyBlinkingButtonState createState() => _MyBlinkingButtonState();
}

class _MyBlinkingButtonState extends State<VidBlinkingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController ;

  @override
  void initState() {
    _animationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: MaterialButton(
        onPressed: () => widget.onClick!(context),
        child: Text(widget.title, style: TextStyle(color: Colors.white),),
        color: widget.color,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

Widget vidDemoButton(BuildContext context, String caption ,void Function(dynamic p) onClick ){
  return   ElevatedButton(
    style: ButtonStyle( backgroundColor: MaterialStateProperty.all<Color>(gblSystemColors.primaryButtonColor), ),
      onPressed: () => onClick(context),
  child: Text(caption, style: TextStyle(color: Colors.white),),
  );
}

Widget vidCancelButton(BuildContext context, String caption ,void Function(dynamic p) onClick ) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: cancelButtonColor(),
    ),
    child: TrText(caption, style: TextStyle(
         color: Colors.black),),
    onPressed: () {
        onClick(context);
      },
  );
}
