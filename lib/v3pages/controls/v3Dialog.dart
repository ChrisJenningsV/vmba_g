






import 'package:flutter/material.dart';

import '../../components/trText.dart';
import '../../components/vidButtons.dart';
import '../../data/globals.dart';
import '../v3Constants.dart';

void v3ShowDialog(BuildContext context,String caption,
    {Widget? content, IconData? icon=null, String txtContent = 'No Content', bool wantCancel=false, String actionButtonText = 'OK',
      void Function(BuildContext, void Function()? )? onComplete}) {
  gblActionBtnDisabled = false;

  List<Widget> getActions(GlobalKey<FormState> formKey, void Function() refresh) {
    List<Widget> actions = [];
    if (wantCancel) {
      actions.add(vidCancelButton(context, "CANCEL", (context) {
        Navigator.of(context).pop();
      },),);
    }
    actions.add(
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: gblSystemColors.primaryButtonColor,),
            child:
            (gblActionBtnDisabled) ? new Transform.scale(scale: 0.5,
                child: CircularProgressIndicator(color: Colors.white)) :
            TrText(actionButtonText),
            onPressed: () {
              if (gblActionBtnDisabled == false) {
                if (formKey!.currentState!.validate()) {
                  gblActionBtnDisabled = true;
                  refresh();
                  if (onComplete != null) onComplete(context, refresh);
                }
                //});
              }
            }
        )
    );
    return actions;
  }


  List <Widget> listT = [];
  if (icon != null) {
    listT.add(Icon(icon, color: gblSystemColors.headerTextColor,));
    listT.add(Padding(padding: EdgeInsets.all(5)));
  }
  listT.add(Text(caption,
    style: TextStyle(color: Colors.white),));
  Widget titleCaption = Row(
      children: listT
  );


  Widget title = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: gblSystemColors.primaryHeaderColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(dialogBorderRadius),
            topRight: Radius.circular(dialogBorderRadius),)),
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
      child: titleCaption
  );
  gblActionBtnDisabled = false;

  if (content == null) {
    content = Text(txtContent);
  }


  showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(

            builder: (context, setState) {
              final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
              return
                Form(
                    key: _formKey,
                    child: AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(dialogBorderRadius))),
                        titlePadding: EdgeInsets.only(top: 0),
                        title: title,
                        content: content,
                        actions: getActions(_formKey, (){
                          setState((){});
                        })

                    )
                );
            }
        );
      }
  );

}