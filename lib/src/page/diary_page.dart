import 'package:flutter/material.dart';
import '../feature/apiService.dart';
import 'package:intl/intl.dart';

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
  int _pageNumber = 1;
  bool _isLoadingComment = false;
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    fetchDiaryData(widget.accessToken, widget.diaryId, (response) {
      if (response != null) {
        setState(() {
          _diaryData = response;
          _diaryData['is_liked'] = _diaryData['is_liked'];
          _diaryData['comments'] = [];
          _commentCount = _diaryData['comment_count']; // 댓글 개수 초기화
        });
        _fetchAndLoadComments();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary Page'),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white, // 앱 바 배경색 변경
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
                  size: 24,
                ),
              ),
              SizedBox(width: 4),
              Text(
                _diaryData['like_count'].toString(),
                style: TextStyle(fontSize: 16),
              ),

              // 조회수 아이콘 및 텍스트
              SizedBox(width: 16),
              Icon(
                Icons.visibility,
                size: 24,
              ),
              SizedBox(width: 4),
              Text(
                _diaryData['view_count'].toString(),
                style: TextStyle(fontSize: 16),
              ),

              // 댓글 아이콘 및 텍스트
              SizedBox(width: 16),
              Icon(
                Icons.comment,
                size: 24,
              ),
              SizedBox(width: 4),
              Text(
                _commentCount.toString(),
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          if (_diaryData['is_owner'])
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 24,
                  ),
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
                  icon: Icon(
                    Icons.delete,
                    size: 24,
                  ),
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
                  '게시 날짜: ${_formatDateTime(_diaryData['create_date'])}',
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
                // Text(
                //   '체크리스트:',
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                // Text(
                //   checklistText,
                //   style: TextStyle(fontSize: 18),
                // ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '댓글 목록:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildCommentList(),
          _buildCommentInput(),
        ],
      ),
    );
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

  Future<void> _fetchAndLoadComments() async {
    List<dynamic> newComments = await fetchCommentList(widget.accessToken, widget.diaryId, _pageNumber);
    setState(() {
      _comments.addAll(newComments.where((comment) => comment != null).toList());
      _pageNumber += 1;
    });
  }

  String _formatDateTime(String dateString) {
    try {
      String year = dateString.substring(0, 4);
      String month = dateString.substring(4, 6);
      String day = dateString.substring(6, 8);
      String hour = dateString.substring(8, 10);
      String minute = dateString.substring(10, 12);
      String second = dateString.substring(12, 14);

      DateTime parsedDateTime = DateTime.parse('$year-$month-$day $hour:$minute:$second');
      DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
      return formatter.format(parsedDateTime);
    } catch (e) {
      return dateString;
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
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_circle, size: 32.0),
                      SizedBox(width: 8),
                      Text(
                        comment['userNickname'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (comment['isMine'])
                    _isLoadingComment
                        ? CircularProgressIndicator()
                        : IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        setState(() {
                          _isLoadingComment = true;
                        });
                        await deleteComment(
                          widget.accessToken,
                          widget.diaryId,
                          comment['id'],
                              () {
                            setState(() {
                              _comments.removeAt(index);
                              _isLoadingComment = false;
                              _commentCount -= 1;
                            });
                          },
                        );
                      },
                    ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                comment['comment'],
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '${_formatDateTime(comment['create_date'])}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    TextEditingController _commentController = TextEditingController();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: '댓글 작성',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                createComment(
                  widget.accessToken,
                  widget.diaryId,
                  _commentController.text,
                      (newComment) {
                    setState(() {
                      _comments.add({
                        'id': newComment['id'],
                        'userNickname': newComment['userNickname'],
                        'comment': newComment['comment'],
                        'isMine': newComment['isMine'],
                        'create_date': _formatDateTime(newComment['create_date']),
                      });
                      _commentCount += 1;
                    });
                    _commentController.clear();
                  },
                );
              }
            },
            child: Text('작성'),
          ),
        ],
      ),
    );
  }
}
