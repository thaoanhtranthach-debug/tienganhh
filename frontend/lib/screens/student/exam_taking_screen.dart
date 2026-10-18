import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/exam_ui.dart';
import 'exam_result_screen.dart';

class ExamTakingScreen extends StatefulWidget {
  const ExamTakingScreen({super.key});

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  static const _duration = Duration(minutes: 75);
  static const _questions = [
    _Question(
      153,
      7,
      'What is indicated about Ms. Sarah Jenkins?',
      'To: Sarah Jenkins <s.jenkins@apexlogistics.com>\nFrom: Daniel Vance, Operations Lead\nDate: October 24, 2024\nSubject: Revised Dispatch Protocol & Billing Statement\n\nDear Ms. Jenkins,\n\nThank you for expediting the cargo. Your suggested upgrade to the warehouse tracking scanners has been prioritized for immediate rollout.',
      [
        'She recently transferred from the dispatch warehouse division.',
        'She submitted an inventory document ahead of the deadline.',
        'Her proposal regarding facility equipment was accepted.',
        'She will authorize the vendor payments by tomorrow noon.',
      ],
    ),
    _Question(
      154,
      7,
      'What will the operations team do next?',
      'The revised dispatch protocol will take effect at the beginning of next month.',
      [
        'Relocate the distribution center.',
        'Install the upgraded tracking scanners.',
        'Cancel the current vendor contract.',
        'Hire additional warehouse staff.',
      ],
    ),
    _Question(
      155,
      7,
      'What does the word “expediting” most nearly mean?',
      'The shipment arrived ahead of the originally expected delivery date.',
      ['Delaying', 'Inspecting', 'Speeding up', 'Repacking'],
    ),
  ];

  final Map<int, int> _answers = {};
  final Set<int> _flagged = {};
  late Duration _remaining;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _remaining = _duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 1) {
        _timer?.cancel();
        setState(() {
          _remaining = Duration.zero;
        });
        _submit(expired: true);
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '${_remaining.inHours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }

  Future<void> _confirmSubmit() async {
    final unanswered = _questions.length - _answers.length;
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận nộp bài thi?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TOEIC Full Reading Test 2025'),
            const SizedBox(height: 16),
            Text('Đã làm: ${_answers.length} câu'),
            Text(
              'Chưa chọn: $unanswered câu',
              style: TextStyle(
                color: unanswered > 0 ? AppColors.error : AppColors.success,
              ),
            ),
            Text('Đã gắn cờ: ${_flagged.length} câu'),
            const SizedBox(height: 14),
            Text('Thời gian còn lại: $_timeLabel'),
            if (unanswered > 0)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Bạn vẫn còn câu chưa trả lời. Bạn có chắc muốn nộp?',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiếp tục làm bài'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nộp bài ngay'),
          ),
        ],
      ),
    );
    if (shouldSubmit == true) _submit();
  }

  void _submit({bool expired = false}) {
    _timer?.cancel();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ExamResultScreen(
          answeredCount: _answers.length,
          totalQuestions: _questions.length,
        ),
      ),
    );
    if (expired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAppMessage(context, 'Đã hết giờ. Bài thi được tự động nộp.');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];
    final isLowTime = _remaining.inMinutes < 5;
    return ExamPage(
      title: 'Phòng Thi TOEIC',
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isLowTime ? AppColors.errorSoft : AppColors.surfaceMid,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _timeLabel,
            style: TextStyle(
              fontFeatures: const [],
              fontWeight: FontWeight.w800,
              color: isLowTime ? AppColors.error : AppColors.primary,
            ),
          ),
        ),
        TextButton(onPressed: _confirmSubmit, child: const Text('Nộp bài')),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Câu ${question.number} / 200',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      '${_answers.length} đã làm',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                LinearProgressIndicator(
                  value: _answers.length / 100,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: AppColors.surfaceHigh,
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(12, (index) {
                final number = 147 + index;
                final active = number == question.number;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text('$number'),
                    avatar: _flagged.contains(number)
                        ? const Icon(Icons.flag, size: 14)
                        : null,
                    backgroundColor: active
                        ? AppColors.primary
                        : AppColors.surfaceLow,
                    labelStyle: TextStyle(
                      color: active ? Colors.white : AppColors.text,
                    ),
                    onPressed: () {
                      final target = _questions.indexWhere(
                        (item) => item.number == number,
                      );
                      if (target >= 0) setState(() => _index = target);
                    },
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageBody(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
              children: [
                SurfaceCard(
                  color: AppColors.surfaceLow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoPill(
                        'Part ${question.part} • Đoạn đọc',
                        icon: Icons.menu_book_outlined,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question.passage,
                        style: const TextStyle(height: 1.7),
                      ),
                    ],
                  ),
                ),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InfoPill('Câu ${question.number}'),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Đánh dấu để xem lại',
                            onPressed: () => setState(() {
                              if (!_flagged.add(question.number)) {
                                _flagged.remove(question.number);
                              }
                            }),
                            icon: Icon(
                              _flagged.contains(question.number)
                                  ? Icons.flag
                                  : Icons.flag_outlined,
                              color: _flagged.contains(question.number)
                                  ? AppColors.warning
                                  : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        question.prompt,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (
                        var choice = 0;
                        choice < question.choices.length;
                        choice++
                      )
                        _AnswerChoice(
                          label: String.fromCharCode(65 + choice),
                          text: question.choices[choice],
                          selected: _answers[question.number] == choice,
                          onTap: () => setState(
                            () => _answers[question.number] = choice,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _index == 0
                        ? null
                        : () => setState(() => _index--),
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Câu trước'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _index == _questions.length - 1
                        ? _confirmSubmit
                        : () => setState(() => _index++),
                    icon: Icon(
                      _index == _questions.length - 1
                          ? Icons.check
                          : Icons.chevron_right,
                    ),
                    label: Text(
                      _index == _questions.length - 1 ? 'Kết thúc' : 'Câu sau',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerChoice extends StatelessWidget {
  const _AnswerChoice({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFDCE1FF) : AppColors.surfaceLow,
        border: Border.all(
          color: selected ? AppColors.secondary : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: selected
                    ? AppColors.secondary
                    : AppColors.surfaceHigh,
                foregroundColor: selected ? Colors.white : AppColors.primary,
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
              if (selected)
                const Icon(Icons.check_circle, color: AppColors.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _Question {
  const _Question(
    this.number,
    this.part,
    this.prompt,
    this.passage,
    this.choices,
  );

  final int number;
  final int part;
  final String prompt;
  final String passage;
  final List<String> choices;
}
