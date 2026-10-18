using Abp.Application.Services;
using giuaki.Sessions.Dto;
using System.Threading.Tasks;

namespace giuaki.Sessions;

public interface ISessionAppService : IApplicationService
{
    Task<GetCurrentLoginInformationsOutput> GetCurrentLoginInformations();
}
