import 'package:flutter/material.dart';
import 'package:docent/src/app.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'keys.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: KakaoKeys.nativeAppKey,
  );
  runApp(App());
}