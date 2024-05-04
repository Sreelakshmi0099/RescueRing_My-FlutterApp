import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:rescue_ring/login.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}

setdata(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 7), () {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    });
  });
}

class _splashscreenState extends State<splashscreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    setdata(context);
    return Scaffold(
      body: Center(
        child: Lottie.network(
            'https://lottie.host/d2702d0b-28c3-43e4-a4a4-ad8ce81cc7db/jzSUZ9jcq4.json'),
      ),
    );
  }
}
