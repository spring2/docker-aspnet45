$build=1
docker build -t spring2/aspnet45:$build .
docker tag spring2/aspnet45:$build spring2/aspnet45:latest

docker push spring2/aspnet45:$build
docker push spring2/aspnet45:latest
