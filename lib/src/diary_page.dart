import 'package:flutter/material.dart';
import 'common.dart';

class DiaryPage extends StatefulWidget {
  final int diaryId;
  final String? accessToken;

  DiaryPage({required this.diaryId, required this.accessToken, Key? key}) : super(key: key);

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  dynamic _diaryData;

  @override
  void initState() {
    super.initState();
    _fetchDiaryData();
  }

  Future<void> _fetchDiaryData() async {
    final url = 'https://bmongsmong.com/api/diary/read?diary_id=${widget
        .diaryId}';
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken}'
    };

    dynamic data = await fetchDataFromApi(url, headers: headers);
    if (data != null) {
      setState(() {
        _diaryData = data;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary Page'),
      ),
      body: _diaryData == null
          ? Center(child: CircularProgressIndicator())
          : _diaryData['is_public']
          ? SingleChildScrollView(
        child: Column(
          children: [
            Image.network(_diaryData['image_url']),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Icon(Icons.visibility),
                    Text(_diaryData['view_count'].toString()),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.favorite),
                    Text(_diaryData['like_count'].toString()),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.comment),
                    Text(_diaryData['comment_count'].toString()),
                  ],
                ),
              ],
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
          ],
        ),
      )
          : Center(
        child: Text(
          '비공개 게시물입니다.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}