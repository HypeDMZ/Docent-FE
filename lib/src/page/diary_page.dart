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

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // 좋아요 아이콘 및 텍스트
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

              // 조회수 아이콘 및 텍스트
              SizedBox(width: 16),
              Icon(Icons.visibility),
              SizedBox(width: 4),
              Text(_diaryData['view_count'].toString()),

              // 댓글 아이콘 및 텍스트
              SizedBox(width: 16),
              Icon(Icons.comment),
              SizedBox(width: 4),
              Text(_diaryData['comment_count'].toString()),
            ],
          ),
          if (_diaryData['is_owner'])
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    await showEditDialog(context, _diaryData['dream_name'], _diaryData['dream'], (String newDreamName, String newDream) async {
                      await modifyDiary(widget.accessToken, widget.diaryId, newDreamName, newDream, () {
                        setState(() {
                          _diaryData['dream_name'] = newDreamName;
                          _diaryData['dream'] = newDream;
                        });
                        print('Diary modified successfully');
                      });
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    final confirmDelete = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("삭제 확인"),
                          content: const Text("게시글을 지우겠습니까?"),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("삭제")
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("취소"),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete != null && confirmDelete) {
                      await deleteDiary(widget.accessToken, widget.diaryId, () {
                        print('Delete clicked: ${widget.diaryId}');
                        Navigator.pop(context, true); // 삭제 성공 시 결과를 전달합니다.
                      });
                    }
                  },
                ),
                Switch(
                  value: _diaryData['is_public'],
                  onChanged: (bool value) async {
                  await toggleDiaryVisibility(widget.accessToken, widget.diaryId, value, () {
                  setState(() {
                  _diaryData['is_public'] = value;
                  });
                });
              },),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    String dreamText = _diaryData['is_public'] || _diaryData['is_owner'] ? _diaryData['dream'] : '비공개 게시물입니다.';
    String resolutionText = _diaryData['is_public'] || _diaryData['is_owner'] ? _diaryData['resolution'] : '비공개 게시물입니다.';
    String checklistText = _diaryData['is_public'] || _diaryData['is_owner'] ? _diaryData['checklist'] : '비공개 게시물입니다.';

    return SingleChildScrollView(
      child: Column(
        children: [
          Image.network(_diaryData['image_url']),
          _buildActionRow(),
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
                  dreamText,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  '해몽:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  resolutionText,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  '체크리스트:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  checklistText,
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

  Future<void> showEditDialog(BuildContext context, String dreamName, String dream, Function(String newDreamName, String newDream) onSave) async {
    TextEditingController dreamNameController = TextEditingController(text: dreamName);
    TextEditingController dreamController = TextEditingController(text: dream);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('게시물 수정'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: dreamNameController,
                  decoration: InputDecoration(labelText: '꿈 이름'),
                ),
                TextField(
                  controller: dreamController,
                  decoration: InputDecoration(labelText: '꿈 내용'),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () {
                onSave(dreamNameController.text, dreamController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
