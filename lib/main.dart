import 'package:flutter/material.dart';

import 'di/dependency_injection.dart';
import 'view/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const YujeokdamApp());
}
