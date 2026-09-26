import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StaticPageScreen extends StatelessWidget {
  const StaticPageScreen({super.key, required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(title), backgroundColor: AppColors.bg),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(body, style: const TextStyle(fontSize: 14.5, height: 1.6, color: AppColors.muted)),
      ),
    );
  }
}
