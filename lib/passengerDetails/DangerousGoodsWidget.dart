import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/contactDetails/contactDetailsPage.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/products.dart';
import 'package:vmba/payment/productViews.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';

class DangerousGoodsWidget extends StatefulWidget {
  bool preLoadDetails = false;
  final PassengerDetail passengerDetailRecord;
  final NewBooking newBooking;
  final PnrModel pnr;
  final int journeyNo;
  final int paxNo;

  DangerousGoodsWidget({Key key, this.preLoadDetails, this.passengerDetailRecord, this.newBooking, this.pnr, this.paxNo, this.journeyNo})
      : super(key: key);

  //final LoadDataType dataType;

  DangerousGoodsWidgetState createState() => DangerousGoodsWidgetState();
}

class DangerousGoodsWidgetState extends State<DangerousGoodsWidget> {
  bool _buttonEnabled;
  bool continuePass;

  @override void initState() {
    _buttonEnabled = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: appBar(
        context,
        'Dangerous Goods',
      ),
      //endDrawer: DrawerMenu(),
      body: SingleChildScrollView( child:_body()),
    );
  }

  Widget _body() {
    List<Widget> list = [];

    list.add(TrText('The following is a non-exhaustive list of Prohibited Items'));

    //list.add(Padding(padding: EdgeInsets.only(top: 60)));
  list.add( Image(
      image: NetworkImage('${gblSettings.gblServerFiles}/pageImages/dangerousgoods.jpg'),
      height: gblIsIos ? 350 : 500,
      width: gblIsIos ? 220 : 250,
      fit: BoxFit.fill,
    ));

  list.add(CheckboxListTile(
    title: TrText("I confirm that I have read and understood this notice and there are no Dangerous Goods or Prohibited Items in my hand luggage or checked-in baggage."),
    value: _buttonEnabled,
    onChanged: (newValue) {
      setState(() {
        _buttonEnabled = newValue;
      });
    },
    controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
  ));

    list.add(ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0)),
          primary: _buttonEnabled ? gblSystemColors.primaryButtonColor : Colors.grey.shade200),
      onPressed: () async {
        if( _buttonEnabled == true ) {
          if( widget.newBooking != null ) {
            var _error = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ContactDetailsWidget(
                          newbooking: widget.newBooking,
                          preLoadDetails: widget.preLoadDetails,
                          passengerDetailRecord: widget.passengerDetailRecord,
                        )));
            //displayError(_error);
          } else {
            continuePass = true;
            Navigator.pop(context, continuePass);
          }
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check,
            color: Colors.white,
          ),
          TrText(
            'CONTINUE',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ));


    return  Column(
      children: list,
    );
  }
}

