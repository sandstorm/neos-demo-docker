# Neos Demo Docker Image

Try Neos by just starting this docker image. No configuration needed.

[Link to Docker Hub](https://store.docker.com/community/images/sandstormmedia/neos-demo)

## Gettings started

Make sure docker is running and run this command:

```
docker run --rm -p 8081:8081 sandstormmedia/neos-demo:1.0
```

Wait for startup and just go to [127.0.0.1:8081](http://127.0.0.1:8081) for frontend and [127.0.0.1:8081/neos](http://127.0.0.1:8081/neos) for backend

You can login with `admin` and `password`

## TODO

- Currently the database and resources are not persistent!
