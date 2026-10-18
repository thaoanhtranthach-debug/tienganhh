using Abp.UI;
using giuaki.Exams.Dto;
using System.Collections.Generic;
using System.Linq;

namespace giuaki.Exams;

internal static class ExamQuestionEditor
{
    private const int ExpectedQuestionCount = 100;
    private static readonly string[] ChoiceIds = { "A", "B", "C", "D" };

    public static void Apply(ExamContentDto content, IReadOnlyCollection<ExamQuestionEditDto> edits)
    {
        if (content?.Parts == null)
        {
            throw new UserFriendlyException("Cấu trúc đề hiện tại không hợp lệ; không thể cập nhật câu hỏi.");
        }

        if (edits == null ||
            edits.Count != ExpectedQuestionCount ||
            edits.Any(edit => edit == null) ||
            edits.Select(edit => edit.Number).Distinct().Count() != ExpectedQuestionCount)
        {
            throw new UserFriendlyException("Cần gửi đủ 100 câu hỏi, không được trùng số câu.");
        }

        foreach (var edit in edits)
        {
            if (edit.Number < 101 || edit.Number > 200)
            {
                throw new UserFriendlyException("Số câu hỏi phải nằm trong khoảng 101–200.");
            }

            if (string.IsNullOrWhiteSpace(edit.Prompt) || edit.Prompt.Length > 10_000)
            {
                throw new UserFriendlyException($"Câu {edit.Number}: nội dung câu hỏi bắt buộc và tối đa 10.000 ký tự.");
            }

            if (edit.Choices == null ||
                edit.Choices.Count != ChoiceIds.Length ||
                ChoiceIds.Any(choiceId =>
                    !edit.Choices.TryGetValue(choiceId, out var text) ||
                    string.IsNullOrWhiteSpace(text) ||
                    text.Length > 4_000))
            {
                throw new UserFriendlyException($"Câu {edit.Number}: cần đủ lựa chọn A, B, C, D; mỗi lựa chọn tối đa 4.000 ký tự.");
            }

            if (!ChoiceIds.Contains(edit.CorrectAnswer, System.StringComparer.Ordinal))
            {
                throw new UserFriendlyException($"Câu {edit.Number}: đáp án đúng phải là A, B, C hoặc D.");
            }
        }

        var currentQuestions = new List<ExamQuestionDto>();
        foreach (var part in content.Parts)
        {
            if (part == null)
            {
                throw new UserFriendlyException("Cấu trúc đề hiện tại không hợp lệ; không thể cập nhật câu hỏi.");
            }

            currentQuestions.AddRange(part.Questions ?? new List<ExamQuestionDto>());
            foreach (var passage in part.Passages ?? new List<ExamPassageDto>())
            {
                if (passage == null)
                {
                    throw new UserFriendlyException("Cấu trúc đề hiện tại không hợp lệ; không thể cập nhật câu hỏi.");
                }

                currentQuestions.AddRange(passage.Questions ?? new List<ExamQuestionDto>());
            }
        }

        if (currentQuestions.Count != ExpectedQuestionCount ||
            currentQuestions.Any(question => question == null) ||
            currentQuestions.Select(question => question.Number).Distinct().Count() != ExpectedQuestionCount)
        {
            throw new UserFriendlyException("Cấu trúc đề hiện tại không hợp lệ; không thể cập nhật câu hỏi.");
        }

        var editsByNumber = edits.ToDictionary(edit => edit.Number);
        var currentByNumber = currentQuestions.ToDictionary(question => question.Number);
        if (currentByNumber.Keys.Any(number => !editsByNumber.ContainsKey(number)))
        {
            throw new UserFriendlyException("Cấu trúc đề hiện tại không khớp danh sách câu hỏi cần cập nhật.");
        }

        foreach (var edit in edits)
        {
            var question = currentByNumber[edit.Number];
            question.Prompt = edit.Prompt.Trim();
            question.Choices = new Dictionary<string, string>(
                edit.Choices,
                System.StringComparer.Ordinal);
            question.CorrectAnswer = edit.CorrectAnswer;
        }
    }
}
