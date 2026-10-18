using Microsoft.EntityFrameworkCore;
using System.Data.Common;

namespace giuaki.EntityFrameworkCore;

public static class giuakiDbContextConfigurer
{
    public static void Configure(DbContextOptionsBuilder<giuakiDbContext> builder, string connectionString)
    {
        builder.UseSqlServer(connectionString);
    }

    public static void Configure(DbContextOptionsBuilder<giuakiDbContext> builder, DbConnection connection)
    {
        builder.UseSqlServer(connection);
    }
}
