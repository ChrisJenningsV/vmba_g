

import 'package:flutter/material.dart';

Widget v3Card( Widget body,void Function()? onPressed,  {Color backClr = Colors.black12, Widget? title, String ? subTitle} ){

  return  Card(
      child: InkWell(
        onTap:() {
          onPressed!();
        },
        child:  Column(
            children: [
              // add title
              title as Widget,
              // add content
              Card(
                  color: Colors.white,
                  elevation: 0,
                  child: body
                 ,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))

              )
              ,
            ]
        ),
      ),
      color: backClr,
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)))
  );
}