using Abp.AutoMapper;
using Abp.Dependency;
using Abp.Modules;
using Abp.Reflection.Extensions;
using giuaki.Authorization;
using giuaki.Exams;

namespace giuaki;

[DependsOn(
    typeof(giuakiCoreModule),
    typeof(AbpAutoMapperModule))]
public class giuakiApplicationModule : AbpModule
{
    public override void PreInitialize()
    {
        Configuration.Authorization.Providers.Add<giuakiAuthorizationProvider>();
    }

    public override void Initialize()
    {
        var thisAssembly = typeof(giuakiApplicationModule).GetAssembly();

        IocManager.RegisterAssemblyByConvention(thisAssembly);
        IocManager.Register<ExpiredExamAttemptWorker>(DependencyLifeStyle.Transient);

        Configuration.Modules.AbpAutoMapper().Configurators.Add(
            // Scan the assembly for classes which inherit from AutoMapper.Profile
            cfg => cfg.AddMaps(thisAssembly)
        );
    }
}
