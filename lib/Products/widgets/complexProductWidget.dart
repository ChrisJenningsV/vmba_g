import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:vmba/Products/controller/productCommands.dart';
import 'package:vmba/components/showDialog.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/components/vidCards.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/products.dart';
import 'package:vmba/utilities/widgets/buttons.dart';
import '../../components/vidButtons.dart';
import '../../utilities/helper.dart';
import '../../utilities/widgets/appBarWidget.dart';
import '../productFunctions.dart';

class ComplextProductWidget extends StatefulWidget {
  final Product product;
  final Product savedProduct;
  final PnrModel pnrModel;
  final bool isMmb;
  final void Function(Product product) onSaved;
  final void Function(String msg) onError;

  ComplextProductWidget({Key key, this.product,this.savedProduct, this.pnrModel, this.onSaved, this.onError, this.isMmb})
      : super(key: key);

  //final LoadDataType dataType;

  ComplextProductWidgetState createState() => ComplextProductWidgetState();
}

class ComplextProductWidgetState extends State<ComplextProductWidget> {

  int minCount;

  @override
  void initState() {

    // set up count
    //widget.product.count = 0;
    /*if( widget.pnrModel.pNR != null && widget.pnrModel.pNR.mPS != null && widget.pnrModel.pNR.mPS.mP != null ){
      widget.pnrModel.pNR.mPS.mP.forEach((element) {
        if( element.mPID == widget.product.productCode){
          widget.product.count+=1;
        }
      });
    }*/
    widget.product.resetProducts(widget.pnrModel);

    if( widget.isMmb) {
        if(widget.product.segmentRelate || widget.product.paxRelate){

        } else {
          minCount = widget.product.count(0);
        }
    } else {
      minCount = 0;
    }

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: appBar(
        context,
        widget.product.productName,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      //endDrawer: DrawerMenu(),
      body: _body(),
    );
  }

  Widget _body() {
    List<Widget> list = [];
    List<Widget> rowList = [];
    List<Widget> headList = [];
    String units = '';


    if( widget.product.unitOfMeasure == null || widget.product.unitOfMeasure.isEmpty) {
      units += translate(' Per Unit');
    } else {
      units = translate(' Per ') + widget.product.unitOfMeasure;
    }

      rowList.add(Image(image: getProductImage(widget.product),
        fit: BoxFit.fill,
        height: 40,
        width: 40,));

    rowList.add(Padding( padding: EdgeInsets.only(right: 15,)));
    rowList.add(Column( children: [
      Text(formatPrice(widget.product.currencyCode, widget.product.getPrice()) ),
      Text(units)
    ]));
    rowList.add(Spacer(),);
  /*  if( widget.product.count() ){
      rowList.add(Align(
        alignment: Alignment.topRight,
          child: Text(formatPrice(widget.product.currencyCode, widget.product.getPrice()* widget.product.count ), textScaleFactor: 1.5,)));
    }*/

    headList.add(new Row(    children: rowList,));

    // product details
    if( widget.product.productDescription != null && widget.product.productDescription.isNotEmpty ) {
      headList.add(new Row(
        children: [
          // get text (strip and HTML)
          Expanded( child:  getHtmlDoc(widget.product.productDescription))
        ],
      ));
    }
    list.add(Card(
        child: Padding(
            padding: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
            child: Column(children: headList,) )
    ));

    list.add(Divider());

    //list.add(Padding(padding: EdgeInsets.only(top: 60)));
    int segNo = 1;
    if (widget.product.segmentRelate) {
      widget.pnrModel.pNR.itinerary.itin.forEach((itin) {
        if( widget.product.applyToClasses == null ||
            widget.product.applyToClasses.isEmpty ||
            widget.product.applyToClasses.contains( itin.xclass)) {
          if (isThisProductValid(widget.pnrModel, widget.product, segNo)) {
            list.add(ProductFlightCard(
              pnrModel: widget.pnrModel,
              product: widget.product,
              savedProduct: widget.savedProduct,
              isMmb: widget.isMmb,
              itin: itin,
              stateChange: () {
                setState(() {

                });
              },
            ));
          }
        }
        segNo+=1;
      });
    } else {
       // not seg related
      widget.pnrModel.pNR.names.pAX.forEach((pax){
        if( pax.paxType != 'IN') {
          //list.add(Text(pax.firstName + ' ' + pax.surname), );
          bool disable = widget.product.getCount(int.parse(pax.paxNo), 0) == 0;
          if (widget.isMmb) {
            disable = widget.product.getCount(int.parse(pax.paxNo), 0) <=
                widget.savedProduct.getCount(int.parse(pax.paxNo), 0);
          }

          list.add(getProductPaxRow(widget.product, pax, 0, 0, disable,
            onDelete: (int paxNo, int segNo) {
              if (widget.product.getCount(paxNo, segNo) > 0) {
                setState(() {
                  widget.product.removeProduct(paxNo, segNo);
                });
              }
            },
            onAdd: (int paxNo, int segNo) {
              int max = widget.product.maxQuantity ?? 1;
              if (widget.product.getCount(paxNo, segNo) < max) {
                setState(() {
                  widget.product.addProduct(paxNo, segNo);
                });
              }
            },
          )
          );
        }
      });
    }

    // add button
    list.add(Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
        child: saveButton( text: 'SAVE', onPressed: () {validateAndSave();}, icon: Icons.check ),
    )
    );

