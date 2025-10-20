import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staj_bul_demo/firebase_options.dart';
import 'package:staj_bul_demo/models/user_model.dart';
import 'package:staj_bul_demo/screens/authentication/auth_wrapper.dart';
import 'package:staj_bul_demo/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(StreamProvider<UserModel?>.value(
    value: Auth().user,
    initialData: null,
    catchError: (_, __) => null,
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}
