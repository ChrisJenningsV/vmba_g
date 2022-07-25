import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/products.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';

import '../../utilities/helper.dart';
import '../productFunctions.dart';
import 'complexProductWidget.dart';

//ignore: must_be_immutable
class ProductsWidget extends StatefulWidget {
  NewBooking newBooking;
  PnrModel pnrModel;
  final Function(PnrModel pnrModel) onComplete;

  ProductsWidget(
      { Key key, this.newBooking, this.pnrModel, this.onComplete  }) : super( key: key);

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

  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    list.add(ExpansionTile(
      tilePadding: EdgeInsets.only(left: 0),
      initiallyExpanded: false,
      title: Text(
        'Travel Extras',
      ),
      children: getBagOptions(widget.newBooking, widget.pnrModel),));
    list.add(Divider());

    //Text('Procucts Widget', style: new TextStyle(fontSize: 26),);

    if( errorMsg != null && errorMsg.isNotEmpty){

        ScaffoldMessenger.of(context).showSnackBar(snackbar(errorMsg));
    }
    return Column(children: list,);
  }



List<Widget> getBagOptions(NewBooking newBooking, PnrModel pnrModel) {
  List<Widget> list = [];

  if ( newBooking != null ) {
    newBooking.passengerDetails.forEach((pax) {

      pnrModel.pNR.fareQuote.fareStore.forEach((element) {
        if( (element.pax == pax.paxNumber ) && (element.fSID.contains('MPS') == false)) {
          // get fq for pax
          var segCount = element.segmentFS.length;

          var holdBagWt = element.segmentFS[0].holdWt;
          var holdBagPcs = element.segmentFS[0].holdPcs;
          var handBagWt = element.segmentFS[0].handWt;
          if( holdBagWt != null &&  holdBagWt.endsWith('K') ){
            holdBagWt = holdBagWt.replaceAll('K', 'Kg');
          }

          if( holdBagPcs == null || holdBagPcs == '0') {
            holdBagPcs = holdBagWt;
            holdBagWt = '';
          }
          //var holdBagWtRet = '';
          var holdBagPcsRet = '';
          var handBagWtRet = '';
          var holdBagWtRet = '';
          if( segCount > 1) {
            holdBagWtRet = element.segmentFS[1].holdWt;
            holdBagPcsRet = element.segmentFS[1].holdPcs;
            handBagWtRet = element.segmentFS[1].handWt;
            if( holdBagPcsRet == null || holdBagPcsRet == '0') {
              holdBagPcsRet = holdBagWtRet;
              holdBagWtRet = '';
            }
          }
          if( holdBagWt == null ){
            holdBagWt = '0';
          }
          list.add( Card( child:
          Padding( padding: EdgeInsets.only(top: 3, left: 6, right: 6, bottom: 2),
              child: ExpansionTile(
                title: Text('${pax.title} ${pax.firstName} ${pax.lastName} ' +
                    translate('allowance'),
                    textScaleFactor: 1),
                children: [
                  if( segCount > 1) getBaggageRow(null, null, null, null, null),

                  getBaggageRow(smallBag, handBagWt, handBagWtRet, 'Hand Luggage', ''),
                  //              Divider(),
                  Divider(),
                  getBaggageRow(holdBag, holdBagPcs, holdBagPcsRet,'Checked Luggage', holdBagWt )
                ],)
          )
          ));


        }
      });
    });
    // add  bag products
    if(gblProducts != null ) {
      gblProducts.productCategorys.forEach((pc) {
        logit('products: add category ${pc.productCategoryName} ${pc.products.length} items');

        list.add(new ProductCard( productCategory: pc, pnrModel: widget.pnrModel, onComplete: widget.onComplete,
        onError: (msg)
        {
          errorMsg = msg;
          logit('add category error:$msg');
        }
        ));
      });
    }

  }
  return list;
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
              height: 40,
              width: 40,
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
class ProductCard extends StatefulWidget {
  final ProductCategory productCategory ;
  PnrModel pnrModel;
  void Function(PnrModel pnrModel) onComplete;
  void Function(String msg) onError;


  // ProductCardState appState = new ProductCardState();
  ProductCard({this.productCategory, this.pnrModel, this.onComplete, this.onError});
  ProductCardState createState() => ProductCardState();

}

class ProductCardState extends State<ProductCard> {
  String title;

  @override
  initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bags = [];
    int index = 0;

    widget.pnrModel.pNR.dumpProducts('build');


    widget.productCategory.products.forEach((prod) {
      if( isThisProductValid(prod)) {
   //     logit('products: add ${prod.productName}');
        bags.add(getProductRow(index++, prod));
      } else {
     //   logit('products: NOT add ${prod.productName}');
      }
    });

    if (bags.length > 0) {
 //     bags.insert(0, ListTile(
  //      title: Text(translate(widget.productCategory.productCategoryName), textScaleFactor: 1.25),));

      return Card(
          child: Padding( padding: EdgeInsets.only(top: 5, left: 6, right: 6, bottom: 3),
              child: ExpansionTile(
                initiallyExpanded: widget.productCategory.autoExpand ,
                title: Text(translate(widget.productCategory.productCategoryName), textScaleFactor: 1.25),
                children: bags,)
          )
      );
    }
    return Container();
  }

  bool isThisProductValid(Product p) {
    bool isValid = false;
    if( p.applyToClasses == null || p.applyToClasses.isEmpty) {
      isValid = true;
    } else {
      widget.pnrModel.pNR.itinerary.itin.forEach((element) {
        if (p.applyToClasses.contains(element.xclass)) {
          isValid = true;
        }
      });
    }
    return isValid;
  }

  Row getProductRow(int index, Product prod) {
    List<Widget> widgets = [];

    // check for this product in pnr
    int noItems = widget.pnrModel.pNR.productCount(prod.productCode);

    if( noItems > 0 ) {
      widgets.add(Text(noItems.toString()));
    }

      widgets.add(Image(image: getBagImage(prod),
        fit: BoxFit.fill,
        height: 40,
        width: 40,),);

    widgets.add(Align(alignment: Alignment.centerLeft,
        child: TrText(prod.productName)),);

    widgets.add(Spacer(),);
    if( prod.productDescription != null && prod.productDescription.isNotEmpty ) {
      widgets.add(ElevatedButton(
        onPressed: () {
          showHtml(context, prod.productName, prod.productDescription);
        },
        style: ElevatedButton.styleFrom(
          primary: gblSystemColors
              .primaryButtonColor,
          shape: CircleBorder(),),
        child:
        Icon(Icons.info, color: Colors.white,
        ),
      ));
    }


        if (prod.paxRelate == false && prod.segmentRelate == false) {
      widgets.add(Align(alignment: Alignment.centerRight,
          child: Row(children: [new IconButton(
            icon: Icon(Icons.remove_circle_outline,),
            onPressed: () {
              //delProduct(index);
              //products[index].count == 0 ? null : products[index].count++;
            },
          ),
            new Text(prod.count.toString(),
                style: TextStyle(fontSize: 20)),
            new IconButton(icon: Icon(Icons.add_circle_outline,),
              onPressed: () {
                // addProduct(index);
              },
            ),
          ],)
      ));
    } else {
      // more button
      widgets.add(ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              SlideTopRoute(
                  page: ComplextProductWidget( product: prod, pnrModel: widget.pnrModel, onSaved: (product) {
                    //saveProduct(product, widget.pnrModel.pNR.rLOC);
                    },
                    onError: (msg){
                      widget.onError(msg);
                    },
                  ))).then((pnrMod) {
                    if( pnrMod != null ) {
                      widget.pnrModel = pnrMod;
                      setState(() {

                      });
                      widget.onComplete(pnrMod);
                      } else {
                      setState(() {

                      });
                    }
            //updatePassengerDetails(passengerDetails, paxNo - 1);
          });
        },
        style: ElevatedButton.styleFrom(
            primary: gblSystemColors
                .primaryButtonColor,
            shape: CircleBorder(),),
        child:
            Icon(
              Icons.arrow_right,
              color: Colors.white,

            ),
      )
      );


    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widgets
    );

  }
  bool hasContent() {
    return true;
  }


}

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


