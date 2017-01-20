set VERSION=2
docker build -t spring2/aspnet45-base:%VERSION% .
docker tag spring2/aspnet45-base:%VERSION% spring2/aspnet45-base:latest
