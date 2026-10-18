using Abp.AspNetCore.Mvc.Authorization;
using giuaki.Controllers;
using Microsoft.AspNetCore.Mvc;

namespace giuaki.Web.Controllers;

[AbpMvcAuthorize]
public class AboutController : giuakiControllerBase
{
    public ActionResult Index()
    {
        return View();
    }
}
