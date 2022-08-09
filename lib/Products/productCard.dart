


import 'package:flutter/material.dart';
import 'package:vmba/Products/productFunctions.dart';
import 'package:vmba/Products/widgets/complexProductWidget.dart';

import '../components/showDialog.dart';
import '../components/trText.dart';
import '../components/vidButtons.dart';
import '../components/vidCards.dart';
import '../data/globals.dart';
import '../data/models/pnr.dart';
import '../data/models/products.dart';
import '../utilities/helper.dart';
import '../utilities/widgets/snackbarWidget.dart';
import 'controller/productCommands.dart';

class ProductCard extends StatefulWidget {
  final ProductCategory productCategory ;
  PnrModel pnrModel;
  final bool isMmb;
  void Function(PnrModel pnrModel) onComplete;
  void Function(String msg) onError;


  // ProductCardState appState = new ProductCardState();
  ProductCard({this.productCategory, this.pnrModel, this.onComplete, this.onError, this.isMmb});
  ProductCardState createState() => ProductCardState();

}

class ProductCardState extends State<ProductCard> {
  String title;
  bool wantSaveButton;

  @override
  initState() {
    wantSaveButton = false;
    widget.productCategory.products.forEach((prod) {
      prod.resetProducts(widget.pnrModel);
    });
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bags = [];
    int index = 0;

    if( widget.pnrModel != null && widget.pnrModel.pNR != null  ) {
      widget.pnrModel.pNR.dumpProducts('build');
    }


    widget.productCategory.products.forEach((prod) {
      if( isThisProductValid(widget.pnrModel, prod, 0)) {
        if( prod.maxQuantity == null ){
          prod.maxQuantity = 999;
        }
        bags.add(getProductRow(index++, prod));
      } else {
        //   logit('products: NOT add ${prod.productName}');
      }
    });

    if (bags.length > 0) {
       return vidExpanderCard(context, widget.productCategory.productCategoryName, false, iconForTitle(widget.productCategory.productCategoryName) , bags);

    }
    return Container();
  }
  IconData iconForTitle( String title){
    if( title.toLowerCase().contains('baggage')) {
      return Icons.luggage;
    }
    if( title.toLowerCase().contains('arms') || title.contains('gun')) {
      return Icons.crisis_alert_rounded;
    }
    if( title.toLowerCase().contains('sport') || title.contains('winter')) {
      return Icons.downhill_skiing;
    }
    if( title.toLowerCase().contains('transfer') || title.contains('bus')) {
      return Icons.directions_bus;
    }

// default
    return Icons.luggage;
  }

  Widget getProductRow(int index, Product prod) {

    List<Widget> widgets0 = [];
    List<Widget> widgets = [];


    // check for this product in pnr
    if( widget.pnrModel != null && widget.pnrModel.pNR != null ) {
      int noItems = widget.pnrModel.pNR.productCount(prod.productCode);

      if (noItems > 0) {
        widgets.add(Text(noItems.toString()));
      }
    }

    widgets.add(Image(image: getProductImage(prod),
      fit: BoxFit.fill,
      height: 40,
      width: 40,),);

    widgets.add(Align(alignment: Alignment.centerLeft,
        child: TrText(prod.productName)),);

    widgets.add(Spacer(),);
    if( prod.productDescription != null && prod.productDescription.isNotEmpty ) {
      widgets.add(vidInfoButton(context, onPressed:(context) => {
        showHtml(context, prod.productName, prod.productDescription)
      }));

    }


    if (prod.paxRelate == false && prod.segmentRelate == false) {
      if( isThisProductSegmentFixed( widget.pnrModel, prod )) {
        // add segment this prod valid for
        widgets0.add(Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(left: 40)),
            Text(prod.cityCode),
            Icon(Icons.chevron_right),
            Text(prod.arrivalCityCode),
          ],
        ));
      }

      widgets.add(Align(alignment: Alignment.centerRight,
          child: Column(
           children: [
           Row(children: [
            vidRemoveButton(context,
              onPressed: (context,paxNo, segNo ) {
                if( gblLogProducts) {logit('removeProduct');}
                if( prod.count(0) > 0) {
                  prod.removeProduct(0, 0);
                  checkSaveButton(prod);
                  setState(() {

                  });
                }
              },
              disabled: (prod.count(0) == 0)
            ),
            new Text(prod.count(0).toString(),
                style: TextStyle(fontSize: 20)),
            vidAddButton(context, onPressed: (context) {
              if( gblLogProducts) {logit('addProduct');}
              // addProduct(index);
              if( prod.count(0) < prod.maxQuantity) {
                prod.addProduct(0, 0);
                checkSaveButton(prod);
                setState(() {

                });
              }
            },
                disabled: (prod.count(0) >= prod.maxQuantity)
            ),
          ],),
             (wantSaveButton == true ) ?
                 Row( children: [
                   vidWideActionButton(context, 'Save', onSave, param1: prod)
                 ]) : Container(),
          ]
      )
      ));
    } else {
      // more button
      widgets.add( vidRightButton(context, onPressed: (context) {
        Navigator.push(
            context,
            SlideTopRoute(
                page: ComplextProductWidget( product: prod, pnrModel: widget.pnrModel, isMmb: widget.isMmb, onSaved: (product) {
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
            if( widget.onComplete != null ) {
              widget.onComplete(pnrMod);
            }
          } else {
            setState(() {

            });
          }
          //updatePassengerDetails(passengerDetails, paxNo - 1);
        });
      },),

      );
    }

  if( widgets0.length > 0) {
    return Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: widgets0
        ),
    Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widgets
    ),
    ]);

  } else {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widgets
    );
  }

  }
  bool hasContent() {
    return true;
  }
  void checkSaveButton(Product prod){
    if(widget.pnrModel != null && widget.pnrModel.pNR != null &&
        widget.pnrModel.pNR.mPS != null  && widget.pnrModel.pNR.mPS.mP != null ){

      int count = widget.pnrModel.pNR.mPS.mP.where((p) => p.mPID == prod.productCode).length;
      // not same length - must have added or removed
      if( count != prod.curProducts.length){
        wantSaveButton = true;
        return;
      }
      // same length, check if same content
      widget.pnrModel.pNR.mPS.mP.forEach((element) {
        if( element.mPID == prod.productCode){
          // check if in curProd
          if(! prod.hasItem(element.pax, element.seg)) {
            wantSaveButton = true;
            return ;
          }
        }
      });
      wantSaveButton = false;
      return;
    }
    if( prod.count(0) > 0) {
      wantSaveButton = true;
    } else {
      wantSaveButton = true;
    }

  }
  void onSave(BuildContext context, dynamic p) {
    saveProduct(p, widget.pnrModel.pNR, onComplete: onComplete, onError: onError);
  }
  void onError(String msg){
    widget.onError(msg);
    showAlertDialog(context, 'Error', msg);

  }

  void onComplete(PnrModel pnrModel, dynamic prod){
    try {
      ScaffoldMessenger.of(context).showSnackBar(snackbar('Saved'));
      widget.pnrModel = gblPnrModel;
      checkSaveButton(prod);
      setState(() {

      });
      //Navigator.pop(context, pnrModel);
    } catch (e) {
      print('Error: $e');
    }
  }
}