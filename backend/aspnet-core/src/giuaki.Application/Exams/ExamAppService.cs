using Abp;
using Abp.Authorization;
using Abp.Domain.Repositories;
using Abp.Runtime.Session;
using Abp.UI;
using giuaki.Authorization;
using giuaki.Exams.Dto;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace giuaki.Exams;

public class ExamAppService : giuakiAppServiceBase, IExamAppService
{
    private const int MaximumUploadBytes = 8 * 1024 * 1024;
    private const int TotalQuestionCount = 100;
    private const string ExamJsonError = "Nội dung đề thi không đọc được. Hãy import lại file Word hợp lệ.";

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    private readonly IRepository<Exam, int> _examRepository;
    private readonly IRepository<ExamAttempt, long> _attemptRepository;

    public ExamAppService(
        IRepository<Exam, int> examRepository,
        IRepository<ExamAttempt, long> attemptRepository)
    {
        _examRepository = examRepository;
        _attemptRepository = attemptRepository;
    }

    [AbpAuthorize(PermissionNames.Pages_Exams_Manage)]
    public async Task<ImportExamResultDto> ImportAsync(ImportExamInputDto input)
    {
        var content = ParseContent(input?.FileName, input?.FileContentBase64);

        var exam = new Exam
        {
            TenantId = AbpSession.TenantId,
            Title = content.Title,
            DurationMinutes = content.DurationMinutes,
            QuestionCount = TotalQuestionCount,
            ContentJson = JsonSerializer.Serialize(content, JsonOptions)
        };

        var examId = await _examRepository.InsertAndGetIdAsync(exam);
        await CurrentUnitOfWork.SaveChangesAsync();

        return new ImportExamResultDto
        {
            ExamId = examId,
            Title = exam.Title,
            QuestionCount = exam.QuestionCount
        };
    }

    [AbpAuthorize(PermissionNames.Pages_Exams_Manage)]
    public async Task<ImportExamResultDto> UpdateAsync(UpdateExamInputDto input)
    {
        if (input == null || input.ExamId <= 0)
        {
            throw new UserFriendlyException("Mã đề thi không hợp lệ.");
        }

        var exam = await GetExamAsync(input.ExamId);
        var content = ParseContent(input.FileName, input.FileContentBase64);
        var contentJson = JsonSerializer.Serialize(content, JsonOptions);
        var previousContentJson = exam.ContentJson;

        if (content.Parts.Sum(GetQuestionCount) != TotalQuestionCount)
        {
            throw new UserFriendlyException("Không thể cập nhật đề chưa có đủ 100 câu hợp lệ.");
        }

        await _attemptRepository.GetAll()
            .Where(attempt =>
                attempt.ExamId == exam.Id &&
                attempt.ContentJsonSnapshot == null)
            .ExecuteUpdateAsync(updates => updates
                .SetProperty(attempt => attempt.ContentJsonSnapshot, previousContentJson));

        exam.Title = content.Title;
        exam.DurationMinutes = content.DurationMinutes;
        exam.QuestionCount = TotalQuestionCount;
        exam.ContentJson = contentJson;
        if (exam.IsPublished)
        {
            exam.PublishedAt = DateTime.UtcNow;
        }

        await _examRepository.UpdateAsync(exam);

        return new ImportExamResultDto
        {
            ExamId = exam.Id,
            Title = exam.Title,
            QuestionCount = exam.QuestionCount
        };
    }

    [AbpAuthorize(PermissionNames.Pages_Exams_Manage)]
    public async Task UpdateQuestionsAsync(UpdateExamQuestionsInputDto input)
    {
        if (input == null || input.ExamId <= 0)
        {
            throw new UserFriendlyException("Mã đề thi không hợp lệ.");
        }

        var exam = await GetExamAsync(input.ExamId);
        if (!exam.IsPublished)
        {
            throw new UserFriendlyException("Chỉ có thể chỉnh sửa câu hỏi của đề đã xuất bản.");
        }

        var content = DeserializeContent(exam.ContentJson);
        ExamQuestionEditor.Apply(content, input.Questions);

        var previousContentJson = exam.ContentJson;
        await _attemptRepository.GetAll()
            .Where(attempt =>
                attempt.ExamId == exam.Id &&
                attempt.ContentJsonSnapshot == null)
            .ExecuteUpdateAsync(updates => updates
                .SetProperty(attempt => attempt.ContentJsonSnapshot, previousContentJson));

        exam.ContentJson = JsonSerializer.Serialize(content, JsonOptions);
        await _examRepository.UpdateAsync(exam);
    }

