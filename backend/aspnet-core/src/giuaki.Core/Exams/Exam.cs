using Abp.Domain.Entities;
using Abp.Domain.Entities.Auditing;
using System;

namespace giuaki.Exams;

public class Exam : FullAuditedEntity<int>, IMayHaveTenant
{
    public int? TenantId { get; set; }

    public string Title { get; set; }

    public int DurationMinutes { get; set; }

    public int QuestionCount { get; set; }

    public bool IsPublished { get; set; }

    public DateTime? PublishedAt { get; set; }

    public string ContentJson { get; set; }
}
