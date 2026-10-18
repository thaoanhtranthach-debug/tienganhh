using System.ComponentModel.DataAnnotations;

namespace giuaki.Users.Dto;

public class ChangeUserLanguageDto
{
    [Required]
    public string LanguageName { get; set; }
}