    [AbpAuthorize(PermissionNames.Pages_Exams_Manage)]
    public async Task<ExamContentDto> PreviewAsync(int examId)
    {
        var exam = await GetExamAsync(examId);
        return DeserializeContent(exam.ContentJson);
    }

    [AbpAuthorize(PermissionNames.Pages_Exams_Manage)]
    public async Task PublishAsync(int examId)
    {
        var exam = await GetExamAsync(examId);
        var content = DeserializeContent(exam.ContentJson);
        if (content.Parts.Sum(GetQuestionCount) != TotalQuestionCount)
        {
            throw new UserFriendlyException("Không thể xuất bản đề chưa có đủ 100 câu hợp lệ.");
        }

        exam.IsPublished = true;
        exam.PublishedAt = DateTime.UtcNow;
        await _examRepository.UpdateAsync(exam);
    }

    [AbpAuthorize(PermissionNames.Pages_Exams_Manage)]
    public async Task<ExamManagerDto> GetManagedExamsAsync()
    {
        var exams = await _examRepository.GetAll()
            .OrderByDescending(exam => exam.CreationTime)
            .ToListAsync();

        return new ExamManagerDto
        {
            Exams = exams.Select(ToSummary).ToList()
        };
    }

    [AbpAuthorize(PermissionNames.Pages_Exams_Manage)]
    public async Task<ExamAnalyticsDto> GetAnalyticsAsync(int examId)
    {
        var exam = await GetExamAsync(examId);
        var attempts = await _attemptRepository.GetAll()
            .Where(attempt => attempt.ExamId == examId)
            .ToListAsync();
        var submitted = attempts.Where(attempt => attempt.SubmittedAt.HasValue).ToList();
        var currentContent = DeserializeContent(exam.ContentJson);
        var incorrectByQuestion = currentContent.Parts
            .SelectMany(part => FlattenQuestions(part))
            .ToDictionary(question => question.Number, _ => 0);

        foreach (var attempt in submitted)
        {
            var attemptContent = DeserializeContent(
                attempt.ContentJsonSnapshot ?? exam.ContentJson);
            var answers = DeserializeAnswers(attempt.AnswersJson);
            foreach (var answer in answers)
            {
                var question = FindQuestion(attemptContent, answer.Key);
                if (question != null &&
                    incorrectByQuestion.ContainsKey(question.Number) &&
                    !string.Equals(question.CorrectAnswer, answer.Value, StringComparison.Ordinal))
                {
                    incorrectByQuestion[question.Number]++;
                }
            }
        }

        return new ExamAnalyticsDto
        {
            ExamId = examId,
            AttemptCount = attempts.Count,
            SubmittedAttemptCount = submitted.Count,
            AverageScorePercent = submitted.Count == 0
                ? 0
                : decimal.Round(submitted.Average(attempt => attempt.ScorePercent), 2),
            MostMissedQuestions = incorrectByQuestion
                .Where(question => question.Value > 0)
                .OrderByDescending(question => question.Value)
                .ThenBy(question => question.Key)
                .Take(10)
                .Select(question => new ExamQuestionAnalyticsDto
                {
                    QuestionNumber = question.Key,
                    IncorrectCount = question.Value
                })
                .ToList()
        };
    }

    [AbpAuthorize]
    public async Task<ExamManagerDto> GetAvailableExamsAsync()
    {
        var exams = await _examRepository.GetAll()
            .Where(exam => exam.IsPublished)
            .OrderByDescending(exam => exam.PublishedAt)
            .ToListAsync();

        return new ExamManagerDto
        {
            Exams = exams.Select(ToSummary).ToList()
        };
    }

    [AbpAuthorize]
    public async Task<ExamAttemptDto> StartAttemptAsync(StartExamAttemptDto input)
    {
        if (input == null || input.ExamId <= 0)
        {
            throw new UserFriendlyException("Mã đề thi không hợp lệ.");
        }

        var exam = await _examRepository.GetAll()
            .FirstOrDefaultAsync(item => item.Id == input.ExamId && item.IsPublished);
        if (exam == null)
        {
            throw new UserFriendlyException("Đề thi không tồn tại hoặc chưa được xuất bản.");
        }

        var content = DeserializeContent(exam.ContentJson);
        var startedAt = DateTime.UtcNow;
        var attempt = new ExamAttempt
        {
            TenantId = AbpSession.TenantId,
            ExamId = exam.Id,
            UserId = AbpSession.GetUserId(),
            StartedAt = startedAt,
            DeadlineAt = startedAt.AddMinutes(exam.DurationMinutes),
            AnswersJson = "{}",
            ContentJsonSnapshot = exam.ContentJson
        };

        await _attemptRepository.InsertAndGetIdAsync(attempt);
        await CurrentUnitOfWork.SaveChangesAsync();

        return ToStudentAttempt(attempt, exam, content, DeserializeAnswers(attempt.AnswersJson));
    }

