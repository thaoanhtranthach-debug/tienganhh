using giuaki.Models.TokenAuth;
using giuaki.Web.Controllers;
using Shouldly;
using System.Threading.Tasks;
using Xunit;

namespace giuaki.Web.Tests.Controllers;

public class HomeController_Tests : giuakiWebTestBase
{
    [Fact]
    public async Task Index_Test()
    {
        await AuthenticateAsync(null, new AuthenticateModel
        {
            UserNameOrEmailAddress = "admin",
            Password = "123qwe"
        });

        //Act
        var response = await GetResponseAsStringAsync(
            GetUrl<HomeController>(nameof(HomeController.Index))
        );

        //Assert
        response.ShouldNotBeNullOrEmpty();
    }
}