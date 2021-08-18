import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/models/products.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/utilities/helper.dart';

class ProductCard extends StatefulWidget {
  final String productType;
  final List<Product> products;

 // ProductCardState appState = new ProductCardState();
  ProductCard({this.productType, this.products});
  ProductCardState createState() => ProductCardState();

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


/*
Card getProductCard(String title, List<Product> products ) {

  List<Widget> bags = [];
  int index = 0;

  products.forEach((prod) {
    if( prod.isBag() ) {
      bags.add(getProductRow(index++, products, prod));
    }
  });
  if( bags.length > 0 ) {
    bags.insert(0, ListTile(
      title: Text(translate(title), textScaleFactor: 1.25),));

    return Card(
      child: Column(
        children: bags,),
    );
  }
  return null;

  }

 */

  Row getProductRow(int index, List<Product> products, Product prod) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Image(image: getBagImage(prod.productCode)),
          Align(alignment: Alignment.centerLeft,
              child: TrText(prod.productName)),


          Align(alignment: Alignment.centerRight,
              child: Row(children: [new IconButton(
                icon: Icon(
                  Icons
                      .remove_circle_outline, // color: widget.systemColors.accentButtonColor,
                ),
                onPressed: () {
                  products[index].count == 0 ? null : products[index].count++;
                },
              ),
                new Text(products[index].count.toString(),
                    style: TextStyle(fontSize: 20)),
                new IconButton(
                  icon: Icon(
                    Icons
                        .add_circle_outline, //color: widget.systemColors.accentButtonColor
                  ),
                  onPressed: () {
                    addProduct(index);
                  },
                ),
              ],)
          )
        ]
    );
  }

  void delProduct(int index) {
    setState(() {
      widget.products[index].count = widget.products[index].count - 1;
    });
  }

  void addProduct(int index) {
    setState(() {
      widget.products[index].count = widget.products[index].count + 1;
    });
  }
}

NetworkImage getBagImage(String name){
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
