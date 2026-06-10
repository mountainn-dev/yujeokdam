import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'di/dependency_injection.dart';
import 'view/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env 가 없거나 키가 비어도 이야기 읽기는 동작한다(무대 화면만 키 필요).
  await dotenv.load(fileName: '.env', isOptional: true);
  await configureDependencies();
  runApp(const YujeokdamApp());
}
