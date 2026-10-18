using Abp.Domain.Repositories;
using Abp.Domain.Uow;
using Abp.Threading.BackgroundWorkers;
using Abp.Threading.Timers;
using giuaki.Exams.Dto;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace giuaki.Exams;

public class ExpiredExamAttemptWorker : AsyncPeriodicBackgroundWorkerBase
{
    private const int BatchSize = 100;

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    private readonly IRepository<ExamAttempt, long> _attemptRepository;
    private readonly IRepository<Exam, int> _examRepository;
    private readonly IUnitOfWorkManager _unitOfWorkManager;

    public ExpiredExamAttemptWorker(
        AbpAsyncTimer timer,
        IRepository<ExamAttempt, long> attemptRepository,
        IRepository<Exam, int> examRepository,
        IUnitOfWorkManager unitOfWorkManager)
        : base(timer)
    {
        _attemptRepository = attemptRepository;
        _examRepository = examRepository;
        _unitOfWorkManager = unitOfWorkManager;
        Timer.Period = 15000;
        Timer.RunOnStart = true;
    }

    protected override async Task DoWorkAsync()
    {
        using var unitOfWork = _unitOfWorkManager.Begin();
        var now = DateTime.UtcNow;
        var expiredAttempts = await _attemptRepository.GetAll()
            .IgnoreQueryFilters()
            .Where(attempt =>
                !attempt.IsDeleted &&
                !attempt.SubmittedAt.HasValue &&
                attempt.DeadlineAt <= now)
            .OrderBy(attempt => attempt.DeadlineAt)
            .Take(BatchSize)
            .ToListAsync();

        if (expiredAttempts.Count == 0)
        {
            await unitOfWork.CompleteAsync();
            return;
        }

        var examIds = expiredAttempts.Select(attempt => attempt.ExamId).Distinct().ToList();
        var exams = await _examRepository.GetAll()
            .IgnoreQueryFilters()
            .Where(exam => !exam.IsDeleted && examIds.Contains(exam.Id))
            .ToDictionaryAsync(exam => exam.Id);

        foreach (var attempt in expiredAttempts)
        {
            if (!exams.TryGetValue(attempt.ExamId, out var exam))
            {
                throw new InvalidOperationException(
                    $"Exam {attempt.ExamId} for expired attempt {attempt.Id} was not found.");
            }

            var content = JsonSerializer.Deserialize<ExamContentDto>(exam.ContentJson, JsonOptions)
                ?? throw new InvalidOperationException($"Exam {exam.Id} has empty content.");
            var answers = JsonSerializer.Deserialize<System.Collections.Generic.Dictionary<int, string>>(
                attempt.AnswersJson,
                JsonOptions)
                ?? throw new InvalidOperationException($"Attempt {attempt.Id} has empty answer data.");
            var score = ExamScoring.Calculate(content, answers);

            var submittedAt = attempt.DeadlineAt;
            await _attemptRepository.GetAll()
                .IgnoreQueryFilters()
                .Where(current =>
                    current.Id == attempt.Id &&
                    !current.IsDeleted &&
                    !current.SubmittedAt.HasValue &&
                    current.DeadlineAt <= now &&
                    current.AnswersJson == attempt.AnswersJson)
                .ExecuteUpdateAsync(updates => updates
                    .SetProperty(current => current.CorrectCount, score.CorrectCount)
                    .SetProperty(current => current.IncorrectCount, score.IncorrectCount)
                    .SetProperty(current => current.SkippedCount, score.SkippedCount)
                    .SetProperty(current => current.ScorePercent, score.ScorePercent)
                    .SetProperty(current => current.SubmittedAt, submittedAt)
                    .SetProperty(current => current.LastModificationTime, (DateTime?)now));
        }

        await unitOfWork.CompleteAsync();
    }
}
