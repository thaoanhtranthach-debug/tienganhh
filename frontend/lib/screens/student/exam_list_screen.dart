import 'package:flutter/material.dart';

import '../../state/exam_publication_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/exam_ui.dart';
import '../teacher/exam_analytics_screen.dart';
import '../teacher/exam_management_screen.dart';
import 'exam_result_screen.dart';
import 'exam_taking_screen.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  String _filter = 'Tất cả đề (8)';
  final _search = TextEditingController();
  final _publicationState = ExamPublicationState.instance;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openExam({bool result = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            result ? const ExamResultScreen() : const ExamTakingScreen(),
      ),
    );
  }

  void _navigate(int index) {
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ExamManagementScreen()),
      );
    } else if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ExamAnalyticsScreen()),
      );
    } else if (index == 3) {
      showAppMessage(context, 'Hồ sơ tài khoản sẽ được bổ sung sau.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExamPage(
      title: 'TOEIC Master  ·  Đề Thi',
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 0,
        onSelected: _navigate,
      ),
      child: AnimatedBuilder(
        animation: _publicationState,
        builder: (context, _) => PageBody(
          children: [
            SurfaceCard(
              color: AppColors.surfaceMid,
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.school_outlined),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phân hệ Sinh viên  •  ACTIVE',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Student Portal • Luyện đề thi chứng chỉ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigate(1),
                    child: const Text('Giảng viên'),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryContainer, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2200236F),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const InfoPill(
                    'IIG Format Standard 2025',
                    icon: Icons.verified_outlined,
                    color: Color(0x334AC08F),
                    textColor: Color(0xFF85F8C4),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Luyện thi TOEIC Reading',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Nâng cao phản xạ đọc hiểu Parts 5, 6, 7',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Text(
                        'Tiến độ đề:  5 / 12 đề',
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Text(
                        'ĐTB: 380/495',
                        style: TextStyle(
                          color: Color(0xFF85F8C4),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    value: .42,
                    color: Color(0xFF85F8C4),
                    backgroundColor: Color(0x554AC08F),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Hoàn thành 42% lộ trình',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.tune),
                hintText: 'Tìm kiếm tên đề, part thi hoặc mã đề...',
              ),
            ),
            Wrap(
              spacing: 7,
              children:
                  ['Tất cả đề (8)', 'Đề Full 100 câu (5)', 'Luyện Part 7 (3)']
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item),
                          selected: _filter == item,
                          onSelected: (_) => setState(() => _filter = item),
                        ),
                      )
                      .toList(),
            ),
            const Row(
              children: [
                Icon(
                  Icons.check_box_outlined,
                  color: AppColors.secondary,
                  size: 19,
                ),
                SizedBox(width: 7),
                Text(
                  'Sẵn sàng làm bài',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Spacer(),
                Text(
                  'Sắp xếp: Mới nhất',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
            if (_publicationState.isPublished(0) &&
                _matches('TOEIC Full Reading Test 2025 - Alpha'))
              _StudentExamCard(
                title: 'TOEIC Full Reading Test 2025 - Alpha',
                status: 'Đang mở thi • Miễn phí',
                details: '100 câu hỏi  •  75 phút  •  Chuẩn Part 5, 6, 7',
                tags: const ['Reading ETS 2025', 'Có giải thích chi tiết'],
                action: 'Bắt đầu làm bài',
                onAction: _openExam,
              ),
            if (_publicationState.isPublished(1) &&
                _matches('ETS TOEIC Format Practice Test 02'))
              _StudentExamCard(
                title: 'ETS TOEIC Format Practice Test 02',
                status: 'Đang mở thi',
                details:
                    '100 câu hỏi  •  75 phút liên tục  •  Từ vựng Business',
                tags: const ['Độ khó: 750+ TOEIC'],
                action: 'Thi lại đề này',
                onAction: _openExam,
              ),
            if (_publicationState.isPublished(2) &&
                _matches('Mini Test: Chuyên đề Đọc hiểu Part 7'))
              _StudentExamCard(
                title: 'Mini Test: Chuyên đề Đọc hiểu Part 7',
                status: 'Đang mở thi',
                details: '40 câu hỏi  •  40 phút  •  Đọc hiểu 2-3 đoạn văn',
                tags: const ['Part 7 tập trung'],
                action: 'Bắt đầu làm bài',
                onAction: _openExam,
              ),
            const SurfaceCard(
              color: AppColors.surfaceMid,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mẹo nhỏ trước khi vào thi: Chuẩn bị không gian yên tĩnh và đảm bảo kết nối mạng trong 75 phút làm bài liên tục.',
                      style: TextStyle(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matches(String title) =>
      title.toLowerCase().contains(_search.text.toLowerCase()) &&
      (_filter != 'Luyện Part 7 (3)' || title.contains('Part 7'));
}

class _StudentExamCard extends StatelessWidget {
  const _StudentExamCard({
    required this.title,
    required this.status,
    required this.details,
    required this.tags,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String status;
  final String details;
  final List<String> tags;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InfoPill(
                  status,
                  icon: Icons.circle,
                  color: AppColors.successSoft,
                  textColor: AppColors.success,
                ),
              ),
              const Icon(Icons.star, color: Color(0xFFE69A00), size: 18),
              const Text(' 4.9', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            details,
            style: const TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((tag) => InfoPill(tag)).toList(),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.play_circle_outline),
              label: Text(action),
            ),
          ),
        ],
      ),
    );
  }
}
