using Abp.AspNetCore.Mvc.Views;
using Abp.Runtime.Session;
using Microsoft.AspNetCore.Mvc.Razor.Internal;

namespace giuaki.Web.Views;

public abstract class giuakiRazorPage<TModel> : AbpRazorPage<TModel>
{
    [RazorInject]
    public IAbpSession AbpSession { get; set; }

    protected giuakiRazorPage()
    {
        LocalizationSourceName = giuakiConsts.LocalizationSourceName;
    }
}
