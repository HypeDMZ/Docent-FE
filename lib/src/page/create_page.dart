import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../dto/createRequest.dart';
import '../feature/apiService.dart';
import '../feature/token.dart';
import 'app.dart';

class CreatePage extends StatefulWidget {
  CreatePage({Key? key}) : super(key: key);

  @override
  _CreateDreamPageState createState() => _CreateDreamPageState();
}

class _CreateDreamPageState extends State<CreatePage> {
  String? _accessToken;
  String _dreamText = '';
  stt.SpeechToText _speech = stt.SpeechToText();
  List<String> _imageUrls = [];
  bool _isListening = false;
  bool _isDreamCreated = false;
  int _dreamId = 0;
  String _dreamName = '';
  String _dream = '';
  String _imageUrl = '';
  String _resolution = '';
  bool _isLoading = false;
  bool _isGeneratingDream = false; // New state
  bool _isLoadingAdditionalImages = false; // New state
  bool _canGoBack = false;
  bool _isPublic = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _accessToken = await fetchAccessToken();
    _speech.initialize();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(onResult: (val) {
        setState(() {
          _dreamText = _dreamText + ' ' + val.recognizedWords;
        });
      });
    }
  }

  void _resetState() {
    setState(() {
      _dreamText = '';
      _isListening = false;
      _isDreamCreated = false;
      _dreamName = '';
      _dream = '';
      _imageUrl = '';
      _resolution = '';
      _isLoading = false;
      _isGeneratingDream = false; // Reset
      _isLoadingAdditionalImages = false; // Reset
    });
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _generateDream() async {
    setState(() {
      _isGeneratingDream = true; // Set state before making request
    });

    Future<Map<String, dynamic>> dreamFuture = generateDream(_accessToken, _dreamText);
    Future<Map<String, dynamic>> resolutionFuture = generateResolution(_accessToken, _dreamText);

    List<dynamic> responses = await Future.wait([dreamFuture, resolutionFuture]);

    setState(() {
      _isDreamCreated = true;
      _dreamId = responses[0]['id'];
      _dreamName = responses[0]['dream_name'];
      _dream = responses[0]['dream'];
      _imageUrls.add(responses[0]['image_url']);
      _resolution = responses[1]['dream_resolution'];
      _canGoBack = true;
      _isGeneratingDream = false; // Reset state after response is received
    });
  }

  Future<void> _generateAdditionalImages() async {
    setState(() {
      _isLoadingAdditionalImages = true; // Set state before making request
    });

    // Call the API and get the response
    Map<String, dynamic> imageResponse = await generateAdditionalImage(_accessToken, _dreamId);

    // Update state to include the new image
    if (imageResponse['image_url'] != null) {
      setState(() {
        _imageUrls.add(imageResponse['image_url']);
      });
    }

    setState(() {
      _isLoadingAdditionalImages = false; // Reset state after response is received
    });
  }

  Future<void> _createDiary() async {
    String checklist = '';
    bool isPublic = true;
    _imageUrl = _imageUrls[_currentIndex];

    Create create = Create(
      dreamName: _dreamName,
      dream: _dream,
      imageUrl: _imageUrl,
      resolution: _resolution,
      checklist: checklist,
      isPublic: isPublic,
    );

    Map<String, dynamic> diaryResponse = await createDiary(_accessToken, create);

    if (diaryResponse['id'] != null) {
      // Navigate to the diary page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('꿈 그리기', style: TextStyle(color: Colors.black)),
        leading: _canGoBack
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            _resetState();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 2)),
            );
          },
        )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          padding: EdgeInsets.only(top: 50.0), // 상단에 패딩 추가
          children: <Widget>[
            if (_isGeneratingDream || _isLoadingAdditionalImages) ...[
              Center(child: CircularProgressIndicator()),
            ]
            else if (_isDreamCreated) ...[
              Text('$_dreamName', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: 200,
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9.0),
                        child: AspectRatio(
                          aspectRatio: 1.0, // For 1:1 aspect ratio
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width, // Adjust the value as needed
                              maxHeight: MediaQuery.of(context).size.width, // Adjust the value as needed
                            ),
                            child: Image.network(_imageUrls[index], fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Text('Image: ${_currentIndex + 1} / ${_imageUrls.length}', textAlign: TextAlign.center),
              ElevatedButton(
                onPressed: _imageUrls.length >= 3 ? null : _generateAdditionalImages,
                child: Text('추가 이미지 생성'),
              ),
              SizedBox(height: 10),
              Text('꿈 내용: $_dream', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('해몽: $_resolution', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              SwitchListTile(
                title: Text("공개"),
                value: _isPublic,
                onChanged: (bool value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _createDiary,
                child: Text('저장하기'),
              ),
            ],
            if (!_isDreamCreated) ...[
              TextField(
                maxLines: 10,
                onChanged: (value) {
                  setState(() {
                    _dreamText = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '꿈 입력',
                  hintText: '꿈을 말하거나 입력해주세요.',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 50),
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _dreamText.isEmpty ? null : _generateDream,
                child: Text('꿈 생성하기'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}