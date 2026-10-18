import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/exam_ui.dart';

class ExamPreviewScreen extends StatefulWidget {
  const ExamPreviewScreen({super.key});

  @override
  State<ExamPreviewScreen> createState() => _ExamPreviewScreenState();
}

class _ExamPreviewScreenState extends State<ExamPreviewScreen> {
  var _questionIndex = 0;
  var _showAnswers = true;

  final _questions = [
    _PreviewQuestion(
      number: 153,
      part: 7,
      prompt: 'What is indicated about Ms. Sarah Jenkins?',
      passage: 'To: Sarah Jenkins <s.jenkins@apexlogistics.com>\nFrom: Daniel Vance, Operations Lead\nSubject: Revised Dispatch Protocol & Billing Statement\n\nDear Ms. Jenkins,\n\nThank you for expediting the cargo. Your suggested upgrade to the warehouse tracking scanners has been prioritized for immediate rollout.',
      choices: [
        'She recently transferred to the dispatch warehouse division.',
        'She submitted an inventory document ahead of the deadline.',
        'Her proposal regarding facility equipment was accepted.',
        'She will authorize the vendor payments tomorrow.',
      ],
      answer: 2,
    ),
    _PreviewQuestion(
      number: 154,
      part: 7,
      prompt: 'What will the operations team do next?',
      passage: 'The new tracking equipment will be installed at the distribution center next month.',
      choices: [
        'Relocate the distribution center.',
        'Begin installing the new scanners.',
        'Cancel the current vendor contract.',
        'Hire additional warehouse staff.',
      ],
      answer: 1,
    ),
  ];

