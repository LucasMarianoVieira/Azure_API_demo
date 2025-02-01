FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Restore and rebuild project
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["azure_api_deploy.csproj", "./"]
RUN dotnet restore "./azure_api_deploy.csproj"
COPY  . .
WORKDIR "/src/"
RUN dotnet build "./azure_api_deploy.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish project
FROM build as publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./azure_api_deploy.csproj" -c $BUILD_CONFIGURATION -co /app/publish /p:UseAppHost=false

# final production run
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT [ "dotnet", "azure_api_deploy" ]
