import 'package:flutter/material.dart';

import '../../services/exam_api_client.dart';
import '../../state/exam_publication_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/exam_ui.dart';
import 'exam_analytics_screen.dart';
import 'exam_preview_screen.dart';
import 'exam_question_editor_screen.dart';
import 'exam_upload_screen.dart';

class ExamManagementScreen extends StatefulWidget {
  const ExamManagementScreen({super.key});

  @override
  State<ExamManagementScreen> createState() => _ExamManagementScreenState();
}

class _ExamManagementScreenState extends State<ExamManagementScreen> {
  String _filter = 'Tất cả';
  final _searchController = TextEditingController();
  final _publicationState = ExamPublicationState.instance;
  ExamApiClient? _apiClient;
  List<ManagedExam>? _managedExams;
  bool _connecting = false;
  String? _connectionError;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openUpload() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ExamUploadScreen()));
  }

  Future<void> _connectToBackend() async {
    final credentials = await showDialog<({String username, String password})>(
      context: context,
      builder: (_) => const _TeacherLoginDialog(),
    );
    if (credentials == null) return;

    setState(() {
      _connecting = true;
      _connectionError = null;
    });
    try {
      final client = await ExamApiClient.authenticate(
        username: credentials.username,
        password: credentials.password,
      );
      final exams = await client.getManagedExams();
      if (!mounted) return;
      setState(() {
        _apiClient = client;
        _managedExams = exams;
        _connecting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _connectionError = error.toString();
      });
    }
  }

  Future<void> _editExam(ManagedExam exam) async {
    final client = _apiClient;
    if (client == null) {
      await _connectToBackend();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExamQuestionEditorScreen(client: client, exam: exam),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _managedExams != null;
    final exams = isConnected
        ? _managedExams!
              .map(
                (exam) => _ExamData(
                  id: exam.id,
                  title: exam.title,
                  code: '#${exam.id}',
                  questions: exam.questionCount,
                  duration: exam.durationMinutes,
                  attempts: '—',
                  isPublished: exam.isPublished,
                ),
              )
              .toList()
        : _sampleExams;
    return ExamPage(
      title: 'TOEIC Master  ·  Quản lý',
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 1,
        onSelected: (index) {
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ExamAnalyticsScreen(),
              ),
            );
          }
          if (index == 0) {
            Navigator.of(context).maybePop();
          }
        },
      ),
      child: AnimatedBuilder(
        animation: _publicationState,
        builder: (context, _) => PageBody(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: ScreenHeading(
                    'Quản lý Đề thi',
                    subtitle:
                        'Thiết lập trạng thái xuất bản và quản lý phiên thi.',
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: _openUpload,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm đề'),
                ),
              ],
            ),
            if (!isConnected)
              SurfaceCard(
                color: AppColors.surfaceMid,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Danh sách đang là dữ liệu mẫu. Đăng nhập để tải đề thật và chỉnh sửa câu hỏi.',
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _connecting ? null : _connectToBackend,
                      icon: _connecting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_sync_outlined),
                      label: Text(_connecting ? 'Đang tải' : 'Tải đề thật'),
                    ),
                  ],
                ),
              ),
            if (_connectionError != null)
              SurfaceCard(
                color: AppColors.errorSoft,
                child: Text(
                  'Không kết nối được backend: $_connectionError',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            Row(
              children: const [
                _OverviewMetric(
                  icon: Icons.article_outlined,
                  value: '12',
                  label: 'Tổng số đề',
                ),
                SizedBox(width: 10),
                _OverviewMetric(
                  icon: Icons.wifi_tethering,
                  value: '06',
                  label: 'Đang mở thi',
                ),
                SizedBox(width: 10),
                _OverviewMetric(
                  icon: Icons.people_alt_outlined,
                  value: '142',
                  label: 'SV online',
                ),
              ],
            ),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Tìm theo tên đề thi, mã đề...',
              ),
            ),
            Wrap(
              spacing: 8,
              children: ['Tất cả', 'Đã xuất bản', 'Bản nháp']
                  .map(
                    (value) => ChoiceChip(
                      label: Text(value),
                      selected: _filter == value,
                      onSelected: (_) => setState(() => _filter = value),
                    ),
                  )
                  .toList(),
            ),
            if (isConnected && exams.isEmpty)
              const SurfaceCard(
                child: Text('Backend chưa có đề thi nào được nhập.'),
              ),
            for (var index = 0; index < exams.length; index++)
              if (_matches(index, exams[index], isConnected))
                _ExamManagementCard(
                  exam: exams[index],
                  isPublished: isConnected
                      ? exams[index].isPublished ?? false
                      : _publicationState.isPublished(index),
                  canChangePublication: !isConnected,
                  onChanged: (value) =>
                      _publicationState.setPublished(index, value),
                  onTap: isConnected
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ExamPreviewScreen(),
                          ),
                        ),
                  onPublish: isConnected
                      ? null
                      : () => _publicationState.setPublished(index, true),
                  onEdit: isConnected && exams[index].isPublished == true
                      ? () => _editExam(_managedExams![index])
                      : null,
                ),
          ],
        ),
      ),
    );
  }

  bool _matches(int index, _ExamData exam, bool isConnected) {
    final published = isConnected
        ? exam.isPublished ?? false
        : _publicationState.isPublished(index);
    final filterMatches = switch (_filter) {
      'Đã xuất bản' => published,
      'Bản nháp' => !published,
      _ => true,
    };
    return filterMatches &&
        exam.title.toLowerCase().contains(_searchController.text.toLowerCase());
  }
}

