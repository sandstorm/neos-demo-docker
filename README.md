# Neos Demo Docker Image

Try Neos by just starting this docker image. No configuration needed. Just download the image from [Docker Hub](https://hub.docker.com/r/sandstormmedia/neos-demo).

## Gettings started

Make sure [Docker](https://docs.docker.com/docker-for-mac/) is running and execute:

```sh
docker run --rm -p 8081:8081 sandstormmedia/neos-demo:5.0.2-neos-4.3.4
```

Wait for startup and just go to [127.0.0.1:8081](http://127.0.0.1:8081) for frontend and [127.0.0.1:8081/neos](http://127.0.0.1:8081/neos) for backend

You can login with `admin` and `password` in the backend.

ADMIN_USER
ADMIN_PASSWORD

CUSTOM_DISTRIBUTION = neos/neos-development-distribution:4.2.x-dev
FORCE_VERSIONS=neos/flow:5.3.2 neos/neos:4.3.0 neos/media-browser:4.3.0 neos/nodetypes:4.3.0 neos/nodetypes-form:4.3.0 neos/nodetypes-navigation:4.3.0 neos/nodetypes-html:4.3.0 neos/nodetypes-contentreferences:4.3.0 neos/nodetypes-columnlayouts:4.3.0 neos/nodetypes-assetlist:4.3.0 neos/nodetypes-basemixins:4.3.0 neos/fusion:4.3.0 neos/content-repository:4.3.0 neos/site-kickstarter:4.3.0 neos/media:4.3.0


## TODO

- Currently the database and resources are not persistent!


## Developing

```
docker build -t neos-demo-docker .
docker run --rm -it --entrypoint /bin/bash neos-demo-docker
```

## Deployment

```
docker build -t sandstormmedia/neos-demo:5.1.0-neos-4.3.4 .
docker push sandstormmedia/neos-demo:5.1.0-neos-4.3.4
```