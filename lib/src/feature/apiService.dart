import 'dart:convert';
import '../dto/createRequest.dart';
import 'common.dart';

const baseUrl = 'https://bmongsmong.com/api';

Future<void> toggleLike(String? accessToken, int postId, bool isLiked, Function callback) async {
  String endpoint;
  String httpMethod;

  if (isLiked) {
    endpoint = '/diary/unlike?diary_id=$postId';
    httpMethod = 'DELETE';
  } else {
    endpoint = '/diary/like?diary_id=$postId';
    httpMethod = 'POST';
  }

  final headers = {'Authorization': 'Bearer $accessToken'};
  final url = '$baseUrl$endpoint';
  await fetchDataFromApi(url, headers: headers, httpMethod: httpMethod);

  if (callback != null) {
    callback();
  }
}

Future<void> modifyDiary(String? accessToken, int diaryId, String dreamName, String dream, Function callback) async {
  final endpoint = '/diary/update?diary_id=$diaryId';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
  final body = {
    "dream_name": dreamName,
    "dream": dream,
  };
  final url = '$baseUrl$endpoint';
  await fetchDataFromApi(url, headers: headers, httpMethod: 'POST', body: body);
  callback();
}

Future<void> toggleDiaryVisibility(String? accessToken, int diaryId, bool isPublic, Function callback) async {
  String endpoint = '/diary/update/ispublic?diary_id=$diaryId&is_public=${isPublic ? 'true' : 'false'}';
  final headers = {'Authorization': 'Bearer $accessToken'};
  final url = '$baseUrl$endpoint';
  await fetchDataFromApi(url, headers: headers, httpMethod: 'POST');
  callback();
}

Future<void> deleteDiary(String? accessToken, int diaryId, Function callback) async {
  final endpoint = '/diary/delete?diary_id=$diaryId';
  final headers = {'Authorization': 'Bearer $accessToken'};

  final url = '$baseUrl$endpoint';
  await fetchDataFromApi(url, headers: headers, httpMethod: 'DELETE');

  callback();
}

Future<void> fetchDiaryData(String? accessToken, int diaryId, Function callback) async {
  final endpoint = '/diary/read?diary_id=${diaryId}';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken'
  };
  final url = '$baseUrl$endpoint';
  dynamic response = await fetchDataFromApi(url, headers: headers);
  callback(response);
}

Future<void> createComment(String? accessToken, int diaryId, String comment, Function(dynamic) callback) async {
  final endpoint = '/diary/comment?diary_id=$diaryId';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
  final body = {
    "comment": comment,
  };
  final url = '$baseUrl$endpoint';
  var response = await fetchDataFromApi(url, headers: headers, httpMethod: 'POST', body: body);

  if (callback != null) {
    callback(response);
  }
}

Future<List<dynamic>> fetchCommentList(String? accessToken, int diaryId, int pageNumber) async {
  final endpoint = '/diary/list/comment/$diaryId/$pageNumber';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };
  final url = '$baseUrl$endpoint';
  List<dynamic> response = await fetchDataFromApi(url, headers: headers);
  return response ?? [];
}

Future<void> deleteComment(String? accessToken, int diaryId, int commentId, Function callback) async {
  final endpoint = '/diary/uncomment?diary_id=$diaryId&comment_id=$commentId';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };
  final url = '$baseUrl$endpoint';
  await fetchDataFromApi(url, headers: headers, httpMethod: 'DELETE');

  if (callback != null) {
    callback();
  }
}

Future<List<dynamic>> getHotPosts(String? accessToken, int page) async {
  final endpoint = '/search/hot?page=$page';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };
  final url = '$baseUrl$endpoint';
  List<dynamic> response = await fetchDataFromApi(url, headers: headers);
  return response ?? [];
}

Future<Map<String, dynamic>> generateDream(String? accessToken, String text) async {
  final endpoint = '/generate/dream';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
  final body = jsonEncode({'text': text});
  final url = '$baseUrl$endpoint';
  Map<String, dynamic> response = await fetchDataFromApi(url, headers: headers, body: body, httpMethod: 'POST');
  return response ?? {};
}

Future<Map<String, dynamic>> generateAdditionalImage(String? accessToken, int textId) async {
  final endpoint = '/generate/image';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
  final body = jsonEncode({'textId': textId});
  final url = '$baseUrl$endpoint';
  Map<String, dynamic> response = await fetchDataFromApi(url, headers: headers, body: body, httpMethod: 'POST');
  return response ?? {};
}

Future<Map<String, dynamic>> generateResolution(String? accessToken, String text) async {
  final endpoint = '/generate/resolution';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
  final body = jsonEncode({'text': text});
  final url = '$baseUrl$endpoint';
  Map<String, dynamic> response = await fetchDataFromApi(url, headers: headers, body: body, httpMethod: 'POST');
  return response ?? {};
}

Future<Map<String, dynamic>> createDiary(String? accessToken, Create create) async {
  final endpoint = '/diary/create';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
  final body = jsonEncode(create.toJson());  // Assuming Create class has a toJson method for serialization.
  final url = '$baseUrl$endpoint';
  Map<String, dynamic> response = await fetchDataFromApi(url, headers: headers, body: body, httpMethod: 'POST');
  return response ?? {};
}

Future<List<dynamic>> fetchDiaries(String? accessToken, int page) async {
  final endpoint = '/diary/list/mydiary/$page';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };
  final url = '$baseUrl$endpoint';
  var response = await fetchDataFromApi(url, headers: headers, httpMethod: 'GET');
  return response ?? [];
}

Future<List<dynamic>> fetchSearchResults(String? accessToken, String searchText, int page) async {
  final url = Uri.https('bmongsmong.com', '/api/search/text', {'text': searchText, 'page': '$page'});
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  var response = await fetchDataFromApi(url.toString(), headers: headers, httpMethod: 'GET');
  return response ?? [];
}
