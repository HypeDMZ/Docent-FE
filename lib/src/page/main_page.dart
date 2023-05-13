import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../feature/common.dart';
import 'diary_page.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../feature/apiService.dart';

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
  double _screenHeight = 0.0;
  bool _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _fetchPosts(refresh: true),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                snap: true,
                floating: true,
                pinned: false,
                automaticallyImplyLeading: false,
                expandedHeight: 4, // 원하는 AppBar 높이로 설정하세요.
                flexibleSpace: InkWell(
                  onTap: () {
                    // 로고 클릭시 처리할 작업을 여기에 추가하세요.
                    print('Logo clicked');
                  },
                    child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return Container(
                            alignment: Alignment.centerLeft, // AppBar의 높이에 맞추기 위해
                            child: Padding(
                              padding: EdgeInsets.only(top: 1, left: 6), // 원하는 만큼의 상단 패딩을 추가하세요.
                              child: Image.asset(
                                'lib/src/img/docent_logo.png', // 로컬 이미지 경로를 설정하세요.
                                width: 120, // 이미지 너비를 설정하세요.
                                height: constraints.maxHeight - 1, // AppBar 높이에 맞게 이미지 높이를 설정하세요.
                                fit: BoxFit.contain, // 이미지를 주어진 너비와 높이에 맞게 조절하려면 BoxFit.contain을 사용하세요.
                              ),
                            ),
                          );
                        }
                    )
                ),
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
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (int index) {
          print(index);
        },
      ),
    );
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

  Future<void> _fetchPosts({bool refresh = false}) async {
    if (_isLoading || _accessToken == null) return;
    _isLoading = true;

    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    final url = 'https://bmongsmong.com/api/diary/list?page=$_page';
    final headers = {'Authorization': 'Bearer $_accessToken'};

    dynamic data = await fetchDataFromApi(url, headers: headers);

    if (data != null) {
      setState(() {
        if (refresh) {
          _posts.clear();
        }
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
      if (_scrollController.position.pixels != 0 && _hasMore) {
        print('Reached the bottom');
        _fetchPosts();
      }
    } else {
      // 현재 인덱스를 계산합니다.
      int currentIndex = (_scrollController.position.pixels / _scrollController.position.maxScrollExtent * _posts.length).floor();
      if (_posts.length - currentIndex <= 2 && _hasMore) {
        _fetchPosts();
      }
    }
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
              print('Image clicked: ${post['id']}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryPage(
                    diaryId: post['id'],
                    accessToken: _accessToken,
                  ),
                ),
              ).then((result) {
                if (result != null && result) {
                  _fetchPosts(refresh: true);
                }
              });
            },
            child: FadeInImage(
              placeholder: AssetImage('lib/src/img/loading_img.png'), // 로딩 중에 표시할 이미지를 지정하세요.
              image: NetworkImage(post['image_url']),
              fit: BoxFit.cover,
              width: double.infinity,
              fadeInDuration: Duration(milliseconds: 50), // 페이드 인 애니메이션 시간 설정
              fadeOutDuration: Duration(milliseconds: 50), // 페이드 아웃 애니메이션 시간 설정
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
                        await toggleLike(_accessToken, post['id'] as int, post['is_liked'] as bool, () {
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