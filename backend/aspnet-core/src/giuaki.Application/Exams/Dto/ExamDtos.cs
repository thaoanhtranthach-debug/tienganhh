using System;
using System.Collections.Generic;

namespace giuaki.Exams.Dto;

public class ImportExamInputDto
{
    public string FileName { get; set; }

    public string FileContentBase64 { get; set; }
}

public class UpdateExamInputDto : ImportExamInputDto
{
    public int ExamId { get; set; }
}

public class UpdateExamQuestionsInputDto
{
    public int ExamId { get; set; }

    public List<ExamQuestionEditDto> Questions { get; set; } = new();
}

public class ExamQuestionEditDto
{
    public int Number { get; set; }

    public string Prompt { get; set; }

    public Dictionary<string, string> Choices { get; set; } = new();

    public string CorrectAnswer { get; set; }
}

public class ImportExamResultDto
{
    public int ExamId { get; set; }

    public string Title { get; set; }

    public int QuestionCount { get; set; }
}

public class ExamSummaryDto
{
    public int Id { get; set; }

    public string Title { get; set; }

    public int DurationMinutes { get; set; }

    public int QuestionCount { get; set; }

    public bool IsPublished { get; set; }
}

public class ExamContentDto
{
    public string Title { get; set; }

    public int DurationMinutes { get; set; }

    public bool ShuffleQuestions { get; set; }

    public bool ShuffleChoices { get; set; }

    public List<ExamImageDto> Images { get; set; } = new();

    public List<ExamPartDto> Parts { get; set; } = new();
}

public class ExamImageDto
{
    public string Id { get; set; }

    public string ContentType { get; set; }

    public string DataBase64 { get; set; }
}

public class ExamPartDto
{
    public int Number { get; set; }

    public List<ExamPassageDto> Passages { get; set; } = new();

    public List<ExamQuestionDto> Questions { get; set; } = new();
}

public class ExamPassageDto
{
    public string Id { get; set; }

    public string Type { get; set; }

    public string SourcePages { get; set; }

    public string Text { get; set; }

    public List<string> ImageIds { get; set; } = new();

    public List<ExamQuestionDto> Questions { get; set; } = new();
}

public class ExamQuestionDto
{
    public int Number { get; set; }

    public int PartNumber { get; set; }

    public string PassageId { get; set; }

    public string Prompt { get; set; }

    public List<string> ImageIds { get; set; } = new();

    public Dictionary<string, string> Choices { get; set; } = new();

    public string CorrectAnswer { get; set; }

    public string SourcePages { get; set; }
}

public class StartExamAttemptDto
{
    public int ExamId { get; set; }
}

public class SaveExamAnswerDto
{
    public int QuestionNumber { get; set; }

    public string ChoiceId { get; set; }
}

public class ExamStudentQuestionDto
{
    public int Number { get; set; }

    public int PartNumber { get; set; }

    public string PassageId { get; set; }

    public string PassageType { get; set; }

    public string PassageText { get; set; }

    public List<string> ImageIds { get; set; } = new();

    public string Prompt { get; set; }

    public Dictionary<string, string> Choices { get; set; } = new();

    public string SelectedChoiceId { get; set; }
}

public class ExamAttemptDto
{
    public long AttemptId { get; set; }

    public int ExamId { get; set; }

    public string ExamTitle { get; set; }

    public DateTime StartedAt { get; set; }

    public DateTime DeadlineAt { get; set; }

    public DateTime? SubmittedAt { get; set; }

    public List<ExamImageDto> Images { get; set; } = new();

    public List<ExamStudentQuestionDto> Questions { get; set; } = new();
}

public class ExamResultDto
{
    public long AttemptId { get; set; }

    public int ExamId { get; set; }

    public int TotalQuestions { get; set; }

    public int CorrectCount { get; set; }

    public int IncorrectCount { get; set; }

    public int SkippedCount { get; set; }

    public decimal ScorePercent { get; set; }

    public DateTime SubmittedAt { get; set; }
}

public class ExamQuestionAnalyticsDto
{
    public int QuestionNumber { get; set; }

    public int IncorrectCount { get; set; }
}

public class ExamAnalyticsDto
{
    public int ExamId { get; set; }

    public int AttemptCount { get; set; }

    public int SubmittedAttemptCount { get; set; }

    public decimal AverageScorePercent { get; set; }

    public List<ExamQuestionAnalyticsDto> MostMissedQuestions { get; set; } = new();
}

public class ExamManagerDto
{
    public List<ExamSummaryDto> Exams { get; set; } = new();
}
