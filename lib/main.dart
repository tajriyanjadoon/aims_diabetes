import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'core/routes/auth_gate.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/password_reset_provider.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const MyApp());

  // Keep the splash screen visible for ~2.5 seconds (2-3 seconds)
  await Future.delayed(const Duration(milliseconds: 2500));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.authProvider, this.passwordResetProvider});

  /// Optional [AuthProvider] instance for testing and custom injection.
  final AuthProvider? authProvider;

  /// Optional [PasswordResetProvider] instance for testing and custom injection.
  final PasswordResetProvider? passwordResetProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (authProvider != null)
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider!)
        else
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider()..initialize(),
          ),
        if (passwordResetProvider != null)
          ChangeNotifierProvider<PasswordResetProvider>.value(
            value: passwordResetProvider!,
          )
        else
          ChangeNotifierProvider<PasswordResetProvider>(
            create: (_) => PasswordResetProvider(),
          ),
      ],
      child: MaterialApp(
        title: 'AIMSD',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}