  Future<void> _editCurrentQuestion(_PreviewQuestion question) async {
    final edit = await showDialog<_PreviewQuestionEdit>(
      context: context,
      builder: (_) => _PreviewQuestionEditDialog(question: question),
    );
    if (!mounted || edit == null) return;

    setState(() {
      question.prompt = edit.prompt;
      question.choices = edit.choices;
      question.answer = edit.answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_questionIndex];
    return ExamPage(
      title: 'Xem trước & rà soát đề',
      actions: [
        Switch(
          value: _showAnswers,
          onChanged: (value) => setState(() => _showAnswers = value),
        ),
      ],
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const InfoPill('100 câu • Đang thẩm định'),
                const SizedBox(width: 8),
                for (final part in [
                  'Tất cả (100)',
                  'Part 5',
                  'Part 6',
                  'Part 7',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(part),
                      selected: part == 'Part ${question.part}',
                      onSelected: (_) {},
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: PageBody(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
              children: [
                SurfaceCard(
                  color: AppColors.surfaceLow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoPill(
                        'Đoạn văn đọc hiểu (Câu 153 - 155)',
                        icon: Icons.description_outlined,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question.passage,
                        style: const TextStyle(height: 1.65),
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
                          InfoPill(
                            'Câu ${question.number} • Part ${question.part}',
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => showAppMessage(
                              context,
                              'Đánh dấu câu cần rà soát.',
                            ),
                            icon: const Icon(Icons.flag_outlined),
                          ),
                          TextButton.icon(
                            onPressed: () => _editCurrentQuestion(question),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Chỉnh sửa câu'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.prompt,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (
                        var index = 0;
                        index < question.choices.length;
                        index++
                      )
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _showAnswers && index == question.answer
                                ? const Color(0xFFE0F8EE)
                                : AppColors.surfaceLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor:
                                    _showAnswers && index == question.answer
                                    ? AppColors.success
                                    : AppColors.surfaceHigh,
                                foregroundColor:
                                    _showAnswers && index == question.answer
                                    ? Colors.white
                                    : AppColors.primary,
                                child: Text(String.fromCharCode(65 + index)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(question.choices[index])),
                              if (_showAnswers && index == question.answer)
                                const Icon(
                                  Icons.verified,
                                  color: AppColors.success,
                                ),
                            ],
                          ),
                        ),
                      if (_showAnswers)
                        const InfoPill(
                          'Đáp án đúng được hiển thị cho giảng viên',
                          icon: Icons.check_circle,
                          color: AppColors.successSoft,
                          textColor: AppColors.success,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _questionIndex == 0
                      ? null
                      : () => setState(() => _questionIndex--),
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Trước'),
                ),
                const Spacer(),
                Text('${_questionIndex + 1} / 100 đã duyệt'),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _questionIndex == _questions.length - 1
                      ? () => showAppMessage(
                          context,
                          'Đề đã sẵn sàng để xuất bản.',
                        )
                      : () => setState(() => _questionIndex++),
                  icon: const Icon(Icons.chevron_right),
                  label: Text(
                    _questionIndex == _questions.length - 1
                        ? 'Phê duyệt'
                        : 'Câu sau',
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

class _PreviewQuestion {
  _PreviewQuestion({
    required this.number,
    required this.part,
    required this.prompt,
    required this.passage,
    required this.choices,
    required this.answer,
  });

  final int number;
  final int part;
  String prompt;
  final String passage;
  List<String> choices;
  int answer;
}

class _PreviewQuestionEdit {
  const _PreviewQuestionEdit({
    required this.prompt,
    required this.choices,
    required this.answer,
  });

  final String prompt;
  final List<String> choices;
  final int answer;
}

class _PreviewQuestionEditDialog extends StatefulWidget {
  const _PreviewQuestionEditDialog({required this.question});

  final _PreviewQuestion question;

  @override
  State<_PreviewQuestionEditDialog> createState() =>
      _PreviewQuestionEditDialogState();
}

class _PreviewQuestionEditDialogState
    extends State<_PreviewQuestionEditDialog> {
  late final TextEditingController _promptController;
  late final List<TextEditingController> _choiceControllers;
  late int _answer;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: widget.question.prompt);
    _choiceControllers = [
      for (final choice in widget.question.choices)
        TextEditingController(text: choice),
    ];
    _answer = widget.question.answer;
  }

  @override
  void dispose() {
    _promptController.dispose();
    for (final controller in _choiceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    final prompt = _promptController.text.trim();
    final choices = [
      for (final controller in _choiceControllers) controller.text.trim(),
    ];
    if (prompt.isEmpty || choices.any((choice) => choice.isEmpty)) {
      setState(
        () => _validationMessage = 'Nhập nội dung câu hỏi và đủ 4 lựa chọn.',
      );
      return;
    }

    Navigator.of(context).pop(
      _PreviewQuestionEdit(prompt: prompt, choices: choices, answer: _answer),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Chỉnh sửa câu ${widget.question.number}'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const Key('preview-question-prompt'),
                controller: _promptController,
                minLines: 2,
                maxLines: 5,
                maxLength: 10000,
                decoration: const InputDecoration(
                  labelText: 'Nội dung câu hỏi',
                  alignLabelWithHint: true,
                ),
              ),
              for (var index = 0; index < _choiceControllers.length; index++)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    key: Key('preview-question-choice-$index'),
                    controller: _choiceControllers[index],
                    maxLines: 3,
                    maxLength: 4000,
                    decoration: InputDecoration(
                      labelText: 'Lựa chọn ${String.fromCharCode(65 + index)}',
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: const Key('preview-question-answer'),
                initialValue: _answer,
                decoration: const InputDecoration(labelText: 'Đáp án đúng'),
                items: [
                  for (
                    var index = 0;
                    index < _choiceControllers.length;
                    index++
                  )
                    DropdownMenuItem(
                      value: index,
                      child: Text(
                        'Lựa chọn ${String.fromCharCode(65 + index)}',
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _answer = value);
                },
              ),
              if (_validationMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _validationMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Lưu thay đổi'),
        ),
      ],
    );
  }
}
