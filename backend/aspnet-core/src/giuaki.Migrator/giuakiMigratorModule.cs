using Abp.Events.Bus;
using Abp.Modules;
using Abp.Reflection.Extensions;
using giuaki.Configuration;
using giuaki.EntityFrameworkCore;
using giuaki.Migrator.DependencyInjection;
using Castle.MicroKernel.Registration;
using Microsoft.Extensions.Configuration;

namespace giuaki.Migrator;

[DependsOn(typeof(giuakiEntityFrameworkModule))]
public class giuakiMigratorModule : AbpModule
{
    private readonly IConfigurationRoot _appConfiguration;

    public giuakiMigratorModule(giuakiEntityFrameworkModule abpProjectNameEntityFrameworkModule)
    {
        abpProjectNameEntityFrameworkModule.SkipDbSeed = true;

        _appConfiguration = AppConfigurations.Get(
            typeof(giuakiMigratorModule).GetAssembly().GetDirectoryPathOrNull()
        );
    }

    public override void PreInitialize()
    {
        Configuration.DefaultNameOrConnectionString = _appConfiguration.GetConnectionString(
            giuakiConsts.ConnectionStringName
        );

        Configuration.BackgroundJobs.IsJobExecutionEnabled = false;
        Configuration.ReplaceService(
            typeof(IEventBus),
            () => IocManager.IocContainer.Register(
                Component.For<IEventBus>().Instance(NullEventBus.Instance)
            )
        );
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(giuakiMigratorModule).GetAssembly());
        ServiceCollectionRegistrar.Register(IocManager);
    }
}
