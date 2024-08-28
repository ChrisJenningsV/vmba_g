
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/trText.dart';
import '../../data/globals.dart';
import '../../utilities/helper.dart';
import '../../utilities/widgets/colourHelper.dart';





class V3TextFormField extends StatefulWidget  {
  String label = '';
  String? hintText ;
  TextEditingController controller;
  TextInputType? keyboardType;
  void Function(String?)? onSaved;
  IconData? icon;
  bool obscureText;
  String obscuringCharacter;
  String? Function(String?)? validator;
  List<TextInputFormatter>? inputFormatters;
  int? maxLength;
  AutovalidateMode? autovalidateMode;

  V3TextFormField(this.label, this.controller,
      {
        this.hintText,
        this.keyboardType,
        this.onSaved,
        this.icon,
        this.obscureText = false,
        this.obscuringCharacter = "*",
        this.validator,
        this.inputFormatters,
        this.maxLength,
        this.autovalidateMode,
    }
  );

  V3TextFormFieldState createState() => V3TextFormFieldState();
}
class V3TextFormFieldState extends State<V3TextFormField> {
  Color _colorText = Colors.black54;
  Color _backColor = Colors.black12;

  @override
  Widget build(BuildContext context) {
    const _defaultColor = Colors.black54;
    //const _focusColor = Colors.purple;

    return Container(
      //padding: EdgeInsets.symmetric(vertical: 15),
      child: Focus(
        onFocusChange: (hasFocus) {
          logit('focus change focus = $hasFocus');
          setState(() {
              _colorText = hasFocus ? focusColor() : _defaultColor;
              _backColor = hasFocus ? Colors.white : Colors.black12;
            });
        },

        child: TextFormField(
          //decoration: getV3Decoration(label              ),
          // Validate input Email
          keyboardType: TextInputType.emailAddress,
          controller: widget.controller,
          obscureText: widget.obscureText,
          obscuringCharacter: widget.obscuringCharacter,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          autovalidateMode: widget.autovalidateMode,
          validator: widget.validator,

          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: _backColor,
            focusColor: Colors.white,
            labelText: widget.label,
            labelStyle: TextStyle(color: _colorText),
            counterText: '',
            // Default Color underline
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
            ),

            // Focus Color underline
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: focusColor()),
            ),
            //prefixIconConstraints: BoxConstraints(maxWidth: 25),
            icon: widget.icon == null ? null : Icon(
              widget.icon as IconData,
              color: _colorText,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration getV3Decoration(String label, {String hintText='', Widget? prefixIcon, bool hasFocus = false}) {
  return InputDecoration(
    fillColor:  hasFocus ? Colors.white : Colors.grey.shade300,
    filled: true,
    counterText: '',
    hintText: hintText,
    prefixIcon: prefixIcon,
    labelStyle: TextStyle(color: Colors.grey),
    labelText: translate(label),

  );

}

Widget v3ActionButton(BuildContext context, String caption, void Function(BuildContext) onPressed,
    {IconData? icon, int iconRotation=0, bool wantIcon = true, Color backColor = Colors.grey, Color textColor = Colors.black87 } ) {
  ShapeBorder? shape;

  return
      ElevatedButton(
        style: ButtonStyle( backgroundColor: MaterialStateProperty.all<Color>(backColor), foregroundColor: MaterialStateProperty.all<Color>(textColor)),
        child: Row( children: [
            gblSettings.wantButtonIcons && wantIcon ? Icon(Icons.check,
                color: gblSystemColors.primaryButtonTextColor) : Container(),
                Text(caption),
            ],),
            onPressed: () {
              if(gblActionBtnDisabled == false ) {
                onPressed(context);
              }
            });

}

Widget v3EmailFormField(String label, TextEditingController controller, {void Function(String?)? onSaved}){
  return V3TextFormField(
    label,
    controller,
    //icon: Icons.email_outlined,
    keyboardType: TextInputType.emailAddress,
    onSaved: onSaved,
    inputFormatters: [
      FilteringTextInputFormatter.deny(RegExp("[#'!£^&*(){},|]"))
    ],
    maxLength: 100,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (value) {
      String er = validateEmail(value!.trim());
      if( er != '' ) return er;
      return null;
    },
  );
}
Widget v3FqtvPasswordFormField(String label, TextEditingController controller, {void Function(String?)? onSaved, bool validate = true}){
  return V3TextFormField(
    label,
    controller,
    obscureText: true,
    obscuringCharacter: "*",
    //icon: Icons.password_outlined,
    keyboardType: TextInputType.visiblePassword,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9!@%\$&*]"))
    ],
    maxLength: 100,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (value)  {
      if( validate == false) return '';
      return validateFqtvPassword(value);
    },

  );
}





Color focusColor() {
  return gblSystemColors.primaryButtonColor;
}
String? validateFqtvPassword(String? value){
  if(value != null && value.length >= 8 && value.length <= 16 ){
    String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@%\$&*]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    //logit('A-Z ${regExp.hasMatch(value)}');
    if(regExp.hasMatch(value)) {
      return null;
    }
  }
  return 'invalid password';
}