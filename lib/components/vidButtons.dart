
import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/utilities/widgets/colourHelper.dart';

import '../Helpers/settingsHelper.dart';
import '../data/globals.dart';

Widget vidWideTextButton(BuildContext context, String caption, void Function({int? p1}) onPressed, {IconData? icon, int iconRotation=0,int p1 = 0 } ) {
  return Expanded( child: vidTextButton(context, caption, onPressed, icon: icon, iconRotation: iconRotation, p1: p1 ));
}

Widget vidTextButton(BuildContext context, String caption, void Function({int? p1}) onPressed, {IconData? icon, int iconRotation=0,int? p1 } ) {
  Widget iconWidget = Container();
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


  return
     TextButton(
      onPressed: () {
        if( gblActionBtnDisabled == false ) {
          gblActionBtnDisabled = true;
          onPressed(p1: p1);
        }
      } ,
      style: TextButton.styleFrom(
          side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
          primary: gblSystemColors.textButtonTextColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TrText(
            caption,
            style: TextStyle(
                color: gblSystemColors
                    .textButtonTextColor),
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
  if(wantPageV2() ){
    radius = BorderRadius.circular(5.0);
  }
  return radius;
}

/*
  NEXT button at the bottom of most pages
 */
Widget vidWideActionButton(BuildContext context, String caption, void Function(BuildContext, dynamic) onPressed, 
    {IconData? icon, int iconRotation=0, var param1, double offset=0, bool wantIcon = true, bool availableOffline = false} ) {

  List<Widget> list = [];
  if( gblSettings.wantButtonIcons && !gblActionBtnDisabled && wantIcon) {
    list.add(Icon(
      Icons.check,
      color: Colors.white,
    ));
  }
  if( gblActionBtnDisabled ){
    list.add(Transform.scale(
      scale: 0.5,
      child: CircularProgressIndicator( color: Colors.white,),
    ));
    list.add(Padding(padding: EdgeInsets.all(2)));
  }
  list.add(TrText(
  caption,
  style: TextStyle(color: Colors.white),
  ));

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
      if(gblActionBtnDisabled == false &&  availableOffline == true || gblNoNetwork == false) {
        onPressed(context, param1);
      }
    },
    style: ElevatedButton.styleFrom(
        backgroundColor: actionButtonColor( availableOffline: availableOffline),
        shape: RoundedRectangleBorder(
            borderRadius: getButtonRadius())),
    child: Row(
      //mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children:  list
,
    ),
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
        primary: gblSystemColors.primaryButtonColor, //Colors.black,
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





Widget vidActionButton(BuildContext context, String caption, void Function(BuildContext) onPressed, {IconData? icon, int iconRotation=0, bool isRectangular=false } ) {
  ShapeBorder? shape;
  if( isRectangular == true ){
    shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5.0))
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
            label: TrText(
              caption,
              style: TextStyle(color: gblSystemColors.primaryButtonTextColor),
            ),

            icon: gblSettings.wantButtonIcons ? Icon(Icons.check,
                color: gblSystemColors.primaryButtonTextColor) : null ,
            backgroundColor: actionButtonColor() ,
            onPressed: () {
              if(gblActionBtnDisabled == false ) {
                onPressed(context);
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

Widget vidRemoveButton(BuildContext? context, {void Function(BuildContext, int, int)? onPressed, int paxNo = 0, int segNo = 0, bool disabled = false}){
  Color clr = gblSystemColors.primaryButtonColor;
      if( disabled != null && disabled) {
        clr = Colors.grey;
      }
  return IconButton(
    icon: Icon(
      Icons.remove_circle,
      color: clr,
    ),
    onPressed: () {
      if( context != null ) {
        if (disabled == null || disabled == false) {
          onPressed!(context as BuildContext, paxNo, segNo,);
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
  return   MaterialButton(
      onPressed: () => onClick(context),
  child: Text(caption, style: TextStyle(color: Colors.white),),
  color: Colors.lightBlue.shade400);
}