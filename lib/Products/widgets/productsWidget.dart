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
import '../../payment/choosePaymentMethod.dart';
import '../../utilities/helper.dart';
import '../../utilities/widgets/CustomPageRoute.dart';
import '../productCard.dart';
import '../seatCard.dart';

//ignore: must_be_immutable
class ProductsWidget extends StatefulWidget {
  NewBooking newBooking;
  PnrModel pnrModel;
  bool wantTitle;
  bool wantButton;
  bool isMMB;
  final Function(PnrModel pnrModel)? onComplete;

  ProductsWidget(
      { Key key = const Key("prodw_key"), required this.newBooking, required this.pnrModel, this.onComplete, this.wantTitle=false,this.wantButton = false , this.isMMB = false }) : super( key: key);

  //final LoadDataType dataType;

  ProductsWidgetState createState() =>
      ProductsWidgetState();
}

class ProductsWidgetState extends State<ProductsWidget> {
/*
  NetworkImage smallBag;
  NetworkImage cabinBag;
  NetworkImage holdBag;
*/
  PnrModel savedPnr = PnrModel();
  String errorMsg = '';

  @override
  void initState() {
    // TODO: implement initState
/*
    smallBag = bagImage('smallBag');
    cabinBag = bagImage('cabinBag');
    holdBag = bagImage('holdBag');
*/

    savedPnr = widget.pnrModel;
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
        children: getBagOptions(widget.newBooking, widget.pnrModel, savedPnr),));

    } else {
      list.add(Column( children: getBagOptions(widget.newBooking, widget.pnrModel, savedPnr),));
    }
    list.add(Divider());

    //Text('Procucts Widget', style: new TextStyle(fontSize: 26),);

    if( errorMsg != null && errorMsg.isNotEmpty){

        ScaffoldMessenger.of(context).showSnackBar(snackbar(errorMsg));
    }
    return Column(children: list,);
  }


  _loadData() async {
    //String currency = widget.pnrModel.pNR.basket.outstanding.cur;

    if (gblProducts == null || gblBookingCurrency != gblLastCurrecy || gblProductCacheDeparts != gblOrigin || gblProductCacheArrives != gblDestination){
      //gblBookingCurrency =currency;
      logit('loading products');
      gblProductCacheDeparts = gblOrigin;
      gblProductCacheArrives = gblDestination;
      gblLastCurrecy = gblSelectedCurrency;
      final http.Response response = await http.post(
          Uri.parse('${gblSettings.apiUrl}/product/getproducts'),
          headers: getApiHeaders(),
          body: json.encode(GetProductsMsg('en', currency: gblSelectedCurrency, cityCode: gblOrigin, arrivalCityCode: gblDestination ).toJson()));

      //if(_fullLogging) logit('dataLoader load data (${widget.dataType.toString()}) result ${response.statusCode}');

      if (response.statusCode == 200) {
        //logit('nearly loaded' );
        gblProducts = ProductCategorys.fromJson(response.body.trim());
        //logit('loaded' );
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


List<Widget> getBagOptions(NewBooking newBooking, PnrModel pnrModel, PnrModel savedPnr) {
  List<Widget> list = [];

  if( gblSettings.wantSeatsWithProducts && !widget.isMMB){
    gblPnrModel = pnrModel;
    list.add(new SeatCard(newBooking: newBooking));
  }


    // add  bag products
    if(gblProducts != null ) {
      gblProducts!.productCategorys.forEach((pc) {
        if( gblLogProducts ) {logit('products: add category ${pc.productCategoryName} ${pc.products.length} items');}

        list.add(new ProductCard( productCategory: pc, pnrModel: widget.pnrModel, savedPnr: savedPnr, isMmb: widget.isMMB, onComplete: widget.onComplete,
        onError: (msg)
        {
          errorMsg = msg;
          logit('add category error:$msg');
        }
        ));
      });
      /*if( widget.wantButton) {
        list.add(Padding(padding: EdgeInsets.only(left: 10, right: 10),
            child: vidActionButton(context,'Continue', onComplete, icon: Icons.check ) )
            //vidWideActionButton(context, 'Continue', onComplete))
              );
        list.add( Divider(height: 100,));
      }*/
      if( gblProducts!.productCategorys.length > 1) list.add( Divider(height: 200,));
    }

  return list;
}
  onComplete(BuildContext context ) {
    try {
      gblPaymentMsg = '';
      Navigator.push(
          context,
          //MaterialPageRoute(
          CustomPageRoute(
              builder: (context) => ChoosePaymenMethodWidget(
                newBooking: widget.newBooking, pnrModel: gblPnrModel!, isMmb: false,)
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

NetworkImage? bagImage(String name){
  try {
    Map pageMap = json.decode(gblSettings.productImageMap.toUpperCase());
    String? pageImage;
    if( pageMap[name.toUpperCase()] != null)
    {
      pageImage = pageMap[name.toUpperCase()];
    }
    if( pageImage == null || pageImage == '') {
      pageImage = name;
    }
    if( pageImage == null) {
      pageImage = 'blank';
    }

    return NetworkImage( '${gblSettings.gblServerFiles}/productImages/$pageImage.png');
  } catch(e) {
    logit(e.toString());
  }
  return null;
}


