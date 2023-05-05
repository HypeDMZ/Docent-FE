import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KakaoWebViewPage extends StatelessWidget {
  final String url;

  KakaoWebViewPage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('카카오 로그인')),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (NavigationRequest request) {
          // 리다이렉트 URL을 처리하려면 이 부분을 수정하십시오.
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}