import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/exam_ui.dart';
import 'exam_preview_screen.dart';

class ExamUploadScreen extends StatefulWidget {
  const ExamUploadScreen({super.key});

  @override
  State<ExamUploadScreen> createState() => _ExamUploadScreenState();
}

class _ExamUploadScreenState extends State<ExamUploadScreen> {
  PlatformFile? _file;

  Future<void> _chooseFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['docx'],
    );
    if (files.isEmpty || !mounted) return;
    setState(() => _file = files.first);
    final size = await _file!.length();
    if (!mounted) return;
    if (size != null && size > 8 * 1024 * 1024) {
      showAppMessage(context, 'File vượt quá giới hạn 8 MB của backend.');
    }
  }

  void _continueToPreview() {
    if (_file == null) {
      showAppMessage(context, 'Hãy chọn file Word .docx trước.');
      return;
    }
    showAppMessage(
      context,
      'Đã chọn file. Kết nối API import sẽ được bổ sung ở bước tích hợp backend.',
    );
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ExamPreviewScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ExamPage(
      title: 'Biên Soạn Đề Thi',
      child: Column(
        children: [
          Expanded(
            child: PageBody(
              children: [
                const SurfaceCard(
                  color: AppColors.primary,
                  child: Row(
                    children: [
                      Icon(Icons.school_outlined, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Không gian làm việc',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Phân hệ Giảng viên',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.swap_horiz, color: Colors.white),
                    ],
                  ),
                ),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InfoPill(
                        'TOEIC Reading (Part 5 - 7)',
                        icon: Icons.article_outlined,
                      ),
                      const SizedBox(height: 12),
                      const ScreenHeading(
                        'Tải lên đề thi mới',
                        subtitle: 'Hệ thống đọc cấu trúc câu hỏi, đáp án và định dạng văn bản.',
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => showAppMessage(
                          context,
                          'Tải mẫu DOCX từ tài liệu dự án.',
                        ),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('File mẫu (.docx)'),
                      ),
                    ],
                  ),
                ),
                SurfaceCard(
                  color: AppColors.surfaceLow,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.surfaceHigh,
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Chọn hoặc kéo thả file đề thi',
                          style: TextStyle(
                            fontSize: 17,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Microsoft Word .docx • tối đa 8 MB',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: _chooseFile,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Chọn từ máy tính'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_file != null)
                  SurfaceCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          color: AppColors.secondary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _file!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'DOCX đã chọn  •  Giới hạn 8 MB',
                                style: const TextStyle(
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _file = null),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                const SurfaceCard(
                  color: AppColors.surfaceLow,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'File sẽ được kiểm tra tag, thứ tự câu, lựa chọn và đáp án trước khi lưu.',
                          style: TextStyle(height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Hủy bỏ'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _continueToPreview,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Xem trước đề'),
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
