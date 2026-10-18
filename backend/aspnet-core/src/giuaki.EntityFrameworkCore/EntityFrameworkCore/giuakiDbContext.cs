using Abp.Zero.EntityFrameworkCore;
using giuaki.Authorization.Roles;
using giuaki.Authorization.Users;
using giuaki.Exams;
using giuaki.MultiTenancy;
using Microsoft.EntityFrameworkCore;
using System;

namespace giuaki.EntityFrameworkCore;

public class giuakiDbContext : AbpZeroDbContext<Tenant, Role, User, giuakiDbContext>
{
    /* Define a DbSet for each entity of the application */
    public DbSet<Exam> Exams { get; set; }

    public DbSet<ExamAttempt> ExamAttempts { get; set; }

    public giuakiDbContext(DbContextOptions<giuakiDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Exam>(entity =>
        {
            entity.Property(exam => exam.Title).HasMaxLength(200).IsRequired();
            entity.Property(exam => exam.ContentJson).IsRequired();
            entity.HasIndex(exam => exam.IsPublished);
        });

        modelBuilder.Entity<ExamAttempt>(entity =>
        {
            entity.Property(attempt => attempt.AnswersJson).IsRequired();
            entity.Property(attempt => attempt.ScorePercent).HasPrecision(5, 2);
            entity.HasIndex(attempt => new { attempt.ExamId, attempt.UserId });
            entity.HasOne<Exam>()
                .WithMany()
                .HasForeignKey(attempt => attempt.ExamId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
