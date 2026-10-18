using Abp.Modules;
using Abp.Reflection.Extensions;
using giuaki.Configuration;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;

namespace giuaki.Web.Startup;

[DependsOn(typeof(giuakiWebCoreModule))]
public class giuakiWebMvcModule : AbpModule
{
    private readonly IWebHostEnvironment _env;
    private readonly IConfigurationRoot _appConfiguration;

    public giuakiWebMvcModule(IWebHostEnvironment env)
    {
        _env = env;
        _appConfiguration = env.GetAppConfiguration();
    }

    public override void PreInitialize()
    {
        Configuration.Navigation.Providers.Add<giuakiNavigationProvider>();
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(giuakiWebMvcModule).GetAssembly());
    }
}
