import 'package:flutter/material.dart';
import '../feature/common.dart';
import '../feature/apiService.dart';

class DiaryPage extends StatefulWidget {
  final int diaryId;
  final String? accessToken;

  DiaryPage({required this.diaryId, required this.accessToken, Key? key}) : super(key: key);

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  List<dynamic> _comments = [];
  dynamic _diaryData;

  @override
  void initState() {
    super.initState();
    _fetchDiaryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary Page'),
        iconTheme: IconThemeData(
          color: Colors.black, // 뒤로가기 버튼의 색상을 변경합니다. 원하는 색상으로 설정하세요.
        ),
      ),
      body: _diaryData == null
          ? Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_diaryData['is_public']) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Image.network(_diaryData['image_url']),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          await toggleLike(widget.accessToken, widget.diaryId, _diaryData['is_liked'], () {
                            setState(() {
                              _diaryData['is_liked'] = !_diaryData['is_liked'];
                              _diaryData['like_count'] += _diaryData['is_liked'] ? 1 : -1;
                            });
                          });
                        },
                        child: Icon(
                          Icons.favorite,
                          color: _diaryData['is_liked'] ? Colors.red : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(_diaryData['like_count'].toString()),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 4),
                      Text(_diaryData['view_count'].toString()),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.comment),
                      SizedBox(width: 4),
                      Text(_diaryData['comment_count'].toString()),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '게시 날짜: ${_diaryData['create_date']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '꿈 내용:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _diaryData['dream'],
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '해몽:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _diaryData['resolution'],
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '체크리스트:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _diaryData['checklist'],
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '댓글 목록:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildCommentList(),
          ],
        ),
      );
    } else {
      return Center(
        child: Text(
          '비공개 게시물입니다.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
  }

  Future<void> _fetchDiaryData() async {
    final url = 'https://bmongsmong.com/api/diary/read?diary_id=${widget.diaryId}';
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken}'
    };

    dynamic response = await fetchDataFromApi(url, headers: headers);
    if (response != null) {
      setState(() {
        _diaryData = response;
        _diaryData['is_liked'] = _diaryData['is_liked']; // 서버에서 받은 is_liked 값을 사용합니다.
        _diaryData['comments'] = []; // 필드를 추가해주세요. 실제 댓글을 가져오는 API가 있다면 이를 사용하여 값을 설정하세요.
      });
    }
  }

  Widget _buildCommentList() {
    return _comments.isEmpty
        ? Center(
      child: Text(
        '현재 작성된 댓글이 없습니다.',
        style: TextStyle(fontSize: 18),
      ),
    )
        : ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _comments.length,
      itemBuilder: (BuildContext context, int index) {
        final comment = _comments[index];
        return ListTile(
          leading: Icon(Icons.account_circle),
          title: Text(comment['author']),
          subtitle: Text(comment['content']),
        );
      },
    );
  }
}
