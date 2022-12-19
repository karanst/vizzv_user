class ResponseRecomndetProducts {
  bool? error;
  String? message;
  List<Data>? data;

  ResponseRecomndetProducts({this.error, this.message, this.data});

  ResponseRecomndetProducts.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? total;
  String? sales;
  Null? stockType;
  String? isPricesInclusiveTax;
  String? type;
  String? attrValueIds;
  String? sellerRating;
  String? sellerSlug;
  String? sellerNoOfRatings;
  String? sellerProfile;
  String? storeName;
  String? storeDescription;
  String? sellerId;
  String? sellerName;
  String? id;
  Null? stock;
  String? name;
  String? categoryId;
  String? shortDescription;
  String? slug;
  String? description;
  String? totalAllowedQuantity;
  String? deliverableType;
  Null? deliverableZipcodes;
  String? minimumOrderQuantity;
  String? quantityStepSize;
  String? codAllowed;
  String? rowOrder;
  String? rating;
  String? noOfRatings;
  String? image;
  String? isReturnable;
  String? isCancelable;
  String? cancelableTill;
  Null? indicator;
  List<Null>? otherImages;
  String? videoType;
  String? video;
  List<Null>? tags;
  String? warrantyPeriod;
  String? guaranteePeriod;
  String? madeIn;
  Null? availability;
  String? categoryName;
  String? taxPercentage;
  List<Null>? reviewImages;
  List<Attributes>? attributes;
  List<Variants>? variants;
  MinMaxPrice? minMaxPrice;
  Null? deliverableZipcodesIds;
  bool? isDeliverable;
  bool? isPurchased;
  String? isFavorite;
  String? imageMd;
  String? imageSm;
  List<Null>? otherImagesSm;
  List<Null>? otherImagesMd;
  List<VariantAttributes>? variantAttributes;

  Data(
      {this.total,
      this.sales,
      this.stockType,
      this.isPricesInclusiveTax,
      this.type,
      this.attrValueIds,
      this.sellerRating,
      this.sellerSlug,
      this.sellerNoOfRatings,
      this.sellerProfile,
      this.storeName,
      this.storeDescription,
      this.sellerId,
      this.sellerName,
      this.id,
      this.stock,
      this.name,
      this.categoryId,
      this.shortDescription,
      this.slug,
      this.description,
      this.totalAllowedQuantity,
      this.deliverableType,
      this.deliverableZipcodes,
      this.minimumOrderQuantity,
      this.quantityStepSize,
      this.codAllowed,
      this.rowOrder,
      this.rating,
      this.noOfRatings,
      this.image,
      this.isReturnable,
      this.isCancelable,
      this.cancelableTill,
      this.indicator,
      this.otherImages,
      this.videoType,
      this.video,
      this.tags,
      this.warrantyPeriod,
      this.guaranteePeriod,
      this.madeIn,
      this.availability,
      this.categoryName,
      this.taxPercentage,
      this.reviewImages,
      this.attributes,
      this.variants,
      this.minMaxPrice,
      this.deliverableZipcodesIds,
      this.isDeliverable,
      this.isPurchased,
      this.isFavorite,
      this.imageMd,
      this.imageSm,
      this.otherImagesSm,
      this.otherImagesMd,
      this.variantAttributes});

  Data.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    sales = json['sales'];
    stockType = json['stock_type'];
    isPricesInclusiveTax = json['is_prices_inclusive_tax'];
    type = json['type'];
    attrValueIds = json['attr_value_ids'];
    sellerRating = json['seller_rating'];
    sellerSlug = json['seller_slug'];
    sellerNoOfRatings = json['seller_no_of_ratings'];
    sellerProfile = json['seller_profile'];
    storeName = json['store_name'];
    storeDescription = json['store_description'];
    sellerId = json['seller_id'];
    sellerName = json['seller_name'];
    id = json['id'];
    stock = json['stock'];
    name = json['name'];
    categoryId = json['category_id'];
    shortDescription = json['short_description'];
    slug = json['slug'];
    description = json['description'];
    totalAllowedQuantity = json['total_allowed_quantity'];
    deliverableType = json['deliverable_type'];
    deliverableZipcodes = json['deliverable_zipcodes'];
    minimumOrderQuantity = json['minimum_order_quantity'];
    quantityStepSize = json['quantity_step_size'];
    codAllowed = json['cod_allowed'];
    rowOrder = json['row_order'];
    rating = json['rating'];
    noOfRatings = json['no_of_ratings'];
    image = json['image'];
    isReturnable = json['is_returnable'];
    isCancelable = json['is_cancelable'];
    cancelableTill = json['cancelable_till'];
    indicator = json['indicator'];
    if (json['other_images'] != null) {
      otherImages = <Null>[];
    }
    videoType = json['video_type'];
    video = json['video'];
    if (json['tags'] != null) {}
    warrantyPeriod = json['warranty_period'];
    guaranteePeriod = json['guarantee_period'];
    madeIn = json['made_in'];
    availability = json['availability'];
    categoryName = json['category_name'];
    taxPercentage = json['tax_percentage'];
    if (json['review_images'] != null) {}
    if (json['attributes'] != null) {
      attributes = <Attributes>[];
      json['attributes'].forEach((v) {
        attributes!.add(new Attributes.fromJson(v));
      });
    }
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants!.add(new Variants.fromJson(v));
      });
    }
    minMaxPrice = json['min_max_price'];
    deliverableZipcodesIds = json['deliverable_zipcodes_ids'];
    isDeliverable = json['is_deliverable'];
    isPurchased = json['is_purchased'];
    isFavorite = json['is_favorite'];
    imageMd = json['image_md'];
    imageSm = json['image_sm'];
    if (json['other_images_sm'] != null) {
      otherImagesSm = <Null>[];
    }
    if (json['other_images_md'] != null) {
      otherImagesMd = <Null>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['sales'] = this.sales;
    data['stock_type'] = this.stockType;
    data['is_prices_inclusive_tax'] = this.isPricesInclusiveTax;
    data['type'] = this.type;
    data['attr_value_ids'] = this.attrValueIds;
    data['seller_rating'] = this.sellerRating;
    data['seller_slug'] = this.sellerSlug;
    data['seller_no_of_ratings'] = this.sellerNoOfRatings;
    data['seller_profile'] = this.sellerProfile;
    data['store_name'] = this.storeName;
    data['store_description'] = this.storeDescription;
    data['seller_id'] = this.sellerId;
    data['seller_name'] = this.sellerName;
    data['id'] = this.id;
    data['stock'] = this.stock;
    data['name'] = this.name;
    data['category_id'] = this.categoryId;
    data['short_description'] = this.shortDescription;
    data['slug'] = this.slug;
    data['description'] = this.description;
    data['total_allowed_quantity'] = this.totalAllowedQuantity;
    data['deliverable_type'] = this.deliverableType;
    data['deliverable_zipcodes'] = this.deliverableZipcodes;
    data['minimum_order_quantity'] = this.minimumOrderQuantity;
    data['quantity_step_size'] = this.quantityStepSize;
    data['cod_allowed'] = this.codAllowed;
    data['row_order'] = this.rowOrder;
    data['rating'] = this.rating;
    data['no_of_ratings'] = this.noOfRatings;
    data['image'] = this.image;
    data['is_returnable'] = this.isReturnable;
    data['is_cancelable'] = this.isCancelable;
    data['cancelable_till'] = this.cancelableTill;
    data['indicator'] = this.indicator;

    data['video_type'] = this.videoType;
    data['video'] = this.video;

    data['warranty_period'] = this.warrantyPeriod;
    data['guarantee_period'] = this.guaranteePeriod;
    data['made_in'] = this.madeIn;
    data['availability'] = this.availability;
    data['category_name'] = this.categoryName;
    data['tax_percentage'] = this.taxPercentage;

    if (this.attributes != null) {
      data['attributes'] = this.attributes!.map((v) => v.toJson()).toList();
    }

    if (this.minMaxPrice != null) {
      data['min_max_price'] = this.minMaxPrice!.toJson();
    }
    data['deliverable_zipcodes_ids'] = this.deliverableZipcodesIds;
    data['is_deliverable'] = this.isDeliverable;
    data['is_purchased'] = this.isPurchased;
    data['is_favorite'] = this.isFavorite;
    data['image_md'] = this.imageMd;
    data['image_sm'] = this.imageSm;

    if (this.variantAttributes != null) {
      data['variant_attributes'] =
          this.variantAttributes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attributes {
  String? ids;
  String? value;
  String? attrName;
  String? name;
  String? swatcheType;
  String? swatcheValue;

  Attributes(
      {this.ids,
      this.value,
      this.attrName,
      this.name,
      this.swatcheType,
      this.swatcheValue});

  Attributes.fromJson(Map<String, dynamic> json) {
    ids = json['ids'];
    value = json['value'];
    attrName = json['attr_name'];
    name = json['name'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ids'] = this.ids;
    data['value'] = this.value;
    data['attr_name'] = this.attrName;
    data['name'] = this.name;
    data['swatche_type'] = this.swatcheType;
    data['swatche_value'] = this.swatcheValue;
    return data;
  }
}

class Variants {
  String? id;
  String? productId;
  String? attributeValueIds;
  String? attributeSet;
  String? price;
  String? specialPrice;
  String? sku;
  Null? stock;
  List<Null>? images;
  String? availability;
  String? status;
  String? dateAdded;
  String? variantIds;
  String? attrName;
  String? variantValues;
  String? swatcheType;
  String? swatcheValue;
  List<Null>? imagesMd;
  List<Null>? imagesSm;
  String? cartCount;

  Variants(
      {this.id,
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
      this.cartCount});

  Variants.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    attributeValueIds = json['attribute_value_ids'];
    attributeSet = json['attribute_set'];
    price = json['price'];
    specialPrice = json['special_price'];
    sku = json['sku'];
    stock = json['stock'];

    availability = json['availability'];
    status = json['status'];
    dateAdded = json['date_added'];
    variantIds = json['variant_ids'];
    attrName = json['attr_name'];
    variantValues = json['variant_values'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];

    if (json['images_sm'] != null) {
      cartCount = json['cart_count'];
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['id'] = this.id;
      data['product_id'] = this.productId;
      data['attribute_value_ids'] = this.attributeValueIds;
      data['attribute_set'] = this.attributeSet;
      data['price'] = this.price;
      data['special_price'] = this.specialPrice;
      data['sku'] = this.sku;
      data['stock'] = this.stock;

      data['availability'] = this.availability;
      data['status'] = this.status;
      data['date_added'] = this.dateAdded;
      data['variant_ids'] = this.variantIds;
      data['attr_name'] = this.attrName;
      data['variant_values'] = this.variantValues;
      data['swatche_type'] = this.swatcheType;
      data['swatche_value'] = this.swatcheValue;

      data['cart_count'] = this.cartCount;
      return data;
    }
  }
}

class MinMaxPrice {
  int? minPrice;
  int? maxPrice;
  int? specialPrice;
  int? maxSpecialPrice;
  int? discountInPercentage;

  MinMaxPrice(
      {this.minPrice,
      this.maxPrice,
      this.specialPrice,
      this.maxSpecialPrice,
      this.discountInPercentage});

  MinMaxPrice.fromJson(Map<String, dynamic> json) {
    minPrice = json['min_price'];
    maxPrice = json['max_price'];
    specialPrice = json['special_price'];
    maxSpecialPrice = json['max_special_price'];
    discountInPercentage = json['discount_in_percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['min_price'] = this.minPrice;
    data['max_price'] = this.maxPrice;
    data['special_price'] = this.specialPrice;
    data['max_special_price'] = this.maxSpecialPrice;
    data['discount_in_percentage'] = this.discountInPercentage;
    return data;
  }
}

class VariantAttributes {
  String? ids;
  String? values;
  String? swatcheType;
  String? swatcheValue;
  String? attrName;

  VariantAttributes(
      {this.ids,
      this.values,
      this.swatcheType,
      this.swatcheValue,
      this.attrName});

  VariantAttributes.fromJson(Map<String, dynamic> json) {
    ids = json['ids'];
    values = json['values'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];
    attrName = json['attr_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ids'] = this.ids;
    data['values'] = this.values;
    data['swatche_type'] = this.swatcheType;
    data['swatche_value'] = this.swatcheValue;
    data['attr_name'] = this.attrName;
    return data;
  }
}
