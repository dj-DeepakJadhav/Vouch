import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/router.dart' show captureLaunchDeepLink;
import 'client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  captureLaunchDeepLink();
  await initializeClient();
  runApp(const VouchApp());
}
