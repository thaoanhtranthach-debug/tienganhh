using Abp.Modules;
using Abp.Reflection.Extensions;
using giuaki.Configuration;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;

namespace giuaki.Web.Host.Startup
{
    [DependsOn(
       typeof(giuakiWebCoreModule))]
    public class giuakiWebHostModule : AbpModule
    {
        private readonly IWebHostEnvironment _env;
        private readonly IConfigurationRoot _appConfiguration;

        public giuakiWebHostModule(IWebHostEnvironment env)
        {
            _env = env;
            _appConfiguration = env.GetAppConfiguration();
        }

        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(giuakiWebHostModule).GetAssembly());
        }
    }
}
