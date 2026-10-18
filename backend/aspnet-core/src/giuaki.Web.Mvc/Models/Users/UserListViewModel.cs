using giuaki.Roles.Dto;
using System.Collections.Generic;

namespace giuaki.Web.Models.Users;

public class UserListViewModel
{
    public IReadOnlyList<RoleDto> Roles { get; set; }
}
