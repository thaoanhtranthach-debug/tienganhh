using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace giuaki.Migrations
{
    /// <inheritdoc />
    public partial class Init_Database : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Exams_TenantId",
                table: "Exams");

            migrationBuilder.DropIndex(
                name: "IX_ExamAttempts_TenantId",
                table: "ExamAttempts");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_Exams_TenantId",
                table: "Exams",
                column: "TenantId");

            migrationBuilder.CreateIndex(
                name: "IX_ExamAttempts_TenantId",
                table: "ExamAttempts",
                column: "TenantId");
        }
    }
}
