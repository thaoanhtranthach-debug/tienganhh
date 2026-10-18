using Abp.Domain.Entities;
using Abp.Domain.Entities.Auditing;
using System;

namespace giuaki.Exams;

public class ExamAttempt : FullAuditedEntity<long>, IMayHaveTenant
{
    public int? TenantId { get; set; }

    public int ExamId { get; set; }

    public long UserId { get; set; }

    public DateTime StartedAt { get; set; }

    public DateTime DeadlineAt { get; set; }

    public DateTime? SubmittedAt { get; set; }

    public string AnswersJson { get; set; }

    public string ContentJsonSnapshot { get; set; }

    public int CorrectCount { get; set; }

    public int IncorrectCount { get; set; }

    public int SkippedCount { get; set; }

    public decimal ScorePercent { get; set; }
}
