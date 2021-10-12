import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
//import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/products.dart';
import 'package:vmba/Products/productViews.dart';
import 'package:vmba/utilities/widgets/buttons.dart';
import '../../utilities/helper.dart';
import '../../utilities/widgets/appBarWidget.dart';

class ComplextProductWidget extends StatefulWidget {
  final Product product;
  final PnrModel pnrModel;

  ComplextProductWidget({Key key, this.product, this.pnrModel})
      : super(key: key);

  //final LoadDataType dataType;

  ComplextProductWidgetState createState() => ComplextProductWidgetState();
}

class ComplextProductWidgetState extends State<ComplextProductWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: appBar(
        context,
        widget.product.productName,
      ),
      //endDrawer: DrawerMenu(),
      body: _body(),
    );
  }

  Widget _body() {
    List<Widget> list = [];

    List<Widget> headList = [];

    headList.add(new Row(
        children: [
    Image(image: getBagImage(widget.product.productCode),
      fit: BoxFit.fill,
      height: 40,
      width: 40,),
    Padding( padding: EdgeInsets.only(right: 15,)),

    Text(formatPrice(widget.product.currencyCode, widget.product.productPrice)),
    ]));

    // product details
    if( widget.product.productDescription != null && widget.product.productDescription.isNotEmpty ) {
      headList.add(new Row(
        children: [
          // get text (strip and HTML)
          Expanded( child: Column( children:  getDom(widget.product.productDescription), mainAxisSize: MainAxisSize.min, ))
        ],
      ));
    }
    list.add(Card(
        child: Padding(
            padding: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
            child: Column(children: headList,) )
    ));


    //list.add(Padding(padding: EdgeInsets.only(top: 60)));
    if (widget.product.segmentRelate) {
      widget.pnrModel.pNR.itinerary.itin.forEach((itin) {
        list.add(ProductFlightCard(
          pnrModel: widget.pnrModel,
          product: widget.product,
          itin: itin,
        ));
      });
    } else {
       // not seg related
      widget.pnrModel.pNR.names.pAX.forEach((pax){
        //list.add(Text(pax.firstName + ' ' + pax.surname), );
        list.add(getProductPaxRow(widget.product, pax, 0,
          onDelete: (int paxNo, int segNo) {
          if( widget.product.getCount(paxNo, segNo) > 0) {
            setState(() {
              widget.product.removeProduct(paxNo, segNo);
            });
        }},
          onAdd: (int paxNo, int segNo) {
            int max = widget.product.maxQuantity ?? 1;
            if( widget.product.getCount(paxNo, segNo) < max) {
              setState(() {
                widget.product.addProduct(paxNo, segNo);
              });
            }},
        )
        );
      });
    }

    // add button
    list.add(Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
        child: saveButton( text: 'SAVE', onPressed: () {validateAndSave();}, icon: Icons.check ),
    )
    );

    return  Column(
        children: list,
    );
  }
  void validateAndSave() {

  }
}



class ProductFlightCard extends StatefulWidget {
  final Product product;
  final PnrModel pnrModel;
  final Itin itin;

  ProductFlightCard({Key key, this.product, this.pnrModel, this.itin})
      : super(key: key);

  //final LoadDataType dataType;

  ProductFlightCardState createState() => ProductFlightCardState();
}

