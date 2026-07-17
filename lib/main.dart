import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/data/profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive boxes are opened per-feature with AES keys wrapped by the
  // Keystore master key (§6.3); initFlutter just sets the directory.
  await Hive.initFlutter();
  // The registered number gates the app: read it before the first frame
  // so the router can decide between /register and /home instantly.
  final myNumber = await ProfileStore.readMyNumber();
  runApp(ProviderScope(
    overrides: [
      myNumberProvider.overrideWith(() => MyNumberNotifier(myNumber)),
    ],
    child: const ZungaApp(),
  ));
}
