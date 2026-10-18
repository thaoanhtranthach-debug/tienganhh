import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/exam_ui.dart';
import 'exam_list_screen.dart';

class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({
    this.answeredCount = 88,
    this.totalQuestions = 100,
    super.key,
  });

  final int answeredCount;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final correct = (answeredCount * .94).round();
    final incorrect = answeredCount - correct;
    final skipped = totalQuestions - answeredCount;
    return ExamPage(
      title: 'Chi Tiết Kết Quả',
      child: PageBody(
        children: [
          SurfaceCard(
            color: AppColors.successSoft,
            child: Column(
              children: [
                const InfoPill(
                  'Kết quả bài thi TOEIC Reading',
                  icon: Icons.verified_outlined,
                ),
                const SizedBox(height: 12),
                const Text(
                  'TOEIC Full Reading Test 2025 - Alpha',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 132,
                  height: 132,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: .83,
                          strokeWidth: 9,
                          backgroundColor: AppColors.surfaceHigh,
                          color: AppColors.secondary,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '410',
                            style: TextStyle(
                              fontSize: 30,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '/ 495 Reading',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const InfoPill(
                  'Tăng +35 điểm',
                  icon: Icons.trending_up,
                  color: AppColors.success,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _ResultStat(
                      'Đúng',
                      '$correct',
                      Icons.check,
                      AppColors.success,
                    ),
                    const SizedBox(width: 7),
                    _ResultStat(
                      'Sai',
                      '$incorrect',
                      Icons.close,
                      AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _ResultStat(
                      'Bỏ qua',
                      '$skipped',
                      Icons.remove,
                      AppColors.muted,
                    ),
                    const SizedBox(width: 7),
                    const _ResultStat(
                      'Thời gian',
                      '62 phút',
                      Icons.timer_outlined,
                      AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeading(
                  'Phân tích kỹ năng theo Part',
                  subtitle: 'Tổng 100 câu',
                ),
                const SizedBox(height: 14),
                const _PartScore(
                  'Part 5',
                  'Incomplete Sentences',
                  '26/30',
                  .87,
                ),
                const _PartScore('Part 6', 'Text Completion', '12/16', .75),
                const _PartScore(
                  'Part 7',
                  'Reading Comprehension',
                  '45/54',
                  .83,
                ),
              ],
            ),
          ),
          const ScreenHeading('Xem lại đáp án chi tiết'),
          const _ReviewItem(
            number: 142,
            part: 'Part 6 • Đoạn văn',
            prompt: 'The research department completed its quarterly performance survey last Friday. [142] _____ the survey among 450 remote employees.',
            selected: 'had conducted',
            correct: 'having conducted',
          ),
          const _ReviewItem(
            number: 154,
            part: 'Part 7 • Đọc hiểu đoạn đơn',
            prompt: 'What qualification is explicitly required for the Senior Systems Architect position?',
            selected: 'More than 5 years of experience',
            correct: 'A minimum of five consecutive years',
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const ExamListScreen()),
              (route) => false,
            ),
            icon: const Icon(Icons.replay),
            label: const Text('Quay lại danh sách đề thi'),
          ),
          OutlinedButton.icon(
            onPressed: () => showAppMessage(
              context,
              'Tải bảng điểm PDF sẽ được bổ sung sau.',
            ),
            icon: const Icon(Icons.download_outlined),
            label: const Text('Tải bảng điểm & phân tích chi tiết (PDF)'),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartScore extends StatelessWidget {
  const _PartScore(this.part, this.label, this.score, this.progress);

  final String part;
  final String label;
  final String score;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Text(part, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
              Text(
                score,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: AppColors.surfaceHigh,
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.number,
    required this.part,
    required this.prompt,
    required this.selected,
    required this.correct,
  });

  final int number;
  final String part;
  final String prompt;
  final String selected;
  final String correct;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InfoPill('Câu $number'),
              const SizedBox(width: 7),
              Expanded(child: Text(part, style: const TextStyle(fontSize: 12))),
              const InfoPill(
                'Xem lại',
                color: AppColors.errorSoft,
                textColor: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(prompt, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 10),
          InfoPill(
            'Bạn chọn: $selected',
            color: AppColors.errorSoft,
            textColor: AppColors.error,
          ),
          const SizedBox(height: 7),
          InfoPill(
            'Đáp án đúng: $correct',
            icon: Icons.check_circle,
            color: AppColors.successSoft,
            textColor: AppColors.success,
          ),
          const SizedBox(height: 10),
          const Text(
            'Giải thích: Xem xét ngữ cảnh của đoạn văn để chọn đáp án phù hợp nhất.',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
