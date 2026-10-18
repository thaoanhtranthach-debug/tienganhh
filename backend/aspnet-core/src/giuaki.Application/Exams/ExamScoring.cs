using giuaki.Exams.Dto;
using System;
using System.Collections.Generic;
using System.Linq;

namespace giuaki.Exams;

internal sealed class ExamScore
{
    public int CorrectCount { get; init; }

    public int IncorrectCount { get; init; }

    public int SkippedCount { get; init; }

    public decimal ScorePercent { get; init; }
}

internal static class ExamScoring
{
    public static ExamScore Calculate(
        ExamContentDto content,
        IReadOnlyDictionary<int, string> answers)
    {
        var questions = content.Parts
            .SelectMany(part => part.Questions.Concat(
                part.Passages.SelectMany(passage => passage.Questions)))
            .ToList();
        var correctCount = questions.Count(question =>
            answers.TryGetValue(question.Number, out var selected) &&
            string.Equals(selected, question.CorrectAnswer, StringComparison.Ordinal));
        var incorrectCount = questions.Count(question =>
            answers.TryGetValue(question.Number, out var selected) &&
            !string.Equals(selected, question.CorrectAnswer, StringComparison.Ordinal));

        return new ExamScore
        {
            CorrectCount = correctCount,
            IncorrectCount = incorrectCount,
            SkippedCount = questions.Count - correctCount - incorrectCount,
            ScorePercent = questions.Count == 0
                ? 0
                : decimal.Round((decimal)correctCount * 100 / questions.Count, 2)
        };
    }
}
