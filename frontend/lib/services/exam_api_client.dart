import 'dart:convert';

import 'package:http/http.dart' as http;

const _defaultExamApiBaseUrl = 'http://localhost:52689';

class ExamApiException implements Exception {
  const ExamApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ManagedExam {
  const ManagedExam({
    required this.id,
    required this.title,
    required this.questionCount,
    required this.durationMinutes,
    required this.isPublished,
  });

  final int id;
  final String title;
  final int questionCount;
  final int durationMinutes;
  final bool isPublished;

  factory ManagedExam.fromJson(Map<String, dynamic> json) {
    return ManagedExam(
      id: ExamApiClient._readInt(json, 'id'),
      title: ExamApiClient._readString(json, 'title'),
      questionCount: ExamApiClient._readInt(json, 'questionCount'),
      durationMinutes: ExamApiClient._readInt(json, 'durationMinutes'),
      isPublished: json['isPublished'] == true,
    );
  }
}

class EditableExamQuestion {
  EditableExamQuestion({
    required this.number,
    required this.prompt,
    required this.choices,
    required this.correctAnswer,
  });

  final int number;
  String prompt;
  Map<String, String> choices;
  String correctAnswer;

  Map<String, Object> toJson() => {
    'number': number,
    'prompt': prompt,
    'choices': choices,
    'correctAnswer': correctAnswer,
  };
}

class ExamApiClient {
  ExamApiClient({
    required this._accessToken,
    String? baseUrl,
    http.Client? transport,
  }) : _baseUrl =
           (baseUrl ??
                   const String.fromEnvironment(
                     'EXAM_API_BASE_URL',
                     defaultValue: _defaultExamApiBaseUrl,
                   ))
               .replaceFirst(RegExp(r'/+$'), ''),
       _transport = transport ?? http.Client();

  final String _accessToken;
  final String _baseUrl;
  final http.Client _transport;

  static Future<ExamApiClient> authenticate({
    required String username,
    required String password,
    String? baseUrl,
    http.Client? transport,
  }) async {
    final apiBaseUrl =
        (baseUrl ??
                const String.fromEnvironment(
                  'EXAM_API_BASE_URL',
                  defaultValue: _defaultExamApiBaseUrl,
                ))
            .replaceFirst(RegExp(r'/+$'), '');
    final client = transport ?? http.Client();
    final response = await client
        .post(
          Uri.parse('$apiBaseUrl/api/TokenAuth/Authenticate'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userNameOrEmailAddress': username,
            'password': password,
            'rememberClient': false,
          }),
        )
        .timeout(const Duration(seconds: 30));
    final result = _readResult(response);
    final accessToken = result['accessToken'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const ExamApiException('Backend không trả về JWT hợp lệ.');
    }
    return ExamApiClient(
      accessToken: accessToken,
      baseUrl: apiBaseUrl,
      transport: client,
    );
  }

  Future<List<ManagedExam>> getManagedExams() async {
    final result = await _get('/api/services/app/Exam/GetManagedExams');
    final exams = result['exams'];
    if (exams is! List) {
      throw const ExamApiException(
        'Dữ liệu danh sách đề thi từ backend không hợp lệ.',
      );
    }
    return exams
        .whereType<Map>()
        .map((exam) => ManagedExam.fromJson(Map<String, dynamic>.from(exam)))
        .toList();
  }

  Future<List<EditableExamQuestion>> getQuestions(int examId) async {
    final result = await _get('/api/services/app/Exam/Preview?examId=$examId');
    final parts = result['parts'];
    if (parts is! List) {
      throw const ExamApiException(
        'Backend không trả về cấu trúc câu hỏi hợp lệ.',
      );
    }

    final questions = <EditableExamQuestion>[];
    for (final rawPart in parts.whereType<Map>()) {
      final part = Map<String, dynamic>.from(rawPart);
      final directQuestions = part['questions'];
      if (directQuestions is List) {
        questions.addAll(_parseQuestions(directQuestions));
      }
      final passages = part['passages'];
      if (passages is List) {
        for (final rawPassage in passages.whereType<Map>()) {
          final passage = Map<String, dynamic>.from(rawPassage);
          final passageQuestions = passage['questions'];
          if (passageQuestions is List) {
            questions.addAll(_parseQuestions(passageQuestions));
          }
        }
      }
    }
    questions.sort((left, right) => left.number.compareTo(right.number));
    if (questions.length != 100) {
      throw ExamApiException(
        'Đề thi có ${questions.length} câu; cần đúng 100 câu để mở trình chỉnh sửa.',
      );
    }
    return questions;
  }

  Future<void> updateQuestions(
    int examId,
    List<EditableExamQuestion> questions,
  ) async {
    await _request(
      'POST',
      '/api/services/app/Exam/UpdateQuestions',
      body: {
        'examId': examId,
        'questions': questions.map((question) => question.toJson()).toList(),
      },
    );
  }

  Future<Map<String, dynamic>> _get(String path) async {
    return _request('GET', path);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, Object>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };
    final response = switch (method) {
      'GET' =>
        await _transport
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 30)),
      'POST' =>
        await _transport
            .post(uri, headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 30)),
      _ => throw ArgumentError.value(
        method,
        'method',
        'Unsupported HTTP method',
      ),
    };
    return _readResult(response);
  }

  static Map<String, dynamic> _readResult(http.Response response) {
    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Expected a JSON object.');
      }
      payload = Map<String, dynamic>.from(decoded);
    } on FormatException {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ExamApiException(
          'Backend trả về lỗi HTTP ${response.statusCode}.',
        );
      }
      throw const ExamApiException('Backend trả về JSON không hợp lệ.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = payload['error'];
      final message = error is Map ? error['message'] : null;
      throw ExamApiException(
        message is String && message.isNotEmpty
            ? message
            : 'Yêu cầu thất bại với HTTP ${response.statusCode}.',
      );
    }

    if (payload['success'] == false) {
      final error = payload['error'];
      final message = error is Map ? error['message'] : null;
      throw ExamApiException(
        message is String && message.isNotEmpty
            ? message
            : 'Backend từ chối yêu cầu.',
      );
    }

    final result = payload['result'];
    return result is Map ? Map<String, dynamic>.from(result) : payload;
  }

  static List<EditableExamQuestion> _parseQuestions(List rawQuestions) {
    return rawQuestions.whereType<Map>().map((rawQuestion) {
      final question = Map<String, dynamic>.from(rawQuestion);
      final rawChoices = question['choices'];
      if (rawChoices is! Map) {
        throw const ExamApiException('Một câu hỏi thiếu danh sách lựa chọn.');
      }
      return EditableExamQuestion(
        number: _readInt(question, 'number'),
        prompt: _readString(question, 'prompt'),
        choices: rawChoices.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ),
        correctAnswer: _readString(question, 'correctAnswer'),
      );
    }).toList();
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw ExamApiException('Dữ liệu backend thiếu trường số "$key".');
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw ExamApiException('Dữ liệu backend thiếu trường "$key".');
  }
}
