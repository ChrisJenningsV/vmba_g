import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/products.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';

import '../../Helpers/networkHelper.dart';
import '../../components/vidButtons.dart';
import '../../payment/choosePaymentMethod.dart';
import '../../utilities/helper.dart';
import '../productCard.dart';
import '../seatCard.dart';

//ignore: must_be_immutable
class ProductsWidget extends StatefulWidget {
  NewBooking newBooking;
  PnrModel pnrModel;
  bool wantTitle;
  bool wantButton;
  bool isMMB;
  final Function(PnrModel pnrModel) onComplete;

  ProductsWidget(
      { Key key, this.newBooking, this.pnrModel, this.onComplete, this.wantTitle,this.wantButton = false , this.isMMB = false }) : super( key: key);

  //final LoadDataType dataType;

  ProductsWidgetState createState() =>
      ProductsWidgetState();
}

class ProductsWidgetState extends State<ProductsWidget> {
  NetworkImage smallBag;
  NetworkImage cabinBag;
  NetworkImage holdBag;
  String errorMsg;

  @override
  void initState() {
    // TODO: implement initState
    smallBag = bagImage('smallBag');
    cabinBag = bagImage('cabinBag');
    holdBag = bagImage('holdBag');

    errorMsg = '';

    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    if( widget.wantTitle) {
      list.add(ExpansionTile(
        tilePadding: EdgeInsets.only(left: 0),
        initiallyExpanded: false,
        title: Text(
          'Travel Extras',
        ),
        children: getBagOptions(widget.newBooking, widget.pnrModel),));

    } else {
      list.add(Column( children: getBagOptions(widget.newBooking, widget.pnrModel),));
    }
    list.add(Divider());

    //Text('Procucts Widget', style: new TextStyle(fontSize: 26),);

    if( errorMsg != null && errorMsg.isNotEmpty){

        ScaffoldMessenger.of(context).showSnackBar(snackbar(errorMsg));
    }
    return Column(children: list,);
  }

