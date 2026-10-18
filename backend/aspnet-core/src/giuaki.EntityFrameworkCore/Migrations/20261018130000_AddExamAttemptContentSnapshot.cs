using giuaki.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace giuaki.Migrations;

[DbContext(typeof(giuakiDbContext))]
[Migration("20261018130000_AddExamAttemptContentSnapshot")]
public partial class AddExamAttemptContentSnapshot : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "ContentJsonSnapshot",
            table: "ExamAttempts",
            type: "nvarchar(max)",
            nullable: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "ContentJsonSnapshot",
            table: "ExamAttempts");
    }
}
