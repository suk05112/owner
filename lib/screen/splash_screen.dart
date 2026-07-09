import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFEE7F44),
        body: Center(
          child: Text(
            'Gifnut\n사장님',
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: 'Paperlogy',
              fontWeight: FontWeight.w800,
              fontSize: 80,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
