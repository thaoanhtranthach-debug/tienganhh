import 'package:flutter/material.dart';

import 'screens/student/exam_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ToeicApp());
}

class ToeicApp extends StatelessWidget {
  const ToeicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOEIC Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ExamListScreen(),
    );
  }
}
