import 'dart:convert';
import 'package:vmba/utilities/helper.dart';

class ProductCategorys {
  List<ProductCategory> productCategorys;


  ProductCategorys.fromJson(String str) {
    List<ProductCategory> cats = List<ProductCategory>.from(
        json.decode(str).map((x) => ProductCategory.fromJson(x)));

    productCategorys = cats;
  }

}

class ProductCategory {
  int productCategoryID;
  String productCategoryName;
  bool subCategory;
  bool autoExpand;
  bool aggregateProducts;
  List <Product> products;

  ProductCategory({this.aggregateProducts, this.autoExpand, this.productCategoryID, this.productCategoryName, this.subCategory, this.products});

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
      productCategoryID = json['productCategoryID'];
      productCategoryName = json['productCategoryName'];
      subCategory =
      (json['subCategory'] == true || json['autoExpand'] == 'true')
          ? true
          : false;
      autoExpand = (json['autoExpand'] == true || json['autoExpand'] == 'true')
          ? true
          : false;
      aggregateProducts =
      (json['aggregateProducts'] == true || json['aggregateProducts'] == 'true')
          ? true
          : false;
      products = _getProducts(json['products']);
    } catch(e) {
      logit(e.toString());
    }
  }

  List <Product> _getProducts(List<dynamic> data ) {
    List <Product> products = [];
    if( data == null) return null;

    data.forEach((p){
      products.add(Product.fromJson(p));
    });
    /*
    products = List<Product>.from(
        json.decode(str).map((x) => Product.fromJson(x)));
*/
    return products;
  }

}



class Products {
  List<Product> products;

  Products({this.products});

  /*
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.products != null) {
      data['products'] = this.products.map((v) => v.toJson()).toList();
    }
    return data;
  }

   */

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

class Product {
  int productID;
  String productCode;
  String productName;
  int currencyID;
  double productPriceCalc;
  double productPrice;
  double taxAmountCalc;
  double taxAmount;
  String currencyCode;
  String taxCurrencyCode;
  int taxID;
  double currencyRatetoNUC;
  int productcategoryID;
  String productType;
  String mmbProductDescription;
  String productDescription;
  String productDescriptionText;
  String productDescriptionURL;
  String productImageURL;
  int cityID;
  String cityCode;
  String cityName;
  String arrivalCityCode;
  String arrivalCityName;
  String via1;
  bool commandLinePrice;
  String operator;
  String additionalInfo;
  bool requiresQuantity;
  int maxQuantity;
  String unitOfMeasure;
  bool paxRelate;
  bool segmentRelate;
  bool restrictPurchaseToAllPaxOrNone;
  bool autoSelect;
  String productImageLink;
  String applyToClasses;
  bool routeSpecificCombinable;
  bool displayOrder;
  bool displayOnwebsite;

int count;

  Product({this.productCode, this.productName, this.productPrice, this.count = 0,
      this.productType,
  this.currencyCode,
  this.arrivalCityCode,
  this.additionalInfo,
  this.applyToClasses,
  this.arrivalCityName,
    this.autoSelect,
    this.cityCode,
    this.cityID,
    this.cityName,
    this.commandLinePrice,
    this.currencyID,
    this.currencyRatetoNUC,
    this.displayOnwebsite,
    this.displayOrder,
    this.maxQuantity,
    this.mmbProductDescription,
    this.operator,
    this.paxRelate,
    this.productcategoryID,
    this.productDescription,
    this.productDescriptionText,
    this.productDescriptionURL,
    this.productID,
    this.productImageLink,
    this.productImageURL,
    this.productPriceCalc,
    this.requiresQuantity,
    this.restrictPurchaseToAllPaxOrNone,
    this.routeSpecificCombinable,
    this.segmentRelate,
    this.taxAmount,
    this.taxAmountCalc,
    this.taxCurrencyCode,
    this.taxID,
    this.unitOfMeasure,
    this.via1
  });


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

  Product.fromJson(Map<String, dynamic> json) {
    try {
      count = 0;
      productID = json['productID'];
      productCode = json['productCode'];
      productName = json['productName'];
      currencyID = json['currencyID'];
      currencyCode = json['currencyCode'];
      taxCurrencyCode = json['taxCurrencyCode'];
      taxID = json['taxID'];
      productcategoryID = json['productcategoryID'];
      productType = json['productType'];
      mmbProductDescription = json['mmbProductDescription'];
      productDescription = json['productDescription'];
      productDescriptionText = json['productDescriptionText'];
      productDescriptionURL = json['productDescriptionURL'];
      productImageURL = json['productImageURL'];
      cityID = json['cityID'];
      cityCode = json['cityCode'];
      cityName = json['cityName'];
      arrivalCityCode = json['arrivalCityCode'];
      arrivalCityName = json['arrivalCityName'];
      via1 = json['via1'];
      operator = json['operator'];
      additionalInfo = json['additionalInfo'];
      unitOfMeasure = json['unitOfMeasure'];
      productImageLink = json['productImageLink'];
      applyToClasses = json['applyToClasses'];
      // ints
      maxQuantity = json['maxQuantity'];
      // doubles
      currencyRatetoNUC = json['currencyRatetoNUC'];
      productPriceCalc = json['productPriceCalc'];
      productPrice = json['productPrice'];
      taxAmountCalc = json['taxAmountCalc'];
      taxAmount = json['taxAmount'];
      // bools
      commandLinePrice = json['commandLinePrice'];
      requiresQuantity = json['requiresQuantity'];
      paxRelate = json['paxRelate'];
      segmentRelate = json['segmentRelate'];
      restrictPurchaseToAllPaxOrNone = json['restrictPurchaseToAllPaxOrNone'];
      autoSelect = json['autoSelect'];
      routeSpecificCombinable = json['routeSpecificCombinable'];
      displayOrder = json['displayOrder'];
      displayOnwebsite = json['displayOnwebsite'];
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
    return map;
  }
}
