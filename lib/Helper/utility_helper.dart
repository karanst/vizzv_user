import 'dart:math';

class UtilityHelper {
// calculate Distance
  static double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((double.parse(lat2.toString()) - double.parse(lat1.toString())) * p) /
            2 +
        c(double.parse(lat1.toString()) * p) *
            c(double.parse(lat2.toString()) * p) *
            (1 -
                c((double.parse(lon2.toString()) -
                        double.parse(lon1.toString())) *
                    p)) /
            2;
    return 12742 * asin(sqrt(a));
  }
}
