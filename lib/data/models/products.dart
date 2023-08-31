
import 'dart:convert';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/utilities/helper.dart';

import '../globals.dart';

class ProductCategorys {
  List<ProductCategory> productCategorys = List.from([ProductCategory()]);


  ProductCategorys.fromJson(String str) {
   // logit('ProductCategorys.fromJson');
    int index = 0;
    List<ProductCategory> cats = List<ProductCategory>.from(
       json.decode(str).map((x) => ProductCategory.fromJson(x)));

    productCategorys = cats;
  }

}

class ProductCategory {
  int productCategoryID=0;
  String productCategoryName='';
  bool subCategory=false;
  bool autoExpand=false;
  bool aggregateProducts=false;
  List <Product> products = List.from([Product()]);

  ProductCategory();

  Map toJson() {
    Map map = new Map();
    map['productCategoryID'] = productCategoryID;
    map['productCategoryName'] = productCategoryName;
    map['subCategory'] = subCategory;
    map['autoExpand'] = autoExpand;
    map['aggregateProducts'] = aggregateProducts;
    if (this.products != null) {
      //map['products'] = this.products.toJson();
    }

    return map;
  }

  ProductCategory.fromJson(Map<String, dynamic> json) {
    try {
      //logit('ProductCat.fromJ');
      if( json['productCategoryID'] != null )productCategoryID = json['productCategoryID'];
      if( json['productCategoryName'] != null )productCategoryName = json['productCategoryName'];
      if( json['subCategory'] != null ) {
        subCategory =
        (json['subCategory'] == true || json['autoExpand'] == 'true')
            ? true
            : false;
      }
      if( json['autoExpand'] != null ) {
        autoExpand =
        (json['autoExpand'] == true || json['autoExpand'] == 'true')
            ? true
            : false;
      }
      if( json['aggregateProducts'] != null ) {
        aggregateProducts =
        (json['aggregateProducts'] == true ||
            json['aggregateProducts'] == 'true')
            ? true
            : false;
      }
        if(json['products'] != null )products = _getProducts(json['products']);
      //logit('end ProductCat.fromJ');
    } catch(e) {
      logit(e.toString());
    }
  }

  List <Product> _getProducts(List<dynamic> data ) {
    List <Product> products = [];
    if( data == null) return products;

    int index = 0;
    data.forEach((p){
      //logit('add ${p.toString()}');
      // if( index < 1)
       products.add(Product.fromJson(p));
      index ++;
    });
    /*
    products = List<Product>.from(
        json.decode(str).map((x) => Product.fromJson(x)));
*/
    return products;
  }

}



class Products {
  List<Product> products = List.from([Product()]);

  Products();

  Products.fromJson(String str) {
    try {
    List<ProductCategory>.from(
        json.decode(str).map((x) => ProductCategory.fromJson(x)));
    } catch(e) {
      logit(e.toString());

    }
    //  choice.add( new Choice(value: 'e',description: 'end'));

  }


}
class prodCount{
  String key = '';
  int count = 0;

  prodCount(this.key, this.count);
}
class Product {
  int productID=0;
  String productCode='';
  String productName='';
  int currencyID=0;
  double productPriceCalc=0;
  double productPrice=0;
  double taxAmountCalc=0;
  double taxAmount=0;
  String currencyCode='';
  String taxCurrencyCode='';
  int taxID=0;
  double currencyRatetoNUC=0;
  int productcategoryID=0;
  String productType='';
  String mmbProductDescription='';
  String productDescription='';
  String productDescriptionText='';
  String productDescriptionURL='';
  String productImageURL='';
  int cityID=0;
  String cityCode='';
  String cityName='';
  String arrivalCityCode='';
  String arrivalCityName='';
  String via1='';
  bool commandLinePrice=false;
  String operator='';
  String additionalInfo='';
  bool requiresQuantity=false;
  int maxQuantity=0;
  String unitOfMeasure='';
  bool paxRelate=false;
  bool segmentRelate=false;
  bool restrictPurchaseToAllPaxOrNone=false;
  bool autoSelect=false;
  String productImageLink='';
  String applyToClasses='';
  bool routeSpecificCombinable=false;
  int displayOrder=0;
  int productImageIndex=0;
  bool displayOnwebsite=false;

//int count

List<prodCount>? curProducts; //= List.from([Product()]) ;


