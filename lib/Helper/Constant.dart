import 'package:eshop_multivendor/Model/Model.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Model/User.dart';

final String appName = 'Vizzve';

final String packageName = 'com.vizve.user';
final String androidLink = 'https://play.google.com/store/apps/details?id=';

final String iosPackage = 'com.vizve.user';
final String iosLink = 'your ios link here';
final String appStoreId = '123456789';

final String deepLinkUrlPrefix = 'https://eshopmultivendor.page.link';
final String deepLinkName = 'Vizzve';

final int timeOut = 50;
const int perPage = 10;

// final String baseUrl = 'https://alphawizztest.tk/Vizzv_food/app/v1/api/';
// final String baseUrl = 'https://alphawizztest.tk/Doorstep/app/v1/api/';

final String baseUrl = 'https://vizzvefoods.com/app/v1/api/';
final String imageUrl = 'https://vizzvefoods.com/';
final String jwtKey = "78084f1698c9fcff5a668b68dcd103db39be2605";
//cart
List<User> addressList = [];
//List<SectionModel> cartList = [];
List<Promo> promoList = [];
String unit ="";
double totalPrice = 0,
    oriPrice = 0,
    delCharge = 0,
    extraDelCharge = 0,
    extraDriverPercent = 0,
    taxPer = 0,
    packagingCharge = 0,
    finalDeliveryCharger = 0;
String?  newKms ;
int? selectedAddress = 0;
String? selAddress, payMethod = '', selTime, selDate, promocode;
bool? isTimeSlot,
    isPromoValid = false,
    isUseWallet = false,
    isPayLayShow = true;
int? selectedTime, selectedDate, selectedMethod;

double promoAmt = 0;
double remWalBal = 0, usedBal = 0;
bool isAvailable = true;
dynamic itemTotal;
double gstPrice = 0;
String? razorpayId,
    cashfreeId,
    cashfreeKey,
    paystackId,
    stripeId,
    stripeSecret,
    stripeMode = "test",
    stripeCurCode,
    stripePayId,
    paytmMerId,
    paytmMerKey;
bool payTesting = true;
//payment
List<Model> timeSlotList = [];
String? allowDay;
bool codAllowed = true;
String? bankName, bankNo, acName, acNo, exDetails;