    [AbpAuthorize]
    public async Task<ExamAttemptDto> SaveAnswerAsync(long attemptId, SaveExamAnswerDto input)
    {
        if (input == null || input.QuestionNumber < 101 || input.QuestionNumber > 200)
        {
            throw new UserFriendlyException("Số câu trả lời không hợp lệ.");
        }

        var attempt = await GetCurrentUserAttemptAsync(attemptId);
        if (attempt.SubmittedAt.HasValue)
        {
            return await GetAttemptSnapshotAsync(attempt);
        }

        if (DateTime.UtcNow >= attempt.DeadlineAt)
        {
            await FinalizeAttemptAsync(attempt, autoSubmitted: true);
            await CurrentUnitOfWork.SaveChangesAsync();
            return await GetAttemptSnapshotAsync(attempt);
        }

        var exam = await GetExamAsync(attempt.ExamId);
        var content = DeserializeContent(attempt.ContentJsonSnapshot ?? exam.ContentJson);
        var question = FindQuestion(content, input.QuestionNumber);
        if (question == null)
        {
            throw new UserFriendlyException("Câu hỏi không tồn tại trong đề thi.");
        }

        var answers = DeserializeAnswers(attempt.AnswersJson);
        if (string.IsNullOrWhiteSpace(input.ChoiceId))
        {
            answers.Remove(input.QuestionNumber);
        }
        else
        {
            if (!question.Choices.ContainsKey(input.ChoiceId))
            {
                throw new UserFriendlyException("Lựa chọn không hợp lệ cho câu hỏi này.");
            }

            answers[input.QuestionNumber] = input.ChoiceId;
        }

        var updatedAnswersJson = JsonSerializer.Serialize(answers, JsonOptions);
        var updatedRows = await _attemptRepository.GetAll()
            .Where(current =>
                current.Id == attempt.Id &&
                current.UserId == AbpSession.GetUserId() &&
                !current.SubmittedAt.HasValue &&
                current.DeadlineAt > DateTime.UtcNow)
            .ExecuteUpdateAsync(updates => updates
                .SetProperty(current => current.AnswersJson, updatedAnswersJson)
                .SetProperty(current => current.LastModificationTime, (DateTime?)DateTime.UtcNow)
                .SetProperty(current => current.LastModifierUserId, AbpSession.UserId));
        if (updatedRows == 0)
        {
            throw new UserFriendlyException("Bài thi đã hết giờ hoặc đã được nộp; không thể sửa đáp án.");
        }

        return ToStudentAttempt(attempt, exam, content, answers);
    }

    [AbpAuthorize]
    public async Task<ExamAttemptDto> GetAttemptAsync(long attemptId)
    {
        var attempt = await GetCurrentUserAttemptAsync(attemptId);
        if (!attempt.SubmittedAt.HasValue && DateTime.UtcNow >= attempt.DeadlineAt)
        {
            await FinalizeAttemptAsync(attempt, autoSubmitted: true);
            await CurrentUnitOfWork.SaveChangesAsync();
        }

        return await GetAttemptSnapshotAsync(attempt);
    }

    [AbpAuthorize]
    public async Task<ExamResultDto> SubmitAsync(long attemptId)
    {
        var attempt = await GetCurrentUserAttemptAsync(attemptId);
        if (!attempt.SubmittedAt.HasValue)
        {
            await FinalizeAttemptAsync(attempt, autoSubmitted: DateTime.UtcNow >= attempt.DeadlineAt);
            await _attemptRepository.UpdateAsync(attempt);
        }

        return ToResult(attempt, (await GetExamAsync(attempt.ExamId)).QuestionCount);
    }

