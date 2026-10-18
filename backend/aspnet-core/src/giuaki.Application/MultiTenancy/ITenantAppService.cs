using Abp.Application.Services;
using giuaki.MultiTenancy.Dto;

namespace giuaki.MultiTenancy;

public interface ITenantAppService : IAsyncCrudAppService<TenantDto, int, PagedTenantResultRequestDto, CreateTenantDto, TenantDto>
{
}

