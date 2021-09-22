import 'dart:convert';


class Products {
  List<Product> products;

  Products({this.products});

}

class Product {
String productCode;
String productName;
String productType;
double productPrice;

int count;

  Product({this.productCode, this.productName, this.productPrice, this.count = 0});


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

}

class GetProductsMsg {
  String BookingCityCurrencyCode;
  String ProductCategoryID;
  String ProductCategoryName;
  String ProductType;
  String Via1;
  String CityCode;
  String ArrivalCityCode;
  bool IncludeHotels;
  bool DisplayOnWebsiteOnly;

  GetProductsMsg(
      this.BookingCityCurrencyCode ,
      {    this.ArrivalCityCode = '',
    this.CityCode = '',
    this.DisplayOnWebsiteOnly = true,
    this.IncludeHotels = false,
    this.ProductCategoryID = '',
    this.ProductCategoryName = '',
    this.ProductType = '',
    this.Via1= '',
  });

  Map toJson() {
    Map map = new Map();
    map['BookingCityCurrencyCode'] = BookingCityCurrencyCode;
    map['ArrivalCityCode'] = ArrivalCityCode;
    map['CityCode'] = CityCode;
    map['DisplayOnWebsiteOnly'] = DisplayOnWebsiteOnly;
    map['IncludeHotels'] = IncludeHotels;
    map['ProductCategoryID'] = ProductCategoryID;
    map['ProductCategoryName'] = ProductCategoryName;
    map['ProductType'] = ProductType;
    map['Via1'] = Via1;
    return map;
  }
}