class _ExamManagementCard extends StatelessWidget {
  const _ExamManagementCard({
    required this.exam,
    required this.isPublished,
    required this.onChanged,
    required this.onTap,
    required this.onPublish,
    required this.canChangePublication,
    required this.onEdit,
  });

  final _ExamData exam;
  final bool isPublished;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onPublish;
  final bool canChangePublication;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InfoPill(
                isPublished ? 'Đã xuất bản' : 'Bản nháp',
                icon: isPublished
                    ? Icons.check_circle_outline
                    : Icons.edit_note,
                color: isPublished
                    ? AppColors.successSoft
                    : AppColors.surfaceMid,
                textColor: isPublished
                    ? AppColors.success
                    : AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                exam.code,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_vert, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            exam.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${exam.questions} câu  •  ${exam.duration} phút',
                  style: const TextStyle(color: AppColors.primary),
                ),
                const SizedBox(height: 5),
                Text(
                  'Lượt thi: ${exam.attempts} lượt',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  isPublished ? 'Cho phép sinh viên vào thi' : 'Chưa xuất bản',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Switch(
                value: isPublished,
                onChanged: canChangePublication ? onChanged : null,
              ),
            ],
          ),
          if (isPublished && onEdit != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Chỉnh sửa câu hỏi'),
              ),
            ),
          ],
          if (!isPublished && onPublish != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPublish,
                icon: const Icon(Icons.publish),
                label: const Text('Xuất bản ngay'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 112,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceMid,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppColors.secondary),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamData {
  const _ExamData({
    required this.title,
    required this.code,
    required this.questions,
    required this.duration,
    required this.attempts,
    this.id,
    this.isPublished,
  });

  final int? id;
  final String title;
  final String code;
  final int questions;
  final int duration;
  final String attempts;
  final bool? isPublished;
}

class _TeacherLoginDialog extends StatefulWidget {
  const _TeacherLoginDialog();

  @override
  State<_TeacherLoginDialog> createState() => _TeacherLoginDialogState();
}

class _TeacherLoginDialogState extends State<_TeacherLoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đăng nhập giảng viên'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Tên đăng nhập hoặc email',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Bắt buộc nhập'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Bắt buộc nhập' : null,
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Đăng nhập và tải đề'),
        ),
      ],
    );
  }
}

const _sampleExams = [
  _ExamData(
    title: 'TOEIC Full Reading Test 2025 - Alpha',
    code: '#TM-2025-01',
    questions: 100,
    duration: 75,
    attempts: '1,420',
  ),
  _ExamData(
    title: 'ETS TOEIC Format Standard Test 03',
    code: '#TM-2025-03',
    questions: 100,
    duration: 75,
    attempts: '890',
  ),
  _ExamData(
    title: 'Đề rà soát kỹ năng Part 7 - Đọc hiểu nâng cao',
    code: '#TM-PART7-DRAFT',
    questions: 54,
    duration: 45,
    attempts: '0',
  ),
];
