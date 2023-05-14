import 'package:flutter/material.dart';
import '../feature/apiService.dart';
import '../feature/token.dart';

class HotPage extends StatefulWidget {
  HotPage({Key? key}) : super(key: key);

  @override
  _HotPageState createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  Future<List<dynamic>>? _hotPosts; // null를 허용하도록 수정
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _accessToken = await fetchAccessToken();
    setState(() {
      _hotPosts = getHotPosts(_accessToken, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hot Posts'),
      ),
      body: _hotPosts == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<List<dynamic>>(
        future: _hotPosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final hotPost = snapshot.data![index];

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
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
            );
          }
        },
      ),
    );
  }
}