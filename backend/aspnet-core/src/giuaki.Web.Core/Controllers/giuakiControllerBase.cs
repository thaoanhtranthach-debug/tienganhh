using Abp.AspNetCore.Mvc.Controllers;
using Abp.IdentityFramework;
using Microsoft.AspNetCore.Identity;

namespace giuaki.Controllers
{
    public abstract class giuakiControllerBase : AbpController
    {
        protected giuakiControllerBase()
        {
            LocalizationSourceName = giuakiConsts.LocalizationSourceName;
        }

        protected void CheckErrors(IdentityResult identityResult)
        {
            identityResult.CheckErrors(LocalizationManager);
        }
    }
}
