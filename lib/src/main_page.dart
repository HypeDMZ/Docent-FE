import 'package:flutter/material.dart';
import 'common.dart';

class MainPage extends StatefulWidget {
  final String? accessToken;

  MainPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<dynamic> _posts = [];
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    if (!_hasMore) return;

    final url = 'https://bmongsmong.com/api/diary/list?page=$_page';
    final headers = {'Authorization': 'Bearer ${widget.accessToken}'};

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: ListView.builder(
        itemCount: _hasMore ? _posts.length + 1 : _posts.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == _posts.length) {
            _fetchPosts();
            return Center(child: CircularProgressIndicator());
          }
          return _buildPostCard(_posts[index]);
        },
      ),
    );
  }

  Widget _buildPostCard(dynamic post) {
    return Card(
      child: Column(
        children: [
          Text(post['dream_name']),
          Image.network(post['image_url']),
          Row(
            children: [
              Icon(Icons.visibility),
              Text(post['view_count'].toString()),
            ],
          ),
          Row(
            children: [
              Icon(Icons.favorite),
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


