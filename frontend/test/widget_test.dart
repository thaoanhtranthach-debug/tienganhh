import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_reading_platform/main.dart';
import 'package:toeic_reading_platform/state/exam_publication_state.dart';
import 'package:toeic_reading_platform/screens/student/exam_result_screen.dart';
import 'package:toeic_reading_platform/screens/student/exam_taking_screen.dart';
import 'package:toeic_reading_platform/screens/teacher/exam_analytics_screen.dart';
import 'package:toeic_reading_platform/screens/teacher/exam_management_screen.dart';
import 'package:toeic_reading_platform/screens/teacher/exam_preview_screen.dart';
import 'package:toeic_reading_platform/screens/teacher/exam_upload_screen.dart';

void main() {
  testWidgets('Student exam list loads and opens teacher management', (
    tester,
  ) async {
    ExamPublicationState.instance.setPublished(0, true);
    await tester.pumpWidget(const ToeicApp());

    expect(find.text('Luyện thi TOEIC Reading'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('TOEIC Full Reading Test 2025 - Alpha'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('TOEIC Full Reading Test 2025 - Alpha'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Giảng viên'));
    await tester.pumpAndSettle();

    expect(find.text('Quản lý Đề thi'), findsOneWidget);
    expect(find.text('Thêm đề'), findsOneWidget);
  });

  testWidgets('Hiding an exam removes it from the student list', (
    tester,
  ) async {
    ExamPublicationState.instance.setPublished(0, true);
    await tester.pumpWidget(const ToeicApp());

    await tester.tap(find.text('Giảng viên'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(Switch).first,
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(find.byType(Switch).first).value, isFalse);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('TOEIC Full Reading Test 2025 - Alpha'), findsNothing);

    ExamPublicationState.instance.setPublished(0, true);
  });

  testWidgets('Teacher exam screens render', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExamUploadScreen()));
    expect(find.text('Tải lên đề thi mới'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: ExamPreviewScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Xem trước & rà soát đề'), findsOneWidget);
    expect(
      find.text('What is indicated about Ms. Sarah Jenkins?'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Chỉnh sửa câu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chỉnh sửa câu'));
    await tester.pumpAndSettle();
    expect(find.text('Chỉnh sửa câu 153'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('preview-question-prompt')),
      'Updated preview question',
    );
    await tester.tap(find.text('Lưu thay đổi'));
    await tester.pumpAndSettle();
    expect(find.text('Updated preview question'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: ExamAnalyticsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('TOEIC Master  ·  Thống kê'), findsOneWidget);
  });

  testWidgets('Teacher management requires backend sign-in for real exams', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExamManagementScreen()));

    expect(find.text('Tải đề thật'), findsOneWidget);
    expect(find.text('Chỉnh sửa câu hỏi'), findsNothing);
    await tester.tap(find.text('Tải đề thật'));
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập giảng viên'), findsOneWidget);
    expect(find.text('Tên đăng nhập hoặc email'), findsOneWidget);
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
  });

  testWidgets('Student test and result screens render', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExamTakingScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Phòng Thi TOEIC'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('What is indicated about Ms. Sarah Jenkins?'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      find.text('What is indicated about Ms. Sarah Jenkins?'),
      findsOneWidget,
    );

    await tester.pumpWidget(const MaterialApp(home: ExamResultScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Chi Tiết Kết Quả'), findsOneWidget);
    expect(find.text('Phân tích kỹ năng theo Part'), findsOneWidget);
  });
}
