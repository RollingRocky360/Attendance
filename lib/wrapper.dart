import 'package:attendance/screens/auth.dart';
import 'package:attendance/screens/home.dart';
import 'package:attendance/services/profile_provider.dart';
import 'package:attendance/services/summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);

    if (user == null) return AuthScreen();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          var profileNotifier = ProfileProvider(user);
          profileNotifier.init();
          return profileNotifier;
        }),
        ChangeNotifierProvider(create: (context) => SummaryProvider())
      ],
      child: HomeScreen(),
    );
  }
}
