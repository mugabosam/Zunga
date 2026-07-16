import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive boxes are opened per-feature with AES keys wrapped by the
  // Keystore master key (§6.3); initFlutter just sets the directory.
  await Hive.initFlutter();
  runApp(const ProviderScope(child: ZungaApp()));
}
