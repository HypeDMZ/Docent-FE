import 'package:flutter/material.dart';
import '../feature/apiService.dart';
import '../feature/token.dart';
import 'diary_page.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _scrollController = ScrollController();
  String? _accessToken;
  List<dynamic> _diaries = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _lastPage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _accessToken = await fetchAccessToken();
      _fetchDiaries();
    });
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchDiaries() async {
    if (_isLoading || _lastPage) return;

    setState(() {
      _isLoading = true;
    });

    var response = await fetchDiaries(_accessToken, _currentPage);
    if (response != null) {
      _diaries.addAll(response);
      _currentPage++;
    }
    else {
      _lastPage = true;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshDiaries() async {
    setState(() {
      _currentPage = 1;
      _diaries.clear();
      _lastPage = false;
    });
    await _fetchDiaries();
  }

  // Pagination occurs when the ScrollController is 100 pixels away from the end.
  _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _fetchDiaries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보', style: TextStyle(color: Colors.black)),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDiaries,
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(radius: 120.0),
                  Text('Username', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                  Text('Bio goes here...'),
                ],
              ),
            ),
            _isLoading && _diaries.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: _diaries.length,
                itemBuilder: (context, index) {
                  var diary = _diaries[index];
                  if (diary is Map) {
                    return GridTile(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: InkWell(
                          onTap: () {
                            print('Image clicked: ${diary['id']}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiaryPage(
                                  diaryId: diary['id'],
                                  accessToken: _accessToken,
                                ),
                              ),
                            ).then((result) {
                              if (result != null && result) {
                                _fetchDiaries();
                              }
                            });
                          },
                          child: Image.network(diary['image_url'], fit: BoxFit.cover),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}