import 'dart:convert';

import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/api/api_services.dart';
import 'package:eshop_multivendor/api/reorder_response.dart';
import 'package:http/http.dart' as http;

class ChangesApi {
  // changes API Helper
  static Future reOrder(oderid) async {
    var headers = {'Cookie': 'ci_session=t6cs0uh435frm8fuocgf50h92tmojbhi'};
    var request = http.MultipartRequest('POST', reOrderApi);
    request.fields.addAll({'id': oderid});

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var data;
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      var str = await response.stream.bytesToString();
      data = json.decode(str);
      // ReorderResponse
    } else {
      print(response.reasonPhrase);
    }
    return data;
    // var responsData = await ApiService.postJsonAPI(
    //     path: reOrderApi, parameters: request.tojson());
    // var data = jsonDecode(responsData.body);
    // return ReorderResponse.fromJson(data);
  }
}
