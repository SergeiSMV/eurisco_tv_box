import 'package:eurisco_tv_box/data/implements/hive_implementation.dart';
import 'package:eurisco_tv_box/data/implements/server_implementation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'presentation/auth.dart';
import 'presentation/main_box.dart';


void main() async {
  await Hive.initFlutter();
  await Hive.openBox('hiveStorage');
  String client = await HiveImpl().getClient();
  String connection = await ServerImpl().checkDeviceConnection();
  runApp(ProviderScope(child: App(client: client, connection: connection,)));
}


class App extends StatelessWidget {
  final String connection;
  final String client;
  const App({super.key, required this.client, required this.connection});

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
      home: authRouter(client, connection)
      // home: client.isEmpty ? const Auth() : const AndroidMain()
    );
  }
}

Widget authRouter(String client, String connection) {
  late Widget router;
  if (client.isEmpty){
    router = const Auth();
  } else {
    connection == 'disconnect' ? {
      HiveImpl().saveClient(''),
      router = const Auth()
    } : router = const MainBox();
  }
  return router;
}