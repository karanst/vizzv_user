import 'Variants.dart';
import 'MinMaxPrice.dart';

class Data {
  Data({
      this.total, 
      this.sales, 
      this.stockType, 
      this.isPricesInclusiveTax, 
      this.type, 
      this.packingCharge, 
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
      this.openCloseStatus, 
      this.breakfastStartProductTime, 
      this.breakfastEndProductTime, 
      this.lunchStartProductTime, 
      this.lunchEndProductTime, 
      this.dinnerStartProductTime, 
      this.dinnerEndProductTime, 
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
      this.variantAttributes,});

  Data.fromJson(dynamic json) {
    total = json['total'];
    sales = json['sales'];
    stockType = json['stock_type'];
    isPricesInclusiveTax = json['is_prices_inclusive_tax'];
    type = json['type'];
    packingCharge = json['packing_charge'];
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
      otherImages = [];
      json['other_images'].forEach((v) {
        otherImages!.add((v));
      });
    }
    videoType = json['video_type'];
    video = json['video'];
    if (json['tags'] != null) {
      tags = [];
      json['tags'].forEach((v) {
        tags!.add((v));
      });
    }
    warrantyPeriod = json['warranty_period'];
    openCloseStatus = json['open_close_status'];
    breakfastStartProductTime = json['breakfast_start_product_time'];
    breakfastEndProductTime = json['breakfast_end_product_time'];
    lunchStartProductTime = json['lunch_start_product_time'];
    lunchEndProductTime = json['lunch_end_product_time'];
    dinnerStartProductTime = json['dinner_start_product_time'];
    dinnerEndProductTime = json['dinner_end_product_time'];
    guaranteePeriod = json['guarantee_period'];
    madeIn = json['made_in'];
    availability = json['availability'];
    categoryName = json['category_name'];
    taxPercentage = json['tax_percentage'];
    if (json['review_images'] != null) {
      reviewImages = [];
      json['review_images'].forEach((v) {
        reviewImages!.add((v));
      });
    }
    if (json['attributes'] != null) {
      attributes = [];
      json['attributes'].forEach((v) {
        attributes!.add((v));
      });
    }
    if (json['variants'] != null) {
      variants = [];
      json['variants'].forEach((v) {
        variants!.add(Variants.fromJson(v));
      });
    }
    minMaxPrice = (json['min_max_price'] != null ? MinMaxPrice.fromJson(json['min_max_price']) : null)!;
    deliverableZipcodesIds = json['deliverable_zipcodes_ids'];
    isDeliverable = json['is_deliverable'];
    isPurchased = json['is_purchased'];
    isFavorite = json['is_favorite'];
    imageMd = json['image_md'];
    imageSm = json['image_sm'];
    if (json['other_images_sm'] != null) {
      otherImagesSm = [];
      json['other_images_sm'].forEach((v) {
        otherImagesSm!.add((v));
      });
    }
    if (json['other_images_md'] != null) {
      otherImagesMd = [];
      json['other_images_md'].forEach((v) {
        otherImagesMd!.add((v));
      });
    }
    if (json['variant_attributes'] != null) {
      variantAttributes = [];
      json['variant_attributes'].forEach((v) {
        variantAttributes!.add((v));
      });
    }
  }
  String? total;
  String? sales;
  String? stockType;
  String? isPricesInclusiveTax;
  String? type;
  String? packingCharge;
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
  String? stock;
  String? name;
  String? categoryId;
  String? shortDescription;
  String? slug;
  String? description;
  String? totalAllowedQuantity;
  String? deliverableType;
  dynamic deliverableZipcodes;
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
  String? indicator;
  List<dynamic>? otherImages;
  String? videoType;
  String? video;
  List<dynamic>? tags;
  String? warrantyPeriod;
  String? openCloseStatus;
  dynamic breakfastStartProductTime;
  dynamic breakfastEndProductTime;
  dynamic lunchStartProductTime;
  dynamic lunchEndProductTime;
  dynamic dinnerStartProductTime;
  dynamic dinnerEndProductTime;
  String? guaranteePeriod;
  String? madeIn;
  String? availability;
  String? categoryName;
  String? taxPercentage;
  List<dynamic>? reviewImages;
  List<dynamic>? attributes;
  List<Variants>? variants;
  MinMaxPrice? minMaxPrice;
  dynamic deliverableZipcodesIds;
  bool? isDeliverable;
  bool? isPurchased;
  String? isFavorite;
  String? imageMd;
  String? imageSm;
  List<dynamic>? otherImagesSm;
  List<dynamic>? otherImagesMd;
  List<dynamic>? variantAttributes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total'] = total;
    map['sales'] = sales;
    map['stock_type'] = stockType;
    map['is_prices_inclusive_tax'] = isPricesInclusiveTax;
    map['type'] = type;
    map['packing_charge'] = packingCharge;
    map['attr_value_ids'] = attrValueIds;
    map['seller_rating'] = sellerRating;
    map['seller_slug'] = sellerSlug;
    map['seller_no_of_ratings'] = sellerNoOfRatings;
    map['seller_profile'] = sellerProfile;
    map['store_name'] = storeName;
    map['store_description'] = storeDescription;
    map['seller_id'] = sellerId;
    map['seller_name'] = sellerName;
    map['id'] = id;
    map['stock'] = stock;
    map['name'] = name;
    map['category_id'] = categoryId;
    map['short_description'] = shortDescription;
    map['slug'] = slug;
    map['description'] = description;
    map['total_allowed_quantity'] = totalAllowedQuantity;
    map['deliverable_type'] = deliverableType;
    map['deliverable_zipcodes'] = deliverableZipcodes;
    map['minimum_order_quantity'] = minimumOrderQuantity;
    map['quantity_step_size'] = quantityStepSize;
    map['cod_allowed'] = codAllowed;
    map['row_order'] = rowOrder;
    map['rating'] = rating;
    map['no_of_ratings'] = noOfRatings;
    map['image'] = image;
    map['is_returnable'] = isReturnable;
    map['is_cancelable'] = isCancelable;
    map['cancelable_till'] = cancelableTill;
    map['indicator'] = indicator;
    if (otherImages != null) {
      map['other_images'] = otherImages!.map((v) => v.toJson()).toList();
    }
    map['video_type'] = videoType;
    map['video'] = video;
    if (tags != null) {
      map['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    map['warranty_period'] = warrantyPeriod;
    map['open_close_status'] = openCloseStatus;
    map['breakfast_start_product_time'] = breakfastStartProductTime;
    map['breakfast_end_product_time'] = breakfastEndProductTime;
    map['lunch_start_product_time'] = lunchStartProductTime;
    map['lunch_end_product_time'] = lunchEndProductTime;
    map['dinner_start_product_time'] = dinnerStartProductTime;
    map['dinner_end_product_time'] = dinnerEndProductTime;
    map['guarantee_period'] = guaranteePeriod;
    map['made_in'] = madeIn;
    map['availability'] = availability;
    map['category_name'] = categoryName;
    map['tax_percentage'] = taxPercentage;
    if (reviewImages != null) {
      map['review_images'] = reviewImages!.map((v) => v.toJson()).toList();
    }
    if (attributes != null) {
      map['attributes'] = attributes!.map((v) => v.toJson()).toList();
    }
    if (variants != null) {
      map['variants'] = variants!.map((v) => v.toJson()).toList();
    }
    if (minMaxPrice != null) {
      map['min_max_price'] = minMaxPrice!.toJson();
    }
    map['deliverable_zipcodes_ids'] = deliverableZipcodesIds;
    map['is_deliverable'] = isDeliverable;
    map['is_purchased'] = isPurchased;
    map['is_favorite'] = isFavorite;
    map['image_md'] = imageMd;
    map['image_sm'] = imageSm;
    if (otherImagesSm != null) {
      map['other_images_sm'] = otherImagesSm!.map((v) => v.toJson()).toList();
    }
    if (otherImagesMd != null) {
      map['other_images_md'] = otherImagesMd!.map((v) => v.toJson()).toList();
    }
    if (variantAttributes != null) {
      map['variant_attributes'] = variantAttributes!.map((v) => v.toJson()).toList();
    }
    return map;
  }

}