using Abp.Authorization;
using giuaki.Authorization.Roles;
using giuaki.Authorization.Users;

namespace giuaki.Authorization;

public class PermissionChecker : PermissionChecker<Role, User>
{
    public PermissionChecker(UserManager userManager)
        : base(userManager)
    {
    }
}