class ProductFlightCardState extends State<ProductFlightCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: EdgeInsets.only(top: 5, left: 6, right: 6, bottom: 3),
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Row(children: [
                new RotatedBox(
                    quarterTurns: 1,
                    child: new Icon(
                      Icons.airplanemode_active,
                      size: 20.0,
                    )),
                Padding(padding: EdgeInsets.only(left: 4),),
                FutureBuilder(
                  future: cityCodeToName(widget.itin.depart),
                  initialData: widget.itin.depart.toString(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> text) {
                    return new Text(text.data, textScaleFactor: 1.25);
                  },
                ),
                new Icon(
                  Icons.arrow_right,
                  size: 20.0,
                ),
                FutureBuilder(
                  future: cityCodeToName(widget.itin.arrive),
                  initialData: widget.itin.arrive.toString(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> text) {
                    return new Text(text.data, textScaleFactor: 1.25);
                  },
                ),
              ]),
              children: _getBody(int.parse(widget.itin.line)),

            )
        )
    );
  }

  List<Widget> _getBody(int lineNo) {
    List<Widget> list = [];

    if (widget.product.paxRelate) {
      widget.pnrModel.pNR.names.pAX.forEach((pax) {
       // list.add(Text(pax.firstName + ' ' + pax.surname),);
        list.add(getProductPaxRow(widget.product, pax, lineNo,
          onDelete: (int paxNo, int segNo) {
          if( widget.product.getCount(paxNo, segNo) > 0) {
            setState(() {
              widget.product.removeProduct(paxNo, segNo);
            });
          }},
          onAdd: (int paxNo, int segNo) {
            int max = widget.product.maxQuantity ?? 1;
            if( widget.product.getCount(paxNo, segNo) < max) {
              setState(() {
                widget.product.addProduct(paxNo, segNo);
              });
            }},
        )
        );
      });
    } else {
      list.add(getProductRow(widget.product, lineNo,
        onDelete: (int paxNo, int segNo) {
        if( widget.product.getCount(paxNo, segNo) > 0) {
          setState(() {
            widget.product.removeProduct(paxNo, segNo);
          });
        }},
        onAdd: (int paxNo, int segNo) {
          if( widget.product.getCount(paxNo, segNo) < widget.product.maxQuantity) {
            setState(() {
              widget.product.addProduct(paxNo, segNo);
            });
          }},
      )
      );
    }

    return list;
  }
}

Row getProductPaxRow(Product prod, PAX pax, int lineNo, { void Function(int paxNo, int segNo) onDelete, void Function(int paxNo, int segNo) onAdd}) {
  List<Widget> widgets = [];

  widgets.add(Align(alignment: Alignment.centerLeft,
      child: Text(pax.firstName + ' ' + pax.surname)),);

  widgets.add(Spacer(),);
  int max = 1;


  if( prod.maxQuantity != null && prod.maxQuantity > 0 ) {
    max = prod.maxQuantity;
  }
    widgets.add(Align(alignment: Alignment.centerRight,
        child: Row(children: [new IconButton(
          icon: Icon(Icons.remove_circle_outline,
            color: (prod.getCount(int.parse(pax.paxNo), lineNo) > 0) ? Colors.black : Colors.grey.shade300,),
          onPressed: () {
            onDelete(int.parse(pax.paxNo), lineNo);
          },
        ),
          new Text(prod.getCount(int.parse(pax.paxNo), lineNo).toString(),
              style: TextStyle(fontSize: 20)),
          new IconButton(icon: Icon(Icons.add_circle_outline,
              color: (prod.getCount(int.parse(pax.paxNo), lineNo) <max) ? Colors.black : Colors
                  .grey.shade300),
            onPressed: () {
              onAdd(int.parse(pax.paxNo), lineNo);
            },
          ),
        ],)
    ));

  return Row(children: widgets);
}
Row getProductRow(Product prod, int segNo, { void Function(int paxNo, int segNo) onDelete, void Function(int paxNo, int segNo) onAdd}) {
    List<Widget> widgets = [];



    widgets.add(Image(image: getBagImage(prod.productCode),
      fit: BoxFit.fill,
      height: 40,
      width: 40,),);

    widgets.add(Align(alignment: Alignment.centerLeft,
        child: TrText(prod.productName)),);

    widgets.add(Spacer(),);

    if( prod.maxQuantity != null && prod.maxQuantity > 0 ) {
      widgets.add(Align(alignment: Alignment.centerRight,
          child: Row(children: [new IconButton(
            icon: Icon(Icons.remove_circle_outline,
              color: (prod.count > 0) ? Colors.black : Colors.grey.shade300,),
            onPressed: () {
              onDelete(0, segNo);
            },
          ),
            new Text(prod.count.toString(),
                style: TextStyle(fontSize: 20)),
            new IconButton(icon: Icon(Icons.add_circle_outline,
                color: (prod.count < prod.maxQuantity) ? Colors.black : Colors
                    .grey.shade300),
              onPressed: () {
                onAdd(0, segNo);
              },
            ),
          ],)
      ));
    }

    return Row(children: widgets);
  }

