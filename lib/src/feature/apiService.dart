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
