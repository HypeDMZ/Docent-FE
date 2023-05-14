import 'common.dart';

Future<void> toggleLike(String? accessToken, int postId, bool isLiked, Function callback) async {
  String url;
  String httpMethod;

  if (isLiked) {
    url = 'https://bmongsmong.com/api/diary/unlike?diary_id=$postId';
    httpMethod = 'DELETE';
  } else {
    url = 'https://bmongsmong.com/api/diary/like?diary_id=$postId';
    httpMethod = 'POST';
  }

  final headers = {'Authorization': 'Bearer $accessToken'};

  await fetchDataFromApi(url, headers: headers, httpMethod: httpMethod);

  if (callback != null) {
    callback();
  }
}

Future<void> modifyDiary(String? accessToken, int diaryId, String dreamName, String dream, Function callback) async {
  final url = 'https://bmongsmong.com/api/diary/update?diary_id=$diaryId';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
  final body = {
    "dream_name": dreamName,
    "dream": dream,
  };

  await fetchDataFromApi(url, headers: headers, httpMethod: 'POST', body: body);

  callback();
}

Future<void> toggleDiaryVisibility(String? accessToken, int diaryId, bool isPublic, Function callback) async {
  String url = 'https://bmongsmong.com/api/diary/update/ispublic?diary_id=$diaryId&is_public=${isPublic ? 'true' : 'false'}';
  final headers = {'Authorization': 'Bearer $accessToken'};

  await fetchDataFromApi(url, headers: headers, httpMethod: 'POST');

  callback();
}

Future<void> deleteDiary(String? accessToken, int diaryId, Function callback) async {
  final url = 'https://bmongsmong.com/api/diary/delete?diary_id=$diaryId';
  final headers = {'Authorization': 'Bearer $accessToken'};

  await fetchDataFromApi(url, headers: headers, httpMethod: 'DELETE');

  callback();
}

Future<void> fetchDiaryData(String? accessToken, int diaryId, Function callback) async {
  final url = 'https://bmongsmong.com/api/diary/read?diary_id=${diaryId}';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken'
  };

  dynamic response = await fetchDataFromApi(url, headers: headers);
  callback(response);
}

Future<void> createComment(String? accessToken, int diaryId, String comment, Function(dynamic) callback) async {
  final url = 'https://bmongsmong.com/api/diary/comment?diary_id=$diaryId';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
  final body = {
    "comment": comment,
  };

  var response = await fetchDataFromApi(url, headers: headers, httpMethod: 'POST', body: body);

  if (callback != null) {
    callback(response);
  }
}

Future<List<dynamic>> fetchCommentList(String? accessToken, int diaryId, int pageNumber) async {
  final url = 'https://bmongsmong.com/api/diary/list/comment/$diaryId/$pageNumber';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  List<dynamic> response = await fetchDataFromApi(url, headers: headers);
  return response ?? [];
}

Future<void> deleteComment(String? accessToken, int diaryId, int commentId, Function callback) async {
  final url = 'https://bmongsmong.com/api/diary/uncomment?diary_id=$diaryId&comment_id=$commentId';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  await fetchDataFromApi(url, headers: headers, httpMethod: 'DELETE');

  if (callback != null) {
    callback();
  }
}

Future<List<dynamic>> getHotPosts(String? accessToken, int page) async {
  final url = 'https://bmongsmong.com/api/search/hot?page=$page';
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  print(accessToken);
  List<dynamic> response = await fetchDataFromApi(url, headers: headers);
  return response ?? [];
}