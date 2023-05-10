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

  callback();
}