

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