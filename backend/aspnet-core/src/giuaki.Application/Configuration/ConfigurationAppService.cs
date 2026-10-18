using Abp.Authorization;
using Abp.Runtime.Session;
using giuaki.Configuration.Dto;
using System.Threading.Tasks;

namespace giuaki.Configuration;

[AbpAuthorize]
public class ConfigurationAppService : giuakiAppServiceBase, IConfigurationAppService
{
    public async Task ChangeUiTheme(ChangeUiThemeInput input)
    {
        await SettingManager.ChangeSettingForUserAsync(AbpSession.ToUserIdentifier(), AppSettingNames.UiTheme, input.Theme);
    }
}
