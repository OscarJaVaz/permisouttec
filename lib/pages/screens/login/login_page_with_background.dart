import 'package:flutter/material.dart';
import 'package:permisouttec/pages/screens/login/login_screen.dart';

class LoginPageWithBackground extends StatelessWidget {
  const LoginPageWithBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://wallpapercave.com/wp/wp2721266.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: const Login(),
      ),
    );
  }
}
