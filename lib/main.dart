// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:comics_db_app/configuration/configuration.dart';
import 'package:comics_db_app/ui/widgets/app/my_app.dart';

// TODO delete this class when go to prod
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      }
      ..findProxy = (uri) => HttpClient.findProxyFromEnvironment(uri);
  }
}

void main() async {
  if (Configuration.apiKey.isEmpty) {
    throw StateError('TMDB_API_KEY is not set: run with --dart-define-from-file=secrets.json (see README)');
  }
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.library == 'image resource service' && details.exception.toString().contains('404')) {
      if (kDebugMode) {
        print('Suppressed cachedNetworkImage exception');
        return;
      }
    }
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };
  HttpOverrides.global = MyHttpOverrides();
  const app = MyApp();
  runApp(app);
}
