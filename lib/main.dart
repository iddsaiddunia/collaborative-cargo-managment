import 'package:collaborative_cargo_managment_app/nonAuth/login.dart';
import 'package:collaborative_cargo_managment_app/services/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:
          "AIzaSyC1QzfJN9x3HYCT_sjdvFOp5r_jjrmWKy4", // paste your api key here
      appId:
          "1:749975818539:android:b0f970e0c32a4f69ae756e", //paste your app id here
      messagingSenderId: "749975818539", //paste your messagingSenderId here
      projectId: "collaborative-cargo", //paste your project id here
    ),
  );
  await Permission.location.request();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // Add more providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
