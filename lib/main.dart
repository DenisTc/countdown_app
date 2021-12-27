import 'package:countdown_calendar/screens/countdown_screen.dart';
import 'package:countdown_calendar/constants.dart' as constants;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: constants.textTitleApp,
      home: CountdownScreen(),
    );
  }
}
