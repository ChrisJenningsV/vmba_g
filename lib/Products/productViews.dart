
import 'package:flutter/material.dart';
import 'package:vmba/Products/productFunctions.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/models/products.dart';

import '../data/globals.dart';
import '../utilities/helper.dart';

class ProductCard extends StatefulWidget {
  final String productType;
  final List<Product> products;

 // ProductCardState appState = new ProductCardState();
  ProductCard({this.productType, this.products});
  ProductCardState createState() => ProductCardState();

/*
  bool hasContent() {
    bool found = false;

    products.forEach((prod) {
      switch (productType) {
        case 'BAG':
          if( prod.isBag()){
            found = true;
            return true;
          }
          break;
        case 'TRAN':
          if( prod.isTransfer()){
            found = true;
            return true;
          }
          break;
      }
    });
    return found;
  }
*/

}
class ProductCardState extends State<ProductCard> {
  String title;

  @override
  initState() {
    super.initState();

    switch (widget.productType) {
      case 'BAG':
        title = 'Baggage Options';
        break;
      case 'TRAN':
        title = 'Airport Transfers';
        break;
      default:
        title = 'Type unknown [${widget.productType}';
        break;
    }
    widget.products.forEach((prod) {
      prod.resetProducts(gblPnrModel);
    });

  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bags = [];
    int index = 0;

    widget.products.forEach((prod) {
      if( widget.productType == 'BAG') {
        if (prod.isBag()) {
          bags.add(getProductRow(index++, widget.products, prod));
        }
      } else {
        if (!prod.isBag()) {
          bags.add(getProductRow(index++, widget.products, prod));
        }

      }
    });
    if (bags.length > 0) {
      bags.insert(0, ListTile(
        title: Text(translate(title), textScaleFactor: 1.25),));

      return Card(
        child: Column(
          children: bags,),
      );
    }
    return Container();
  }

  bool hasContent() {
    return true;
  }


  Row getProductRow(int index, List<Product> products, Product prod) {
    if( gblLogProducts ) { logit('getProductRow: ${prod.productName}'); }

    int pCount = products[index].count(0);
    String sPcount = pCount.toString();
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Image(image: getProductImage(prod)),
          Align(alignment: Alignment.centerLeft,
              child: TrText(prod.productName)),


          Align(alignment: Alignment.centerRight,
              child: Row(children: [new IconButton(
                icon: Icon(
                  Icons
                      .remove_circle_outline, // color: widget.systemColors.accentButtonColor,
                ),
                onPressed: () {
                  if( gblLogProducts ) { logit('getProductRow-delete: ${prod.productName}'); }
                  delProduct(index);
                  //products[index].count == 0 ? null : products[index].count++;
                },
              ),
                new Text(sPcount,
                    style: TextStyle(fontSize: 20)),
                new IconButton(
                  icon: Icon(
                    Icons
                        .add_circle_outline, //color: widget.systemColors.accentButtonColor
                  ),
                  onPressed: () {
                    if( gblLogProducts ) { logit('getProductRow-add: ${prod.productName}'); }
                    addProduct(index);
                  },
                ),
              ],)
          )
        ]
    );
  }

  void delProduct(int index) {
    if( widget.products[index].count(0) == 0 ) {
      return;
    }
    setState(() {
      widget.products[index].curProducts.removeAt(0);
    });
  }

  void addProduct(int index) {
    setState(() {
      widget.products[index].curProducts.add('0:0');
    });
  }
}