    [AbpAuthorize]
    public async Task<ExamResultDto> GetResultAsync(long attemptId)
    {
        var attempt = await GetCurrentUserAttemptAsync(attemptId);
        if (!attempt.SubmittedAt.HasValue)
        {
            if (DateTime.UtcNow < attempt.DeadlineAt)
            {
                throw new UserFriendlyException("Kết quả chỉ có sau khi nộp bài hoặc hết giờ.");
            }

            await FinalizeAttemptAsync(attempt, autoSubmitted: true);
            await CurrentUnitOfWork.SaveChangesAsync();
        }

        var exam = await GetExamAsync(attempt.ExamId);
        return ToResult(attempt, exam.QuestionCount);
    }

    private async Task<Exam> GetExamAsync(int examId)
    {
        var exam = await _examRepository.GetAll().FirstOrDefaultAsync(item => item.Id == examId);
        if (exam == null)
        {
            throw new UserFriendlyException("Đề thi không tồn tại.");
        }

        return exam;
    }

    private static ExamContentDto ParseContent(string fileName, string fileContentBase64)
    {
        if (string.IsNullOrWhiteSpace(fileName) ||
            !string.Equals(Path.GetExtension(fileName), ".docx", StringComparison.OrdinalIgnoreCase))
        {
            throw new UserFriendlyException("Chỉ chấp nhận file Word .docx.");
        }

        if (string.IsNullOrWhiteSpace(fileContentBase64))
        {
            throw new UserFriendlyException("File DOCX đang trống.");
        }

        byte[] fileBytes;
        try
        {
            fileBytes = Convert.FromBase64String(fileContentBase64);
        }
        catch (FormatException)
        {
            throw new UserFriendlyException("Nội dung file DOCX không đúng định dạng Base64.");
        }

        if (fileBytes.Length == 0 || fileBytes.Length > MaximumUploadBytes)
        {
            throw new UserFriendlyException("File DOCX phải có dung lượng từ 1 byte đến 8 MB.");
        }

        if (fileBytes.Length < 4 ||
            fileBytes[0] != 0x50 ||
            fileBytes[1] != 0x4B)
        {
            throw new UserFriendlyException("File không phải gói DOCX hợp lệ.");
        }

        try
        {
            using var stream = new MemoryStream(fileBytes, writable: false);
            return ExamImportParser.Parse(stream);
        }
        catch (ExamImportValidationException exception)
        {
            throw new UserFriendlyException(
                "Đề thi chưa được lưu hoặc cập nhật. Hãy sửa các lỗi trong file Word:\n- " +
                string.Join("\n- ", exception.Errors));
        }
    }

    private async Task<ExamAttempt> GetCurrentUserAttemptAsync(long attemptId)
    {
        var userId = AbpSession.GetUserId();
        var attempt = await _attemptRepository.GetAll()
            .FirstOrDefaultAsync(item => item.Id == attemptId && item.UserId == userId);
        if (attempt == null)
        {
            throw new UserFriendlyException("Lần làm bài không tồn tại.");
        }

        return attempt;
    }

    private async Task<ExamAttemptDto> GetAttemptSnapshotAsync(ExamAttempt attempt)
    {
        var exam = await GetExamAsync(attempt.ExamId);
        var content = DeserializeContent(attempt.ContentJsonSnapshot ?? exam.ContentJson);
        var answers = DeserializeAnswers(attempt.AnswersJson);
        return ToStudentAttempt(attempt, exam, content, answers);
    }

    private async Task FinalizeAttemptAsync(ExamAttempt attempt, bool autoSubmitted)
    {
        var exam = await GetExamAsync(attempt.ExamId);
        var content = DeserializeContent(attempt.ContentJsonSnapshot ?? exam.ContentJson);
        var answers = DeserializeAnswers(attempt.AnswersJson);
        var score = ExamScoring.Calculate(content, answers);

        attempt.CorrectCount = score.CorrectCount;
        attempt.IncorrectCount = score.IncorrectCount;
        attempt.SkippedCount = score.SkippedCount;
        attempt.ScorePercent = score.ScorePercent;
        attempt.SubmittedAt = autoSubmitted ? attempt.DeadlineAt : DateTime.UtcNow;
        await _attemptRepository.UpdateAsync(attempt);
    }

    private static ExamContentDto DeserializeContent(string json)
    {
        try
        {
            return JsonSerializer.Deserialize<ExamContentDto>(json, JsonOptions)
                   ?? throw new JsonException("Empty exam content.");
        }
        catch (JsonException)
        {
            throw new UserFriendlyException(ExamJsonError);
        }
    }

