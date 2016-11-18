set VERSION=5
docker build -t corts/aspnet45-base:%VERSION% .
docker tag corts/aspnet45-base:%VERSION% corts/aspnet45-base:latest
