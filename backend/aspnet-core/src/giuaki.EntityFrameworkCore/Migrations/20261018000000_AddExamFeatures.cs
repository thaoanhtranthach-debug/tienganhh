using giuaki.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using System;

namespace giuaki.Migrations;

[DbContext(typeof(giuakiDbContext))]
[Migration("20261018000000_AddExamFeatures")]
public class AddExamFeatures : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "Exams",
            columns: table => new
            {
                Id = table.Column<int>(type: "int", nullable: false)
                    .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                TenantId = table.Column<int>(type: "int", nullable: true),
                Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                DurationMinutes = table.Column<int>(type: "int", nullable: false),
                QuestionCount = table.Column<int>(type: "int", nullable: false),
                IsPublished = table.Column<bool>(type: "bit", nullable: false),
                PublishedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                ContentJson = table.Column<string>(type: "nvarchar(max)", nullable: false),
                CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Exams", exam => exam.Id);
            });

        migrationBuilder.CreateTable(
            name: "ExamAttempts",
            columns: table => new
            {
                Id = table.Column<long>(type: "bigint", nullable: false)
                    .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                TenantId = table.Column<int>(type: "int", nullable: true),
                ExamId = table.Column<int>(type: "int", nullable: false),
                UserId = table.Column<long>(type: "bigint", nullable: false),
                StartedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                DeadlineAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                SubmittedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                AnswersJson = table.Column<string>(type: "nvarchar(max)", nullable: false),
                CorrectCount = table.Column<int>(type: "int", nullable: false),
                IncorrectCount = table.Column<int>(type: "int", nullable: false),
                SkippedCount = table.Column<int>(type: "int", nullable: false),
                ScorePercent = table.Column<decimal>(type: "decimal(5,2)", precision: 5, scale: 2, nullable: false),
                CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_ExamAttempts", attempt => attempt.Id);
                table.ForeignKey(
                    name: "FK_ExamAttempts_Exams_ExamId",
                    column: attempt => attempt.ExamId,
                    principalTable: "Exams",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_Exams_IsPublished",
            table: "Exams",
            column: "IsPublished");

        migrationBuilder.CreateIndex(
            name: "IX_ExamAttempts_ExamId_UserId",
            table: "ExamAttempts",
            columns: new[] { "ExamId", "UserId" });

        migrationBuilder.CreateIndex(
            name: "IX_ExamAttempts_TenantId",
            table: "ExamAttempts",
            column: "TenantId");

        migrationBuilder.CreateIndex(
            name: "IX_Exams_TenantId",
            table: "Exams",
            column: "TenantId");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(name: "ExamAttempts");
        migrationBuilder.DropTable(name: "Exams");
    }
}
