import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/exam_ui.dart';
import 'exam_management_screen.dart';

class ExamAnalyticsScreen extends StatelessWidget {
  const ExamAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamPage(
      title: 'TOEIC Master  ·  Thống kê',
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 2,
        onSelected: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ExamManagementScreen(),
              ),
            );
          }
        },
      ),
      child: PageBody(
        children: [
          const SurfaceCard(
            color: AppColors.surfaceLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoPill(
                  'Đang kích hoạt',
                  icon: Icons.circle,
                  color: AppColors.successSoft,
                  textColor: AppColors.success,
                ),
                SizedBox(height: 10),
                Text(
                  'TOEIC Full Reading Test 2025 - Alpha',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '7 ngày qua  ·  30 ngày  ·  Tất cả',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Row(
            children: [
              _MetricCard(
                'Tổng lượt thi',
                '1,420',
                '+12% tuần trước',
                Icons.groups_outlined,
              ),
              SizedBox(width: 10),
              _MetricCard(
                'Điểm trung bình',
                '365 / 495',
                '73.7% trung bình',
                Icons.star_outline,
              ),
            ],
          ),
          const Row(
            children: [
              _MetricCard(
                'Tỷ lệ nộp bài',
                '94.2%',
                '58 bài bỏ dở giữa chừng',
                Icons.check_circle_outline,
              ),
              SizedBox(width: 10),
              _MetricCard(
                'Điểm cao nhất',
                '490 / 495',
                '3 học viên đạt top',
                Icons.emoji_events_outlined,
              ),
            ],
          ),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeading(
                  'Phân bổ điểm số',
                  subtitle: 'Tần suất thí sinh theo 5 thang điểm',
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      _ChartBar('112', '< 250', .32),
                      _ChartBar('325', '255-350', .62),
                      _ChartBar('618', '355-400', .94, active: true),
                      _ChartBar('267', '405-450', .72),
                      _ChartBar('98', '455-495', .42),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeading(
                  'Phân tích theo phần thi',
                  subtitle: '100 câu đọc',
                ),
                const SizedBox(height: 12),
                const _PartProgress(
                  'Part 5',
                  'Incomplete Sentences',
                  '26/30',
                  .78,
                ),
                const _PartProgress('Part 6', 'Text Completion', '12/16', .72),
                const _PartProgress(
                  'Part 7',
                  'Reading Comprehension',
                  '45/54',
                  .61,
                  warning: true,
                ),
              ],
            ),
          ),
          const ScreenHeading('Top câu hỏi sai nhiều nhất'),
          for (final question in const [
            ('142', 'Part 6 (Text Completion)', '68.4%', 'having conducted'),
            (
              '187',
              'Part 7 (Triple Passage)',
              '64.1%',
              'To request a reimbursement',
            ),
            ('124', 'Part 5 (Incomplete Sentence)', '59.8%', 'in light of'),
            ('165', 'Part 7 (Single Passage)', '55.2%', 'contextual meaning'),
          ])
            SurfaceCard(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.surfaceMid,
                    foregroundColor: AppColors.primary,
                    child: Text(
                      '#${question.$1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Câu ${question.$1} • ${question.$2}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Đáp án đúng: ${question.$4}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    question.$3,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          FilledButton.icon(
            onPressed: () => showAppMessage(
              context,
              'Báo cáo PDF/Excel sẽ được kết nối ở bước tiếp theo.',
            ),
            icon: const Icon(Icons.download_outlined),
            label: const Text('Xuất báo cáo PDF / Excel'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.label, this.value, this.note, this.icon);

  final String label;
  final String value;
  final String note;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SurfaceCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
                Icon(icon, color: AppColors.secondary, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar(this.count, this.label, this.fraction, {this.active = false});

  final String count;
  final String label;
  final double fraction;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(fontSize: 10, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 100,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 100 * fraction,
                  decoration: BoxDecoration(
                    color: active ? AppColors.secondary : AppColors.surfaceHigh,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(7),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartProgress extends StatelessWidget {
  const _PartProgress(
    this.part,
    this.name,
    this.score,
    this.value, {
    this.warning = false,
  });

  final String part;
  final String name;
  final String score;
  final double value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              InfoPill(part),
              const SizedBox(width: 8),
              Expanded(child: Text(name)),
              Text(
                '$score  ${(value * 100).round()}%',
                style: TextStyle(
                  color: warning ? AppColors.error : AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: value,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: AppColors.surfaceHigh,
            color: warning ? AppColors.error : AppColors.secondary,
          ),
        ],
      ),
    );
  }
}