  Product();

  int count(int segNo) {
    if( this.curProducts == null || this.curProducts!.length == 0) {
      return 0;
    }
    int c = 0;
    this.curProducts!.forEach((element) {
      if(element.key.endsWith(':$segNo' )) {
        c +=1;
      }
    });
    return c;
  }


  bool isBag() {
    if( this.productType == 'BAG' || this.productCode.startsWith('BAG')) {
      return true;
    }
    return false;
  }
  bool isTransfer() {
  if( this.productType == 'TRAN' || this.productCode.startsWith('TRA')) {
    return true;
  }
  return false;
  }

  void resetProducts(PnrModel pnrModel) {
    curProducts = [];

    if( pnrModel != null && pnrModel.pNR != null && pnrModel.pNR.mPS != null && pnrModel.pNR.mPS.mP != null ){
      pnrModel.pNR.mPS.mP.forEach((element) {
        if( element.mPID == productCode){
          incProduct(int.parse(element.pax), int.parse(element.seg));
          //curProducts!.add(prodCount(getID(int.parse(element.pax), int.parse(element.seg)),1));
        }
      });
    }

  }
  bool hasItem(String paxNo, String segNo) {
    return curProducts!.contains(getID(int.parse(paxNo), int.parse(segNo)));
  }

  String getID(int paxNo, int segNo) {
    return '$paxNo:$segNo';
  }
  void incProduct(int paxNo, int segNo ) {
    if( curProducts == null) curProducts = [];
    String str = getID(paxNo, segNo);
    bool found = false;
    curProducts!.forEach((element) {
        if(element.key == str){
          element.count +=1;
          found = true;
        }
    });
    if(found == false ) {
      curProducts!.add(prodCount(str, 1));
    }
    // count +=1;

  }
  void xaddProduct(int paxNo, int segNo, int count ) {
    if( curProducts == null) curProducts = [];
    String str = getID(paxNo, segNo);
    curProducts!.add(prodCount(str, count));
   // count +=1;

  }
  void removeProduct(int paxNo, int segNo) {
    if( curProducts == null) curProducts = [];
    String str = getID(paxNo, segNo);

    int index = 0 ;
    int removeAt = -1;
    bool found = false;
    curProducts!.forEach((element) {
      if( element.key == str){
        if(element.count >1){
          element.count -=1;
        }else {
          removeAt = index;
        }

      }
      index += 1;
      /*if( found == false) {
        if (element == str) {
          found = true;
        //  count -=1;
        } else {

        }
      }*/
      });
    if(removeAt != -1 ) {
       curProducts!.removeAt(removeAt);
    }

  }

  int getCount(int paxNo, int segNo){
    if( curProducts == null){
      curProducts = [];
      return 0;
    }
    String str = getID(paxNo, segNo);
    int cnt = 0;
    curProducts!.forEach((element) {
      if( element.key == str){
       cnt= element.count;
      }
    });
    return cnt;
  }

  double getPrice() {
    double p = 0;
    if( productPrice != null ){
      p += productPrice;
    }
    if( taxAmount != null ){
      p += taxAmount;
    }
    return p;
  }

