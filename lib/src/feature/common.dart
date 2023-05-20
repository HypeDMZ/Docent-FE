import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> fetchDataFromApi(String url,
    {Map<String, String>? headers, String httpMethod = 'GET', dynamic body}) async {
  http.Response response;

  if (httpMethod == 'GET') {
    response = await http.get(Uri.parse(url), headers: headers);
  } else if (httpMethod == 'POST') {
    response = await http.post(Uri.parse(url), headers: headers, body: body);
  } else if (httpMethod == 'DELETE') {
    response = await http.delete(Uri.parse(url), headers: headers);
  } else {
    throw ArgumentError('Invalid httpMethod: $httpMethod');
  }

  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    final jsonResponse = json.decode(responseBody);
    return jsonResponse['data'];
  } else {
    print('Error: ${response.statusCode}, ${response.reasonPhrase}');
    return null;
  }
}