    private static Dictionary<int, string> DeserializeAnswers(string json)
    {
        try
        {
            return JsonSerializer.Deserialize<Dictionary<int, string>>(json, JsonOptions) ?? new();
        }
        catch (JsonException)
        {
            throw new UserFriendlyException("Câu trả lời của bài thi bị lỗi dữ liệu.");
        }
    }

    private static ExamSummaryDto ToSummary(Exam exam)
    {
        return new ExamSummaryDto
        {
            Id = exam.Id,
            Title = exam.Title,
            DurationMinutes = exam.DurationMinutes,
            QuestionCount = exam.QuestionCount,
            IsPublished = exam.IsPublished
        };
    }

    private static ExamAttemptDto ToStudentAttempt(
        ExamAttempt attempt,
        Exam exam,
        ExamContentDto content,
        IReadOnlyDictionary<int, string> answers)
    {
        var questions = new List<ExamStudentQuestionDto>();
        var random = Random.Shared;
        foreach (var part in content.Parts.OrderBy(part => part.Number))
        {
            var partQuestions = content.ShuffleQuestions
                ? part.Questions.OrderBy(_ => random.Next())
                : part.Questions.OrderBy(question => question.Number);
            foreach (var question in partQuestions)
            {
                questions.Add(ToStudentQuestion(question, null, answers, content.ShuffleChoices));
            }

            var passages = content.ShuffleQuestions
                ? part.Passages.OrderBy(_ => random.Next())
                : part.Passages.OrderBy(passage => passage.Id, StringComparer.Ordinal);
            foreach (var passage in passages)
            {
                var passageQuestions = content.ShuffleQuestions
                    ? passage.Questions.OrderBy(_ => random.Next())
                    : passage.Questions.OrderBy(question => question.Number);
                foreach (var question in passageQuestions)
                {
                    questions.Add(ToStudentQuestion(question, passage, answers, content.ShuffleChoices));
                }
            }
        }

        return new ExamAttemptDto
        {
            AttemptId = attempt.Id,
            ExamId = exam.Id,
            ExamTitle = content.Title,
            StartedAt = attempt.StartedAt,
            DeadlineAt = attempt.DeadlineAt,
            SubmittedAt = attempt.SubmittedAt,
            Images = content.Images,
            Questions = questions
        };
    }

    private static ExamStudentQuestionDto ToStudentQuestion(
        ExamQuestionDto question,
        ExamPassageDto passage,
        IReadOnlyDictionary<int, string> answers,
        bool shuffleChoices)
    {
        var choices = question.Choices;
        if (shuffleChoices)
        {
            choices = choices
                .OrderBy(_ => Random.Shared.Next())
                .ToDictionary(choice => choice.Key, choice => choice.Value, StringComparer.Ordinal);
        }

        answers.TryGetValue(question.Number, out var selectedChoiceId);
        return new ExamStudentQuestionDto
        {
            Number = question.Number,
            PartNumber = question.PartNumber,
            PassageId = question.PassageId,
            PassageType = passage?.Type,
            PassageText = passage?.Text,
            ImageIds = new List<string>(question.ImageIds),
            Prompt = question.Prompt,
            Choices = new Dictionary<string, string>(choices, StringComparer.Ordinal),
            SelectedChoiceId = selectedChoiceId
        };
    }

    private static ExamResultDto ToResult(ExamAttempt attempt, int totalQuestions)
    {
        return new ExamResultDto
        {
            AttemptId = attempt.Id,
            ExamId = attempt.ExamId,
            TotalQuestions = totalQuestions,
            CorrectCount = attempt.CorrectCount,
            IncorrectCount = attempt.IncorrectCount,
            SkippedCount = attempt.SkippedCount,
            ScorePercent = attempt.ScorePercent,
            SubmittedAt = attempt.SubmittedAt ?? attempt.DeadlineAt
        };
    }

    private static IEnumerable<ExamQuestionDto> FlattenQuestions(ExamPartDto part)
    {
        return part.Questions.Concat(part.Passages.SelectMany(passage => passage.Questions));
    }

    private static ExamQuestionDto FindQuestion(ExamContentDto content, int questionNumber)
    {
        return content.Parts
            .SelectMany(FlattenQuestions)
            .FirstOrDefault(question => question.Number == questionNumber);
    }

    private static int GetQuestionCount(ExamPartDto part)
    {
        return FlattenQuestions(part).Count();
    }

}
