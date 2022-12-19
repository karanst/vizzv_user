import 'package:eshop_multivendor/Model/Section_Model.dart';

class SubCatModel{
  String id,name,total,image;
  double offset;
  List<Product> productList;
  bool show;
  SubCatModel(this.id, this.name, this.total, this.image, this.productList,this.offset,this.show);
}