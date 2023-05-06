import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> fetchDataFromApi(String url,
    {Map<String, String>? headers, String httpMethod = 'GET', Map<String, dynamic>? body}) async {
  http.Response response;

  if (httpMethod == 'GET') {
    response = await http.get(Uri.parse(url), headers: headers);
  } else if (httpMethod == 'POST') {
    response = await http.post(Uri.parse(url), headers: headers, body: json.encode(body));
  } else {
    throw ArgumentError('Invalid httpMethod: $httpMethod');
  }

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['data'];
  } else {
    print('Error: ${response.statusCode}');
    return null;
  }
}