import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common.dart';
import 'diary_page.dart';
import 'widgets/bottom_navigation_bar.dart';

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _fetchAccessToken();
    _fetchPosts();
    _scrollController.addListener(_onScroll);
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
    print('fetching page $_page');

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
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        print('Reached the bottom');
        _fetchPosts();
      }
    } else {
      // 현재 인덱스를 계산합니다.
      int currentIndex = (_scrollController.position.pixels / _scrollController.position.maxScrollExtent * _posts.length).floor();
      if (_posts.length - currentIndex <= 2) {
        _fetchPosts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            title: Text('Docent'),
            snap: false,
            floating: true,
            pinned: false,
            expandedHeight: 35.0,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                if (index == _posts.length) {
                  return Center(child: CircularProgressIndicator());
                }
                return _buildPostCard(_posts[index]);
              },
              childCount: _hasMore ? _posts.length + 1 : _posts.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (int index) {
          print(index);
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
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              // 이미지 클릭시 이벤트 처리
              // diary_page로 이동
              print('Image clicked: ${post['id']}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryPage(
                    diaryId: post['id'],
                    accessToken: _accessToken,
                  ),
                ),
              );
            },
            child: Image.network(
              post['image_url'],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                    SizedBox(width: 4.0),
                    Text(post['like_count'].toString()),

                    SizedBox(width: 8.0),
                    InkWell(
                      onTap: () {
                        // 댓글 클릭시 이벤트 처리
                        print('Comment clicked: ${post['id']}');
                      },
                      child: Icon(Icons.comment),
                    ),
                    SizedBox(width: 4.0),
                    Text(post['comment_count'].toString()),
                    SizedBox(width: 8.0),
                    Icon(Icons.visibility),
                    SizedBox(width: 4.0),
                    Text(post['view_count'].toString()),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.flag),
                  onPressed: () {
                    // 신고 버튼 클릭시 이벤트 처리
                    print('Report clicked: ${post['id']}');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
