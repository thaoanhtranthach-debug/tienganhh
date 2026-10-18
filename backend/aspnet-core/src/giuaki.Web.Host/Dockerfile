FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src
COPY ["src/giuaki.Web.Host/giuaki.Web.Host.csproj", "src/giuaki.Web.Host/"]
COPY ["src/giuaki.Web.Core/giuaki.Web.Core.csproj", "src/giuaki.Web.Core/"]
COPY ["src/giuaki.Application/giuaki.Application.csproj", "src/giuaki.Application/"]
COPY ["src/giuaki.Core/giuaki.Core.csproj", "src/giuaki.Core/"]
COPY ["src/giuaki.EntityFrameworkCore/giuaki.EntityFrameworkCore.csproj", "src/giuaki.EntityFrameworkCore/"]
WORKDIR "/src/src/giuaki.Web.Host"
RUN dotnet restore 

WORKDIR /src
COPY ["src/giuaki.Web.Host", "src/giuaki.Web.Host"]
COPY ["src/giuaki.Web.Core", "src/giuaki.Web.Core"]
COPY ["src/giuaki.Application", "src/giuaki.Application"]
COPY ["src/giuaki.Core", "src/giuaki.Core"]
COPY ["src/giuaki.EntityFrameworkCore", "src/giuaki.EntityFrameworkCore"]
WORKDIR "/src/src/giuaki.Web.Host"
RUN dotnet publish -c Release -o /publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0
EXPOSE 80
WORKDIR /app
COPY --from=build /publish .
ENTRYPOINT ["dotnet", "giuaki.Web.Host.dll"]
