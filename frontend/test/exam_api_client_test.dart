import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:toeic_reading_platform/services/exam_api_client.dart';

void main() {
  test(
    'authenticates and sends all question edits to the protected endpoint',
    () async {
      final requests = <http.Request>[];
      final transport = MockClient((baseRequest) async {
        final request = baseRequest;
        requests.add(request);
        if (request.url.path == '/api/TokenAuth/Authenticate') {
          return http.Response(
            jsonEncode({
              'result': {'accessToken': 'test-jwt'},
              'success': true,
            }),
            200,
          );
        }
        if (request.url.path == '/api/services/app/Exam/GetManagedExams') {
          return http.Response(
            jsonEncode({
              'result': {
                'exams': [
                  {
                    'id': 12,
                    'title': 'Reading exam',
                    'questionCount': 100,
                    'durationMinutes': 75,
                    'isPublished': true,
                  },
                ],
              },
              'success': true,
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({'result': null, 'success': true}),
          200,
        );
      });

      final client = await ExamApiClient.authenticate(
        username: 'lecturer',
        password: 'test-password',
        baseUrl: 'http://localhost:52689/',
        transport: transport,
      );
      final exams = await client.getManagedExams();
      await client.updateQuestions(12, [
        for (var number = 101; number <= 200; number++)
          EditableExamQuestion(
            number: number,
            prompt: 'Question $number',
            choices: const {
              'A': 'Choice A',
              'B': 'Choice B',
              'C': 'Choice C',
              'D': 'Choice D',
            },
            correctAnswer: 'A',
          ),
      ]);

      expect(exams, hasLength(1));
      expect(exams.single.id, 12);
      expect(exams.single.isPublished, isTrue);
      expect(requests[1].headers['Authorization'], 'Bearer test-jwt');
      expect(requests[2].url.path, '/api/services/app/Exam/UpdateQuestions');
      final updateBody = jsonDecode(requests[2].body) as Map<String, dynamic>;
      expect(updateBody['examId'], 12);
      expect(updateBody['questions'], hasLength(100));
      transport.close();
    },
  );
}