    return SingleChildScrollView( child:  Column(
        children: list,
    ));
  }
  void validateAndSave() {
     saveProduct(widget.product, widget.pnrModel.pNR, onComplete: onComplete, onError: onError);
  }

  void onError(String msg){
    widget.onError(msg);
    showAlertDialog(context, 'Error', msg);

  }

    void onComplete(PnrModel pnrModel, dynamic p){
    widget.onSaved(widget.product);
    try {
      Navigator.pop(context, pnrModel);
    } catch (e) {
      print('Error: $e');
    }

  }
}



class ProductFlightCard extends StatefulWidget {
  final Product product;
  final Product savedProduct;
  final PnrModel pnrModel;
  final Itin itin;
  final bool isMmb;
  final void Function() stateChange;

  ProductFlightCard({Key key, this.product, this.savedProduct, this.pnrModel, this.itin, this.stateChange, this.isMmb})
      : super(key: key);

  //final LoadDataType dataType;

  ProductFlightCardState createState() => ProductFlightCardState();
}

class ProductFlightCardState extends State<ProductFlightCard> {

  @override
  void initState() {
    if( widget.product.maxQuantity == null ){
      widget.product.maxQuantity = 999;
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return vidExpanderCardExt(context,
        Row(children: [
          FutureBuilder(
            future: cityCodeToName(widget.itin.depart),
            initialData: widget.itin.depart.toString(),
            builder:
                (BuildContext context, AsyncSnapshot<String> text) {
              return new Text(text.data);
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
              return new Text(text.data);
            },
          ),
        ]), true,
        _getBody(int.parse(widget.itin.line)));

  }

  List<Widget> _getBody(int lineNo) {
    List<Widget> list = [];

    if (widget.product.paxRelate) {
      widget.pnrModel.pNR.names.pAX.forEach((pax) {
       // list.add(Text(pax.firstName + ' ' + pax.surname),);
        bool disable = widget.product.getCount(int.parse(pax.paxNo), lineNo) == 0;
        if( widget.isMmb && widget.savedProduct != null ){
            disable = widget.product.getCount(int.parse(pax.paxNo), lineNo) <= widget.savedProduct.getCount(int.parse(pax.paxNo), lineNo);
        }

        if(pax.paxType != 'IN') {
          list.add(
              getProductPaxRow(widget.product, pax, lineNo, lineNo, disable,
                onDelete: (int paxNo, int segNo) {
                  if (widget.product.getCount(paxNo, segNo) > 0) {
                    setState(() {
                      widget.product.removeProduct(paxNo, segNo);
                      widget.stateChange();
                    });
                  }
                },
                onAdd: (int paxNo, int segNo) {
                  int max = widget.product.maxQuantity ?? 1;
                  if (widget.product.getCount(paxNo, segNo) < max) {
                    widget.product.addProduct(paxNo, segNo);
                    widget.stateChange();
                  };
                  setState(() {});
                },
              )
          );
        }
      });
    } else {
      list.add(getProductRow(widget.product, lineNo,
        onDelete: (int paxNo, int segNo) {
        if( widget.product.getCount(paxNo, segNo) > 0) {
          setState(() {
            widget.product.removeProduct(paxNo, segNo);
            widget.stateChange();
          });
        }},
        onAdd: (int paxNo, int segNo) {
          if( widget.product.getCount(paxNo, segNo) < widget.product.maxQuantity) {
            setState(() {
              widget.product.addProduct(paxNo, segNo);
              widget.stateChange();
            });
          }},
      )
      );
    }

    return list;
  }
}

Widget getProductPaxRow(Product prod, PAX pax, int segNo, int lineNo, bool disable, { void Function(int paxNo, int segNo) onDelete, void Function(int paxNo, int segNo) onAdd}) {
  List<Widget> widgets = [];

  widgets.add(Align(alignment: Alignment.centerLeft,
      child: Text(pax.firstName + ' ' + pax.surname)),);

  widgets.add(Spacer(),);


    widgets.add(Align(alignment: Alignment.centerRight,
        child: Row(children: [
          vidRemoveButton(null, paxNo: int.parse(pax.paxNo), segNo: segNo,
              disabled: disable,
              onPressed: (context, paxNo, segNo) {
            if(gblLogProducts) logit('onDelete p=${pax.paxNo} s=$segNo');
              onDelete(paxNo, segNo);
          }),

          new Text(prod.getCount(int.parse(pax.paxNo), lineNo).toString(),
              style: TextStyle(fontSize: 20)),

        vidAddButton(null,
            disabled: prod.getCount(int.parse(pax.paxNo), segNo) >= prod.maxQuantity,
            onPressed: (context) {
          onAdd(int.parse(pax.paxNo), lineNo);
        }),

        ],)
    ));

  return Padding(padding: EdgeInsets.only(left: 10),
            child: Row(children: widgets));
}
Row getProductRow(Product prod, int segNo, { void Function(int paxNo, int segNo) onDelete, void Function(int paxNo, int segNo) onAdd}) {
    List<Widget> widgets = [];

      widgets.add(Image(image: getProductImage(prod),
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
              color: (prod.count(segNo) > 0) ? Colors.black : Colors.grey.shade300,),
            onPressed: () {
              onDelete(0, segNo);
            },
          ),
            new Text(prod.count(segNo).toString(),
                style: TextStyle(fontSize: 20)),
            new IconButton(icon: Icon(Icons.add_circle_outline,
                color: (prod.count(segNo) < prod.maxQuantity) ? Colors.black : Colors
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

Widget getHtmlDoc( String htmlData) {
  //dom.Document document = htmlparser.parse(htmlData);
  /// sanitize or query document here
  Widget html = Html(
    data: htmlData,
  );
  return html;
}