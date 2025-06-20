import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models.dart' show CurrentUser;
import 'screens.dart' show HomeScreen, LoginScreen, NoteEditor, SettingsScreen;
import 'services.dart' show SharingService;
import 'styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sharing service
  SharingService.initialize();

  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Keep',
        theme: Theme.of(context).copyWith(
          brightness: Brightness.light,
          primaryColor: Colors.white,
          colorScheme: Theme.of(context).colorScheme.copyWith(
                secondary: kAccentColorLight,
              ),
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                elevation: 0,
                iconTheme: IconThemeData(
                  color: kIconTintLight,
                ),
              ),
          scaffoldBackgroundColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
                titleLarge: const TextStyle(
                  color: kIconTintLight,
                ),
              ),
        ),
        home: HomeScreen(),
        routes: {
          '/settings': (_) => SettingsScreen(),
        },
        onGenerateRoute: _generateRoute,
      );

  /// Handle named route
  Route _generateRoute(RouteSettings settings) {
    try {
      return _doGenerateRoute(settings);
    } catch (e, s) {
      debugPrint("failed to generate route for $settings: $e $s");
      return MaterialPageRoute<void>(
        builder: (_) => Scaffold(body: Center(child: Text('잘못된 경로'))),
      );
    }
  }

  Route _doGenerateRoute(RouteSettings settings) {
    if (settings.name == null || settings.name!.isEmpty) {
      return MaterialPageRoute<void>(
        builder: (_) => Scaffold(body: Center(child: Text('잘못된 경로'))),
      );
    }

    final uri = Uri.parse(settings.name!);
    final path = uri.path;
    switch (path) {
      case '/note':
        {
          final note = (settings.arguments as Map? ?? {})['note'];
          return _buildRoute(settings, (_) => NoteEditor(note: note));
        }
      default:
        return MaterialPageRoute<void>(
          builder: (_) => Scaffold(body: Center(child: Text('잘못된 경로'))),
        );
    }
  }

  /// Create a [Route].
  Route _buildRoute(RouteSettings settings, WidgetBuilder builder) =>
      MaterialPageRoute<void>(
        settings: settings,
        builder: builder,
      );
}
