import 'package:flutter/material.dart';
import '../feature/apiService.dart';
import '../feature/token.dart';
import 'diary_page.dart';

class HotPage extends StatefulWidget {
  HotPage({Key? key}) : super(key: key);

  @override
  _HotPageState createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  List<dynamic> _hotPosts = [];
  String? _accessToken;
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _accessToken = await fetchAccessToken();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasMore = false; // Set _hasMore to false during the fetch
    });

    List<dynamic> newPosts = await getHotPosts(_accessToken, _page);

    setState(() {
      _isLoading = false;
      if (newPosts.isEmpty) {
        _hasMore = false; // if no more posts, set _hasMore to false
      } else {
        _hotPosts.addAll(newPosts);
        _page++;
        _hasMore = true; // Set _hasMore to true after successfully fetching posts
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0 && _hasMore) {
        print('Reached the bottom');
        _fetchPosts();
      }
    } else if (_scrollController.position.maxScrollExtent.isFinite && _scrollController.position.maxScrollExtent > 0 && _hotPosts.isNotEmpty) {
      // Ensure maxScrollExtent is a finite number and not zero and _hotPosts is not empty before doing the calculation.
      // Calculate the current index.
      int currentIndex = (_scrollController.position.pixels / _scrollController.position.maxScrollExtent * _hotPosts.length).floor();
      if (_hotPosts.length - currentIndex <= 4 && _hasMore) {
        _fetchPosts();
      }
    }
  }

  Future<void> _onRefresh() async {
    _page = 1;
    _hotPosts = [];
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '인기 게시물',
            style: TextStyle(color: Colors.black),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _hotPosts.length,
          itemBuilder: (context, index) {
            final hotPost = _hotPosts[index];
            return Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => DiaryPage(
                    diaryId: hotPost['id'],
                    accessToken: _accessToken,
                  )));
                },
                leading: hotPost['image_url'] != null
                    ? Image.network(hotPost['image_url'])
                    : SizedBox(width: 50, height: 50),
                title: Text(hotPost['dream_name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Posted by: ${hotPost['userNickname']}'),
                    Text('Likes: ${hotPost['like_count']}'),
                    Text('Views: ${hotPost['view_count']}'),
                    Text('Comments: ${hotPost['comment_count']}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}