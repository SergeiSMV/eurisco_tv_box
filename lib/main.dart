import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'presentation/android_main.dart';
import 'presentation/auth.dart';
import 'data/implements/server_implementation.dart';


void main() async {
  await Hive.initFlutter();
  await Hive.openBox('hiveStorage');
  String auth = await ServerImpl().autoAuth();
  runApp(ProviderScope(child: App(auth: auth)));
}


class App extends StatelessWidget {
  final String auth;
  const App({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF687797),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)
          ),
        )
      ),
      home: authRouter(auth),
      // home: auth == 'unlogin' || auth == 'denied' ? const AuthPage() : 
      //   const AuthPage() // const MainPage(),
    );
  }
}

Widget authRouter(String auth){
  late Widget router;
  if (auth == 'unlogin' || auth == 'denied'){
    router = const AuthAndroid();
  } else {
    router = const AndroidMain();
  }
  return router;
}