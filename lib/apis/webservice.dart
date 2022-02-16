import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
const defaultHeader = {
  'Content-Type': 'application/x-www-form-urlencoded',
};
String MBWAYhost = 'https://mbway.ifthenpay.com';
String MBhost = 'https://ifthenpay.com/api';

class Resource<T> {
  final String url;
  final Map<String, String> headers;
  final body;
  T Function(Response response) parse;

  Resource(
      {required this.url, required this.parse, this.headers = defaultHeader, this.body});
}

class Webservice {
  // String proxy = 'https://thingproxy.freeboard.io/fetch/';
  String proxy = '';

  Future<T> get<T>(Resource<T> resource) async {
    Map<String, String> headers = {
      ...defaultHeader,
      ...resource.headers,
    };
    // print('skey ${this.skey}');
    // print('GET headers: ${headers}');
    String resourceUrl =
        "${MBWAYhost}${resource.url}";

    //client.connectionTimeout = const Duration(seconds: 10);
    final response = await http.get(
      Uri.parse(resourceUrl),
      headers: headers,
    );
    if (response.statusCode == 200) {
      // print('Response headers: ${response.headers}');
      return resource.parse(response);
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      throw Exception(error["message"]);
    }
  }

  Future<T> getDoor<T>(Resource<T> resource) async {
    Map<String, String> headers = {
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      "Accept-Encoding": "gzip, deflate",
      "Accept-Language": "en-US,en;q=0.9",
      "Authorization": 'Digest username"="admin", realm="Login to 75fb9cb5fa02c1363cb51defd537db68", nonce="1099556286", uri="/cgi-bin/accessControl.cgi?action=openDoor&channel=1&UserID=101&Type=Remote", response="10dd002676dc13d64a8cd3b6110ca331", opaque="4f135eda3ef76399c88388e7eafbaa479985a12a", qop=auth, nc=00000002, cnonce="a6615ed7d40dde05"',
      "Cache-Control": "max-age=0",
      "Connection": "keep-alive",
      "Cookie": "secure",
      "Host": "161.230.247.85:3333",
    "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
    };
    String resourceUrl =
        "${resource.url}";

    //client.connectionTimeout = const Duration(seconds: 10);
    final response = await http.get(
      Uri.parse(resourceUrl),
      headers: headers,
    );
    if (response == 'OK') {
      // print('Response headers: ${response.headers}');
      return resource.parse(response);
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      throw Exception(error["message"]);
    }
  }
  Future<T> post<T>(Resource<T> resource) async {
    Map<String, String> headers = {
      ...defaultHeader,
      ...resource.headers,
    };

    String resourceUrl =
        "${MBhost}${resource.url}";


    final response = await http.post(
      Uri.parse(resourceUrl),
      headers: headers,
      body: resource.body
    );


      return resource.parse(response);

  }

  // Future<T> post<T>(Resource<T> resource) async {
  //   if (globals.server == '' || globals.silo == '') {
  //     throw Exception('No server/silo set!');
  //   }
  //
  //   Map<String, String> skey =
  //       !loggedInUser.skey.isEmpty ? {'skey': loggedInUser.skey} : {};
  //
  //   Map<String, String> headers = {
  //     ...defaultHeader,
  //     ...resource.headers,
  //     ...skey
  //   };
  //
  //   print('POST headers: ${headers}');
  //   String resourceUrl =
  //       "$proxy${globals.server}${resource.url}"; //TODO REMOVE PROXY
  //   print(resourceUrl);
  //   if (resourceUrl.contains('login')) {
  //     resourceUrl += '&silo=${globals.silo}';
  //   }
  //   final response = await http.post(
  //     Uri.parse(resourceUrl),
  //     headers: headers,
  //     body: resource.body,
  //   );
  //
  //   if (response.statusCode == 200) {
  //     return resource.parse(response);
  //   } else {
  //     // TODO: response can be html not just json?
  //     Map<String, dynamic> error = jsonDecode(response.body);
  //     globals.requestToCopy = '${resource.headers}\n'
  //         '${resource.url}\n'
  //         'RESPONSE: ${response.statusCode} ';
  //     print(error['message']);
  //     throw Exception(error["message"]);
  //   }
  // }
  //
  // Future<T> put<T>(Resource<T> resource) async {
  //   if (globals.server == '' || globals.silo == '') {
  //     throw Exception('No server/silo set!');
  //   }
  //   Map<String, String> skey =
  //       !loggedInUser.skey.isEmpty ? {'skey': loggedInUser.skey} : {};
  //
  //   Map<String, String> headers = {
  //     ...defaultHeader,
  //     ...resource.headers,
  //     ...skey
  //   };
  //   print('PUT headers: ${headers}');
  //   String resourceUrl = "${globals.server}${resource.url}"; //TODO REMOVE PROXY
  //
  //   final response = await http.put(
  //     Uri.parse(resourceUrl),
  //     headers: headers,
  //     body: resource.body,
  //   );
  //
  //   if (response.statusCode == 200) {
  //     return resource.parse(response);
  //   } else {
  //     Map<String, dynamic> error = jsonDecode(response.body);
  //     globals.requestToCopy = '${resource.headers}\n'
  //         '${resource.url}\n'
  //         'RESPONSE: ${response.statusCode} ';
  //     throw Exception(error["message"]);
  //   }
  // }
  //
  // Future<T> delete<T>(Resource<T> resource) async {
  //   Map<String, String> skey =
  //       !loggedInUser.skey.isEmpty ? {'skey': loggedInUser.skey} : {};
  //   Map<String, String> headers = {
  //     // ...defaultHeader,
  //     ...resource.headers,
  //     ...skey
  //   };
  //   print('DELETE headers: ${headers}');
  //   String resourceUrl = "${globals.server}${resource.url}";
  //
  //   print('DELETE url: ${resourceUrl}');
  //
  //   final client = new http.Client();
  //   //client.connectionTimeout = const Duration(seconds: 10);
  //   final response = await http.delete(
  //     Uri.parse(resourceUrl),
  //     headers: headers,
  //   );
  //   if (response.statusCode == 200) {
  //     print('Response headers: ${response.headers}');
  //     return resource.parse(response);
  //   } else {
  //     Map<String, dynamic> error = jsonDecode(response.body);
  //     globals.requestToCopy = '${resource.headers}\n'
  //         '${resource.url}\n'
  //         'RESPONSE: ${response.statusCode} ';
  //     throw Exception(error["message"]);
  //   }
  // }
}
