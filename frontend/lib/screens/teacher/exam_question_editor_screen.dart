import 'package:flutter/material.dart';

import '../../services/exam_api_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/exam_ui.dart';

class ExamQuestionEditorScreen extends StatefulWidget {
  const ExamQuestionEditorScreen({
    required this.client,
    required this.exam,
    super.key,
  });

  final ExamApiClient client;
  final ManagedExam exam;

  @override
  State<ExamQuestionEditorScreen> createState() =>
      _ExamQuestionEditorScreenState();
}

class _ExamQuestionEditorScreenState extends State<ExamQuestionEditorScreen> {
  final _promptController = TextEditingController();
  final _choiceControllers = {
    for (final choice in const ['A', 'B', 'C', 'D'])
      choice: TextEditingController(),
  };
  List<EditableExamQuestion> _questions = [];
  var _questionIndex = 0;
  var _loading = true;
  var _saving = false;
  String? _error;

  EditableExamQuestion? get _currentQuestion =>
      _questions.isEmpty ? null : _questions[_questionIndex];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _promptController.dispose();
    for (final controller in _choiceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await widget.client.getQuestions(widget.exam.id);
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _loading = false;
      });
      _loadCurrentQuestion();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _loadCurrentQuestion() {
    final question = _currentQuestion;
    if (question == null) return;
    _promptController.text = question.prompt;
    for (final choice in const ['A', 'B', 'C', 'D']) {
      _choiceControllers[choice]!.text = question.choices[choice] ?? '';
    }
  }

  void _storeCurrentQuestion() {
    final question = _currentQuestion;
    if (question == null) return;
    question.prompt = _promptController.text.trim();
    question.choices = {
      for (final choice in const ['A', 'B', 'C', 'D'])
        choice: _choiceControllers[choice]!.text.trim(),
    };
  }

  void _selectQuestion(int index) {
    _storeCurrentQuestion();
    setState(() => _questionIndex = index);
    _loadCurrentQuestion();
  }

  Future<void> _save() async {
    _storeCurrentQuestion();
    final invalidIndex = _questions.indexWhere(
      (question) =>
          question.prompt.trim().isEmpty ||
          const ['A', 'B', 'C', 'D'].any(
            (choice) => question.choices[choice]?.trim().isNotEmpty != true,
          ) ||
          !const ['A', 'B', 'C', 'D'].contains(question.correctAnswer),
    );
    if (invalidIndex >= 0) {
      final invalidQuestion = _questions[invalidIndex];
      setState(() {
        _questionIndex = invalidIndex;
        _error =
            'Câu ${invalidQuestion.number}: hãy nhập nội dung và đủ 4 lựa chọn.';
      });
      _loadCurrentQuestion();
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.client.updateQuestions(widget.exam.id, _questions);
      if (!mounted) return;
      showAppMessage(
        context,
        'Đã cập nhật đề. Lượt thi mới sẽ dùng nội dung này.',
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    return ExamPage(
      title: 'Chỉnh sửa câu hỏi',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _questions.isEmpty
          ? PageBody(
              children: [
                SurfaceCard(
                  color: AppColors.errorSoft,
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Quay lại'),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: PageBody(
                    children: [
                      ScreenHeading(
                        widget.exam.title,
                        subtitle: 'Chỉnh sửa câu hỏi, lựa chọn và đáp án đúng. Các lượt thi cũ giữ nguyên phiên bản.',
                      ),
                      SurfaceCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.help_outline,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('Đang sửa câu')),
                            DropdownButton<int>(
                              value: _questionIndex,
                              items: [
                                for (
                                  var index = 0;
                                  index < _questions.length;
                                  index++
                                )
                                  DropdownMenuItem(
                                    value: index,
                                    child: Text(
                                      '${_questions[index].number} (${index + 1}/100)',
                                    ),
                                  ),
                              ],
                              onChanged: _saving
                                  ? null
                                  : (index) {
                                      if (index != null) _selectQuestion(index);
                                    },
                            ),
                          ],
                        ),
                      ),
                      if (_error != null)
                        SurfaceCard(
                          color: AppColors.errorSoft,
                          child: Text(
                            _error!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      if (question != null) ...[
                        SurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Câu ${question.number} · Nội dung câu hỏi',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _promptController,
                                minLines: 3,
                                maxLines: 8,
                                maxLength: 10000,
                                decoration: const InputDecoration(
                                  hintText: 'Nhập nội dung câu hỏi',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lựa chọn và đáp án đúng',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),
                              for (final choice in const ['A', 'B', 'C', 'D'])
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: ChoiceChip(
                                          label: Text(choice),
                                          selected:
                                              question.correctAnswer == choice,
                                          onSelected: _saving
                                              ? null
                                              : (_) => setState(
                                                  () => question.correctAnswer =
                                                      choice,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              _choiceControllers[choice],
                                          minLines: 1,
                                          maxLines: 4,
                                          maxLength: 4000,
                                          decoration: InputDecoration(
                                            labelText: 'Lựa chọn $choice',
                                            counterText: '',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const Text(
                                'Chọn chữ cái của đáp án đúng bằng nút A, B, C hoặc D.',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _saving || _questionIndex == 0
                            ? null
                            : () => _selectQuestion(_questionIndex - 1),
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Trước'),
                      ),
                      const Spacer(),
                      Text(
                        _questions.isEmpty
                            ? '0 / 100'
                            : '${_questionIndex + 1} / ${_questions.length}',
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed:
                            _saving || _questionIndex >= _questions.length - 1
                            ? null
                            : () => _selectQuestion(_questionIndex + 1),
                        icon: const Icon(Icons.chevron_right),
                        label: const Text('Tiếp'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _saving || _questions.isEmpty ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(_saving ? 'Đang lưu' : 'Lưu đề'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
