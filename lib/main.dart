import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      debugPrint('Flutter error: ${details.exceptionAsString()}');
    }
  };

  ErrorWidget.builder = (FlutterErrorDetails details) => const _FatalErrorView();

  await runZonedGuarded<Future<void>>(
    () async {
      if (AppConfig.hasSupabase) {
        await Supabase.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,
          ),
        );
      }

      runApp(const ProviderScope(child: FamilyIqApp()));
    },
    (Object error, StackTrace stackTrace) {
      debugPrint('Uncaught application error: $error');
      debugPrintStack(stackTrace: stackTrace);
    },
  );
}

class _FatalErrorView extends StatelessWidget {
  const _FatalErrorView();

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Color(0xFF070914),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF9B75FF),
                  size: 52,
                ),
                SizedBox(height: 18),
                Text(
                  'FamilyIQ временно не может открыть этот экран',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Ваши локальные семейные данные не удалены. Перезапустите приложение.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
