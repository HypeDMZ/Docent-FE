import 'package:shared_preferences/shared_preferences.dart';

Future<String?> fetchAccessToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('access_token');
  return accessToken;
}