  _loadData() async {
    if (gblProducts == null ){
      logit('loading products');
      final http.Response response = await http.post(
          Uri.parse('${gblSettings.apiUrl}/product/getproducts'),
          headers: getApiHeaders(),
          body: json.encode(GetProductsMsg('en', cityCode: gblOrigin, arrivalCityCode: gblDestination ).toJson()));

      //if(_fullLogging) logit('dataLoader load data (${widget.dataType.toString()}) result ${response.statusCode}');

      if (response.statusCode == 200) {
        gblProducts = ProductCategorys.fromJson(response.body.trim());
        logit('loaded' );
        setState(() {

        });
      } else {
        if(response.body.startsWith('{')){
          try {
            Map m = jsonDecode(response.body);
            if(m['errors'] != null ){
            }
          } catch(e) {
            logit(e.toString());
          }

        }

      }
    }
  }


List<Widget> getBagOptions(NewBooking newBooking, PnrModel pnrModel) {
  List<Widget> list = [];

  if( gblSettings.wantSeatsWithProducts && !widget.isMMB){
    gblPnrModel = pnrModel;
    list.add(new SeatCard(newBooking: newBooking));
  }

  /*if ( newBooking != null && pnrModel != null  ) {
    newBooking.passengerDetails.forEach((pax) {
      pnrModel.pNR.fareQuote.fareStore.forEach((element) {
        if ((element.pax == pax.paxNumber) &&
            (element.fSID.contains('MPS') == false)) {
          // get fq for pax
          var segCount = element.segmentFS.length;

          var holdBagWt = element.segmentFS[0].holdWt;
          var holdBagPcs = element.segmentFS[0].holdPcs;
          var handBagWt = element.segmentFS[0].handWt;
          if (holdBagWt != null && holdBagWt.endsWith('K')) {
            holdBagWt = holdBagWt.replaceAll('K', 'Kg');
          }

          if (holdBagPcs == null || holdBagPcs == '0') {
            holdBagPcs = holdBagWt;
            holdBagWt = '';
          }
          //var holdBagWtRet = '';
          var holdBagPcsRet = '';
          var handBagWtRet = '';
          var holdBagWtRet = '';
          if (segCount > 1) {
            holdBagWtRet = element.segmentFS[1].holdWt;
            holdBagPcsRet = element.segmentFS[1].holdPcs;
            handBagWtRet = element.segmentFS[1].handWt;
            if (holdBagPcsRet == null || holdBagPcsRet == '0') {
              holdBagPcsRet = holdBagWtRet;
              holdBagWtRet = '';
            }
          }
          if (holdBagWt == null) {
            holdBagWt = '0';
          }
          list.add(Card(child:
          Padding(
              padding: EdgeInsets.only(top: 3, left: 6, right: 6, bottom: 2),
              child: ExpansionTile(
                title: Text('${pax.title} ${pax.firstName} ${pax.lastName} ' +
                    translate('allowance'),
                    textScaleFactor: 1),
                children: [
                  if( segCount > 1) getBaggageRow(null, null, null, null, null),

                  getBaggageRow(
                      smallBag, handBagWt, handBagWtRet, 'Hand Luggage', ''),
                  //              Divider(),
                  Divider(),
                  getBaggageRow(
                      holdBag, holdBagPcs, holdBagPcsRet, 'Checked Luggage',
                      holdBagWt)
                ],)
          )
          ));
        }
      });
    });
  }*/
    // add  bag products
    if(gblProducts != null ) {
      gblProducts.productCategorys.forEach((pc) {
        if( gblLogProducts ) {logit('products: add category ${pc.productCategoryName} ${pc.products.length} items');}

        list.add(new ProductCard( productCategory: pc, pnrModel: widget.pnrModel, isMmb: widget.isMMB, onComplete: widget.onComplete,
        onError: (msg)
        {
          errorMsg = msg;
          logit('add category error:$msg');
        }
        ));
      });
      if( widget.wantButton) {
        list.add(Padding(padding: EdgeInsets.only(left: 10, right: 10),
            child: vidWideActionButton(context, 'Continue', onComplete))
              );
        list.add( Divider(height: 100,));
      }
    }

  return list;
}
  onComplete(BuildContext context, dynamic p ) {
    try {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChoosePaymenMethodWidget(
                newBooking: widget.newBooking, pnrModel: gblPnrModel, isMmb: false,)
            //CreditCardExample()
          ));
    } catch (e) {
      print('Error: $e');
    }
  }

Row getBaggageRow(NetworkImage img, String count, String countRet, String title, String line2) {
  if( img == null && count == null ) {
    // heading row
    return Row(
        children: [
          Container(width: 40,),
          Container( width: 40,child: TrText('Out')),
          Container( width: 40,child: TrText('Ret')),
          Spacer(),
          Padding(padding: EdgeInsets.only(left: 5))
        ]);

  }
  if( count != null &&  count.endsWith('K')){
    count =  count.replaceAll('K', 'Kg');
  }
  if( count == null ) {
    count = '0';
  }
  if( countRet != null &&  countRet.endsWith('K')){
    countRet = countRet.replaceAll('K', 'Kg');
  }
  if( countRet == null ) {
    countRet = '0';
  }
  return Row(
      children: [
        Container(
            width: 40,
            child: Image(
              image: img,
              fit: BoxFit.fill,
              height: 50,
              width: 50,
            )),
        Container( width: 40,child: Text(count + ' ')),
        Container( width: 40,child: Text(countRet + ' ')),
        Spacer(),
        Column( children: [ TrText(title),
          Text(line2, textScaleFactor: 0.75,),
        ] ),
        Padding(padding: EdgeInsets.only(left: 5))
      ]);

}

}


//ignore: must_be_immutable

NetworkImage bagImage(String name){
  try {
    Map pageMap = json.decode(gblSettings.productImageMap.toUpperCase());
    String pageImage = pageMap[name.toUpperCase()];
    if( pageImage == null || pageImage.isEmpty) {
      pageImage = name;
    }
    if( pageImage == null) {
      pageImage = 'blank';
    }

    return NetworkImage( '${gblSettings.gblServerFiles}/productImages/$pageImage.png');
  } catch(e) {
    logit(e);
  }
  return null;
}


