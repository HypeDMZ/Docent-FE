import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../dto/createRequest.dart';
import '../feature/apiService.dart';
import '../feature/token.dart';

class CreatePage extends StatefulWidget {
  CreatePage({Key? key}) : super(key: key);

  @override
  _CreateDreamPageState createState() => _CreateDreamPageState();
}

class _CreateDreamPageState extends State<CreatePage> {
  String? _accessToken;
  String _dreamText = '';
  stt.SpeechToText _speech = stt.SpeechToText();
  List<String> _images = [];
  bool _isListening = false;
  bool _isDreamCreated = false; // Indicating if a dream is created
  String _dreamName = '';
  String _dream = '';
  String _imageUrl = '';

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
          _dreamText = val.recognizedWords;
        });
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _generateDream() async {
    Map<String, dynamic> dreamResponse = await generateDream(_accessToken, _dreamText);
    setState(() {
      _isDreamCreated = true;
      _dreamName = dreamResponse['dream_name'];
      _dream = dreamResponse['dream'];
      _imageUrl = dreamResponse['image_url'];  // Assuming the dreamResponse contains an image URL.
    });
  }

  Future<void> _createDiary() async {
    // Assuming you've got a generateResolution functions.
    Map<String, dynamic> resolutionResponse = await generateResolution(_accessToken, _dreamText);

    String resolution = resolutionResponse['resolution'];
    String checklist = '';  // TODO: Update this with actual checklist data.
    bool isPublic = true;  // TODO: Update this based on user choice.

    Create create = Create(
      dreamName: _dreamName,
      dream: _dream,
      imageUrl: _imageUrl,
      resolution: resolution,
      checklist: checklist,
      isPublic: isPublic,
    );

    // Map<String, dynamic> diaryResponse = await createDiary(_accessToken, create);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Dream'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              maxLines: 10,
              onChanged: (value) {
                setState(() {
                  _dreamText = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Dream',
                hintText: 'Write about your dream...',
              ),
            ),
            IconButton(
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
              onPressed: _isListening ? _stopListening : _startListening,
            ),
            IconButton(
              icon: Icon(Icons.image),
              onPressed: () async {
                await generateAdditionalImage(_accessToken, 1);
              },
            ),
            ElevatedButton(
              onPressed: _isDreamCreated ? _createDiary : null,
              child: Text('Create Diary'),
            ),
            ElevatedButton(
              onPressed: _generateDream,
              child: Text('Create Dream'),
            ),
            Wrap(
              children: _images.map((url) => Image.network(url)).toList(),
            ),
            // New lines of code to show dream results
            if (_isDreamCreated) ...[
              Text('Dream Name: $_dreamName'),
              Text('Dream: $_dream'),
              Text('Image URL: $_imageUrl'),
            ],
          ],
        ),
      ),
    );
  }
}