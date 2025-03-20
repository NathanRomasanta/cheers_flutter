import 'package:cheers_flutter/services/AuthGate.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: FluentThemeData(
        fontFamily: 'Product Sans',
        navigationPaneTheme: const NavigationPaneThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
