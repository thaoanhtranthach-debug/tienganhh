using giuaki.Roles.Dto;
using System.Collections.Generic;

namespace giuaki.Web.Models.Common;

public interface IPermissionsEditViewModel
{
    List<FlatPermissionDto> Permissions { get; set; }
}