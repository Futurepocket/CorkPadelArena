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
