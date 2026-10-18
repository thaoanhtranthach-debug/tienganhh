import 'package:flutter/foundation.dart';

class ExamPublicationState extends ChangeNotifier {
  ExamPublicationState._();

  static final instance = ExamPublicationState._();

  final List<bool> _published = [true, true, false];

  bool isPublished(int index) => _published[index];

  int get publishedCount => _published.where((published) => published).length;

  void setPublished(int index, bool isPublished) {
    if (_published[index] == isPublished) return;
    _published[index] = isPublished;
    notifyListeners();
  }
}
