class Variants {
  Variants({
      this.id, 
      this.productId, 
      this.attributeValueIds, 
      this.attributeSet, 
      this.price, 
      this.specialPrice, 
      this.sku, 
      this.stock, 
      this.images, 
      this.availability, 
      this.status, 
      this.dateAdded, 
      this.variantIds, 
      this.attrName, 
      this.variantValues, 
      this.swatcheType, 
      this.swatcheValue, 
      this.imagesMd, 
      this.imagesSm, 
      this.cartCount,});

  Variants.fromJson(dynamic json) {
    id = json['id'];
    productId = json['product_id'];
    attributeValueIds = json['attribute_value_ids'];
    attributeSet = json['attribute_set'];
    price = json['price'];
    specialPrice = json['special_price'];
    sku = json['sku'];
    stock = json['stock'];
    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images!.add((v));
      });
    }
    availability = json['availability'];
    status = json['status'];
    dateAdded = json['date_added'];
    variantIds = json['variant_ids'];
    attrName = json['attr_name'];
    variantValues = json['variant_values'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];
    if (json['images_md'] != null) {
      imagesMd = [];
      json['images_md'].forEach((v) {
        imagesMd!.add((v));
      });
    }
    if (json['images_sm'] != null) {
      imagesSm = [];
      json['images_sm'].forEach((v) {
        imagesSm!.add((v));
      });
    }
    cartCount = json['cart_count'];
  }
  String? id;
  String? productId;
  String? attributeValueIds;
  String? attributeSet;
  String? price;
  String? specialPrice;
  String? sku;
  String? stock;
  List<dynamic>? images;
  String? availability;
  String? status;
  String? dateAdded;
  String? variantIds;
  String? attrName;
  String? variantValues;
  String? swatcheType;
  String? swatcheValue;
  List<dynamic>? imagesMd;
  List<dynamic>? imagesSm;
  String? cartCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['product_id'] = productId;
    map['attribute_value_ids'] = attributeValueIds;
    map['attribute_set'] = attributeSet;
    map['price'] = price;
    map['special_price'] = specialPrice;
    map['sku'] = sku;
    map['stock'] = stock;
    if (images != null) {
      map['images'] = images!.map((v) => v.toJson()).toList();
    }
    map['availability'] = availability;
    map['status'] = status;
    map['date_added'] = dateAdded;
    map['variant_ids'] = variantIds;
    map['attr_name'] = attrName;
    map['variant_values'] = variantValues;
    map['swatche_type'] = swatcheType;
    map['swatche_value'] = swatcheValue;
    if (imagesMd != null) {
      map['images_md'] = imagesMd!.map((v) => v.toJson()).toList();
    }
    if (imagesSm != null) {
      map['images_sm'] = imagesSm!.map((v) => v.toJson()).toList();
    }
    map['cart_count'] = cartCount;
    return map;
  }

}