import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/v3pages/v3Theme.dart';

import '../data/globals.dart';
import '../v3pages/fields/Pax.dart';

ThemeData _theme =    new ThemeData(
  primaryColor: Colors.blueAccent,
  primaryColorDark: Colors.blue,
);

TextEditingController _titleTextEditingController = TextEditingController();
TextEditingController _firstNameTextEditingController =  TextEditingController();
TextEditingController _middleNameTextEditingController =  TextEditingController();
TextEditingController _lastNameTextEditingController =  TextEditingController();
TextEditingController _dateOfBirthTextEditingController =  TextEditingController();

List <Widget> renderFqtvRegFields(BuildContext context ) {
  List <Widget> list = [];

  list.add( fqtvIntroBox());
  list.add(paxGetTitle(context, _titleTextEditingController,(value){
/*
    setState(() {
      widget.passengerDetail.title = value;
      _titleTextEditingController.text = translate(value);
      //FocusScope.of(context).requestFocus(new FocusNode());
    });
*/
  }));
  list.add( paxGetFirstName(
            _firstNameTextEditingController,
            onFieldSubmitted: (value){
              //widget.passengerDetail.firstName = value;
          },
            onSaved: (value){
              //widget.passengerDetail.firstName = value;
            },
  ));
  if( gblSettings.wantMiddleName) {
    list.add(paxGetMiddleName(_middleNameTextEditingController,
        onFieldSubmitted: (value){
      //    widget.passengerDetail.middleName = value;
        },
        onSaved: (value) {
          //  widget.passengerDetail.middleName = value;}
        }
        ));
  }
  list.add(paxGetLastName(_lastNameTextEditingController,
      onFieldSubmitted: (value){
        //widget.passengerDetail.lastName = value;
        },
      onSaved: (value){
  //      widget.passengerDetail.lastName = value;
    }
    ));

  if( gblSettings.wantFqtvDob) {
/*
    list.add(paxGetDOB(context,
        _dateOfBirthTextEditingController,
        widget.passengerDetail.paxType,
        _updateDateOfBirth, formSave, setState)

    ));
*/
  }

    return list;
}

Widget fqtvIntroBox() {
  return Card(
      color: gblSystemColors.primaryHeaderColor,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      ),

      clipBehavior: Clip.antiAlias,
      child: Padding(
      //padding: EdgeInsets.fromLTRB(15.0, 10, 15, 15),
          padding: EdgeInsets.all(0),
      child: Row(
        children: [
          Padding(padding: EdgeInsets.all(10), child: Image(
            image: NetworkImage('${gblSettings.gblServerFiles}/pageImages/fqtvRegister.png'),
            height: 60,
            width: 60,
            fit: BoxFit.fill,
          ) ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
            //  VBodyText('${gblSettings.fqtvName} Registration\n', size: TextSize.large,color: gblSystemColors.headerTextColor, ),
              VBodyText('Please complete this registration form.',color: gblSystemColors.headerTextColor),
              VBodyText('On completion you will receive an email',color: gblSystemColors.headerTextColor),
              VBodyText('containing your joining information.',color: gblSystemColors.headerTextColor),

            ],
          )
        ],
        )
      )
  );
}
