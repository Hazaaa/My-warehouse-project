class Product {

  final String id;
  final String name;
  final String description;
  final int quantity;
  String measurementUnit;
  String whereIsStored;
  String imageUrl;
  String barcode;

  Product({this.id, this.name, this.description, this.quantity, this.whereIsStored, this.barcode, this.imageUrl, this.measurementUnit});

}