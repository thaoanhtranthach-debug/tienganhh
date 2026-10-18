using Abp.AspNetCore;
using Abp.AspNetCore.TestBase;
using Abp.Modules;
using Abp.Reflection.Extensions;
using giuaki.EntityFrameworkCore;
using giuaki.Web.Startup;
using Microsoft.AspNetCore.Mvc.ApplicationParts;

namespace giuaki.Web.Tests;

[DependsOn(
    typeof(giuakiWebMvcModule),
    typeof(AbpAspNetCoreTestBaseModule)
)]
public class giuakiWebTestModule : AbpModule
{
    public giuakiWebTestModule(giuakiEntityFrameworkModule abpProjectNameEntityFrameworkModule)
    {
        abpProjectNameEntityFrameworkModule.SkipDbContextRegistration = true;
    }

    public override void PreInitialize()
    {
        Configuration.UnitOfWork.IsTransactional = false; //EF Core InMemory DB does not support transactions.
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(giuakiWebTestModule).GetAssembly());
    }

    public override void PostInitialize()
    {
        IocManager.Resolve<ApplicationPartManager>()
            .AddApplicationPartsIfNotAddedBefore(typeof(giuakiWebMvcModule).Assembly);
    }
}