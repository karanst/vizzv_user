import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //  post api request without token
  static Future<http.Response> postAPI(
      {required String path, required Map<String, dynamic> parameters}) async {
    var url = Uri.parse(path);

    print("myperamitars ====== ");
    print(jsonEncode(parameters));
    final result = await http.post(url,
        headers: postHeaderWidoutToken(),
        encoding: Encoding.getByName("utf-8"),
        body: parameters);
    print('===========$url===============');
    print("statusCode => ${result.statusCode}");
    print("Body Data => ");
    print(jsonDecode(result.body));
    print('===========$url===============');
    return result;
  }

  //  post api request with json
  static Future<http.Response> postJsonAPI(
      {required String path, required Map<String, dynamic> parameters}) async {
    var url = Uri.parse(path);

    print("myperamitars ====== ");
    print(jsonEncode(parameters));
    final result = await http.post(url,
        headers: decodeHeaderWidoutToken(),
        // encoding: Encoding.getByName("utf-8"),
        body: jsonEncode(parameters));
    print('===========$url===============');
    print("statusCode => ${result.statusCode}");
    print("Body Data => ");
    print(jsonDecode(result.body));
    print('===========$url===============');
    return result;
  }

  //  get api request without token
  static Future<http.Response> getAPI({
    required String path,
  }) async {
    var url = Uri.parse(path);
    final result = await http.get(url, headers: postHeaderWidoutToken());
    print('===========$url===============');
    print("statusCode => ${result.statusCode}");
    print("Body Data => ${result.body}");
    print('===========$url===============');
    return result;
  }

  //  get api request without token
  static Future<http.Response> getDecodeAPI({
    required String path,
  }) async {
    var url = Uri.parse(path);
    final result = await http.get(url, headers: decodeHeaderWidoutToken());
    print('===========$url===============');
    print("statusCode => ${result.statusCode}");
    print("Body Data => ${result.body}");
    print('===========$url===============');
    return result;
  }

// Api Header
  static Map<String, String> postHeaderWidoutToken() => {
        "X-Requested-With": "XMLHttpRequest",
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      };
  // Api Header
  static Map<String, String> decodeHeaderWidoutToken() => {
        "Accept": "application/json",
        "Content-Type": "application/json",
      };
}
