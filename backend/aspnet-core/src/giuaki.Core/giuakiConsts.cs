using giuaki.Debugging;

namespace giuaki;

public class giuakiConsts
{
    public const string LocalizationSourceName = "giuaki";

    public const string ConnectionStringName = "Default";

    public const bool MultiTenancyEnabled = true;


    /// <summary>
    /// Default pass phrase for SimpleStringCipher decrypt/encrypt operations
    /// </summary>
    public static readonly string DefaultPassPhrase =
        DebugHelper.IsDebug ? "gsKxGZ012HLL3MI5" : "9c80224133b440118b98f02a1742ea71";
}
