import 'package:attendance/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignInButton(
                Buttons.Google,
                onPressed: () {
                  AuthService.signInWithGoogle();
                },
              ),
          ],
        ),
      ),
    );
  }
}
