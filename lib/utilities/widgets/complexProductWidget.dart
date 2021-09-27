import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
//import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/products.dart';
import 'package:vmba/payment/productViews.dart';
import '../helper.dart';
import 'appBarWidget.dart';

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
        list.add(Text(pax.firstName + ' ' + pax.surname), );
        list.add(getProductRow(widget.product));
      });
    }
    return  Column(
        children: list,
    );
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
              children: _getBody(),

            )
        )
    );
  }

  List<Widget> _getBody() {
    List<Widget> list = [];

    if (widget.product.paxRelate) {
      widget.pnrModel.pNR.names.pAX.forEach((pax) {
        list.add(Text(pax.firstName + ' ' + pax.surname),);
        list.add(getProductRow(widget.product));
      });
    } else {
      list.add(getProductRow(widget.product));
    }

    return list;
  }
}
  Row getProductRow(Product prod) {
    List<Widget> widgets = [];

    widgets.add(Image(image: getBagImage(prod.productCode),
      fit: BoxFit.fill,
      height: 40,
      width: 40,),);

    widgets.add(Align(alignment: Alignment.centerLeft,
        child: TrText(prod.productName)),);

    widgets.add(Spacer(),);
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

    return Row(children: widgets);
  }

