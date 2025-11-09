import 'package:flutter/material.dart';
import 'package:quote_builder/screens/quote_from_screen.dart';
import 'package:quote_builder/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Quote Builder',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const QuoteFormScreen()
    );
  }
}
