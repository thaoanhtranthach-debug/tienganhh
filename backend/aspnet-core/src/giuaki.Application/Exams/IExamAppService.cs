using Abp.Application.Services;
using System.Threading.Tasks;

namespace giuaki.Exams;

public interface IExamAppService : IApplicationService
{
    Task<Dto.ImportExamResultDto> ImportAsync(Dto.ImportExamInputDto input);

    Task<Dto.ImportExamResultDto> UpdateAsync(Dto.UpdateExamInputDto input);

    Task UpdateQuestionsAsync(Dto.UpdateExamQuestionsInputDto input);

    Task<Dto.ExamContentDto> PreviewAsync(int examId);

    Task PublishAsync(int examId);

    Task<Dto.ExamManagerDto> GetManagedExamsAsync();

    Task<Dto.ExamAnalyticsDto> GetAnalyticsAsync(int examId);

    Task<Dto.ExamManagerDto> GetAvailableExamsAsync();

    Task<Dto.ExamAttemptDto> StartAttemptAsync(Dto.StartExamAttemptDto input);

    Task<Dto.ExamAttemptDto> SaveAnswerAsync(long attemptId, Dto.SaveExamAnswerDto input);

    Task<Dto.ExamAttemptDto> GetAttemptAsync(long attemptId);

    Task<Dto.ExamResultDto> SubmitAsync(long attemptId);

    Task<Dto.ExamResultDto> GetResultAsync(long attemptId);
}
