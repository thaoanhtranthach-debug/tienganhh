using giuaki.Configuration.Dto;
using System.Threading.Tasks;

namespace giuaki.Configuration;

public interface IConfigurationAppService
{
    Task ChangeUiTheme(ChangeUiThemeInput input);
}
