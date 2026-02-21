import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitializer.init();

  runZonedGuarded(
    () => runApp(const App()),
    (error, stack) {
      FlutterError.presentError(
        FlutterErrorDetails(exception: error, stack: stack),
      );
    },
  );
}
