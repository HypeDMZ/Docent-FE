import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  List<dynamic> _posts = [];
  int _page = 1;
  bool _hasMore = true;
  String? _accessToken;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _fetchAccessToken();
    _fetchPosts();
  }

  Future<void> _fetchAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken != null) {
      setState(() {
        _accessToken = accessToken;
      });
    }
  }

  bool _isLoading = false;

  Future<void> _fetchPosts() async {
    if (!_hasMore || _isLoading) return;
    if (_accessToken == null) return;
    _isLoading = true;

    final url = 'https://bmongsmong.com/api/diary/list?page=$_page';
    final headers = {'Authorization': 'Bearer $_accessToken'};

    dynamic data = await fetchDataFromApi(url, headers: headers);

    if (data != null) {
      setState(() {
        _posts.addAll(data);
        if (data.length < 5) {
          _hasMore = false;
        } else {
          _page++;
        }
      });
    }
    _isLoading = false;
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent ||
        _scrollController.position.maxScrollExtent - _scrollController.position.pixels <=
            2 * MediaQuery.of(context).size.height) {
      _fetchPosts();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _hasMore ? _posts.length + 1 : _posts.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == _posts.length) {
            return Center(child: CircularProgressIndicator());
          }
          return _buildPostCard(_posts[index]);
        },
      ),
    );
  }

  Future<void> _toggleLike(int postId, bool isLiked, Function callback) async {
    String url;
    String httpMethod;

    if (isLiked) {
      url = 'https://bmongsmong.com/api/diary/unlike?diary_id=$postId';
      httpMethod = 'DELETE';
    } else {
      url = 'https://bmongsmong.com/api/diary/like?diary_id=$postId';
      httpMethod = 'POST';
    }

    final headers = {'Authorization': 'Bearer $_accessToken'};

    await fetchDataFromApi(url, headers: headers, httpMethod: httpMethod);

    callback();
  }

  Widget _buildPostCard(dynamic post) {
    return Card(
      child: Column(
        children: [
          Text(post['dream_name']),
          InkWell(
            onTap: () {
              // 이미지 클릭시 이벤트 처리
              print('Image clicked: ${post['id']}');
            },
            child: Image.network(post['image_url']),
          ),
          Row(
            children: [
              Icon(Icons.visibility),
              Text(post['view_count'].toString()),
            ],
          ),
          Row(
            children: [
              InkWell(
                onTap: () async {
                  await _toggleLike(post['id'], post['is_liked'], () {
                    setState(() {
                      post['is_liked'] = !post['is_liked'];
                      post['like_count'] += post['is_liked'] ? 1 : -1;
                    });
                  });
                },
                child: Icon(
                  Icons.favorite,
                  color: post['is_liked'] ? Colors.red : Colors.grey,
                ),
              ),
              Text(post['like_count'].toString()),
            ],
          ),
          Row(
            children: [
              Icon(Icons.comment),
              Text(post['comment_count'].toString()),
            ],
          ),
        ],
      ),
    );
  }
}


