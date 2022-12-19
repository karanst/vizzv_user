class MinMaxPrice {
  MinMaxPrice({
      this.minPrice, 
      this.maxPrice, 
      this.specialPrice, 
      this.maxSpecialPrice, 
      this.discountInPercentage,});

  MinMaxPrice.fromJson(dynamic json) {
    minPrice = json['min_price'];
    maxPrice = json['max_price'];
    specialPrice = json['special_price'];
    maxSpecialPrice = json['max_special_price'];
    discountInPercentage = json['discount_in_percentage'];
  }
  int? minPrice;
  int? maxPrice;
  int? specialPrice;
  int? maxSpecialPrice;
  int? discountInPercentage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['min_price'] = minPrice;
    map['max_price'] = maxPrice;
    map['special_price'] = specialPrice;
    map['max_special_price'] = maxSpecialPrice;
    map['discount_in_percentage'] = discountInPercentage;
    return map;
  }

}