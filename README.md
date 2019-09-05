# Neos Demo Docker Image

Try Neos by just starting this docker image. No configuration needed. Just download the image from [Docker Hub](https://hub.docker.com/r/sandstormmedia/neos-demo).

## Gettings started

Make sure [Docker](https://docs.docker.com/docker-for-mac/) is running and execute:

```sh
docker run --rm -p 8081:8081 sandstormmedia/neos-demo:5.0.2
```

Wait for startup and just go to [127.0.0.1:8081](http://127.0.0.1:8081) for frontend and [127.0.0.1:8081/neos](http://127.0.0.1:8081/neos) for backend

You can login with `admin` and `password` in the backend.

## TODO

- Currently the database and resources are not persistent!
- Replace _BASE_URI by [Trusted Proxies](https://flowframework.readthedocs.io/en/stable/TheDefinitiveGuide/PartIII/Http.html#trusted-proxies)
