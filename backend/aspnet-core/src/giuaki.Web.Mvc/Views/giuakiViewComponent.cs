using Abp.AspNetCore.Mvc.ViewComponents;

namespace giuaki.Web.Views;

public abstract class giuakiViewComponent : AbpViewComponent
{
    protected giuakiViewComponent()
    {
        LocalizationSourceName = giuakiConsts.LocalizationSourceName;
    }
}
