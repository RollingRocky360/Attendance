import 'package:attendance/firebase_options.dart';
import 'package:attendance/services/auth.dart';
import 'package:attendance/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(StreamProvider<User?>.value(
      initialData: null,
      value: AuthService.user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AppWrapper(),
      )));
}