  Product.fromJson(Map<String, dynamic> json) {
    try {
      //count = 0;
      //logit('Product.fromJ');
      try {
        if (json['productID'] != null) productID = json['productID'];
        if (json['productCode'] != null) productCode = json['productCode'];
        if (json['productName'] != null) productName = json['productName'];
        if (json['currencyID'] != null) currencyID = json['currencyID'];
        if (json['currencyCode'] != null) currencyCode = json['currencyCode'];
        if (json['taxCurrencyCode'] != null)
          taxCurrencyCode = json['taxCurrencyCode'];
        if (json['taxID'] != null) taxID = json['taxID'];
        if (json['productcategoryID'] != null)
          productcategoryID = json['productcategoryID'];
        if (json['productType'] != null) productType = json['productType'];
        if (json['mmbProductDescription'] != null)
          mmbProductDescription = json['mmbProductDescription'];
        if (json['productDescription'] != null)
          productDescription = json['productDescription'];
        if (json['productDescriptionText'] != null)
          productDescriptionText = json['productDescriptionText'];
        if (json['productDescriptionURL'] != null)
          productDescriptionURL = json['productDescriptionURL'];
        if (json['productImageURL'] != null)
          productImageURL = json['productImageURL'];
        if (json['cityID'] != null) cityID = json['cityID'];
        if (json['cityCode'] != null) cityCode = json['cityCode'];
        if (json['cityName'] != null) cityName = json['cityName'];
        if (json['arrivalCityCode'] != null)
          arrivalCityCode = json['arrivalCityCode'];
        if (json['arrivalCityName'] != null)
          arrivalCityName = json['arrivalCityName'];
        if (json['via1'] != null) via1 = json['via1'];
        if (json['operator'] != null) operator = json['operator'];
        if (json['additionalInfo'] != null)
          additionalInfo = json['additionalInfo'];
        if (json['unitOfMeasure'] != null)
          unitOfMeasure = json['unitOfMeasure'];
        if (json['productImageLink'] != null)
          productImageLink = json['productImageLink'];
        if (json['productImageURL'] != null)
          productImageURL = json['productImageURL'];
        if (json['productImageIndex'] != null)
          productImageIndex = json['productImageIndex'];
        if (json['applyToClasses'] != null)
          applyToClasses = json['applyToClasses'];
        // ints
        if (json['maxQuantity'] != null) maxQuantity = json['maxQuantity'];
        // doubles
        if (json['currencyRatetoNUC'] != null)
          currencyRatetoNUC = json['currencyRatetoNUC'];
        if (json['productPriceCalc'] != null)
          productPriceCalc = json['productPriceCalc'];
        if (json['productPrice'] != null) productPrice = json['productPrice'];
        if (json['exPrice'] != null && json['exPrice'] != '') {
          productPrice = json['exPrice'];
          currencyCode = gblSelectedCurrency;
        }
        if (json['taxAmountCalc'] != null)
          taxAmountCalc = json['taxAmountCalc'];
        if (json['taxAmount'] != null) taxAmount = json['taxAmount'];
        // bools
        if (json['commandLinePrice'] != null)
          commandLinePrice = parseBool(json['commandLinePrice']);
        if (json['requiresQuantity'] != null)
          requiresQuantity = parseBool(json['requiresQuantity']);
        if (json['paxRelate'] != null) paxRelate = parseBool(json['paxRelate']);
        if (json['segmentRelate'] != null)
          segmentRelate = parseBool(json['segmentRelate']);
        if (json['restrictPurchaseToAllPaxOrNone'] != null)
          restrictPurchaseToAllPaxOrNone =
              parseBool(json['restrictPurchaseToAllPaxOrNone']);
        if (json['autoSelect'] != null)
          autoSelect = parseBool(json['autoSelect']);
        if (json['routeSpecificCombinable'] != null)
          routeSpecificCombinable = parseBool(json['routeSpecificCombinable']);
        if (json['displayOnwebsite'] != null)
          displayOnwebsite = parseBool(json['displayOnwebsite']);

        if (json['displayOrder'] != null) displayOrder = json['displayOrder'];
        //logit('end Product.fromJ');
      }
      catch(e){
        logit('p ${e.toString()}');

      }
    } catch(e) {
      logit(e.toString());
    }
  }
}

class GetProductsMsg {
  String bookingCityCurrencyCode;
  String productCategoryID;
  String productCategoryName;
  String productType;
  String via1;
  String cityCode;
  String arrivalCityCode;
  String currency;
  bool includeHotels;
  bool displayOnWebsiteOnly;

  GetProductsMsg(
      this.bookingCityCurrencyCode ,
      {    this.arrivalCityCode = '',
    this.cityCode = '',
    this.displayOnWebsiteOnly = true,
    this.includeHotels = false,
    this.productCategoryID = '',
    this.productCategoryName = '',
    this.productType = '',
    this.currency = '',
    this.via1= '',
  });

  Map toJson() {
    Map map = new Map();
    map['BookingCityCurrencyCode'] = bookingCityCurrencyCode;
    map['ArrivalCityCode'] = arrivalCityCode;
    map['CityCode'] = cityCode;
    map['DisplayOnWebsiteOnly'] = displayOnWebsiteOnly;
    map['IncludeHotels'] = includeHotels;
    map['ProductCategoryID'] = productCategoryID;
    map['ProductCategoryName'] = productCategoryName;
    map['ProductType'] = productType;
    map['Via1'] = via1;
    map['currency'] = currency;
    return map;
  }
}
