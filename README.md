# docker-registry-manifest-cleanup-companion

A very simple container to be deployed alongside a Docker registry, incorporating Morten Steen Rasmussen's fantastic [docker-registry-manifest-cleanup](https://github.com/mortensteenrasmussen/docker-registry-manifest-cleanup) script to automatically cleanup the registry on a schedule.

Deploy this alongside your registry to have the following sequence of actions performed on the schedule you configure:

1. Execute the docker-registry-manifest-cleanup script to delete untagged manifests 
1. Stop the registry
1. Perform a registry garbage collection
1. Restart the registry

## Disclaimer

I'm using this image on my build server, but *would not stake my life on it*. Please *do not* use this on registries containing unrecoverable images! You use this *entirely at your own risk*.

## Example (Using Docker Compose)

```
version: '3.1'
services:
  registry:
    image: registry:2
    environment:
      REGISTRY_STORAGE_DELETE_ENABLED: 'true'
    ports:
      - "5000:5000"
    volumes:
      - registry-data:/var/lib/registry
    labels:
      - "me.hdpe.docker_registry_manifest_cleanup_companion.registry"

  cleanup-companion:
    image: hdpe/docker-registry-manifest-cleanup-companion
    environment:
      REGISTRY_URL: http://registry:5000
    volumes:
      - registry-data:/registry
      - /var/run/docker.sock:/var/run/docker.sock:ro

volumes:
  registry-data:
```

## Required Configuration

### For docker-registry-manifest-cleanup-companion

* Mount the Docker socket to `/var/run/docker.sock` so the container can restart your registry container
* Mount the volume containing your registry data
* Set the `REGISTRY_URL` environment variable to the base URL of your registry

### For your registry

* Add the label `me.hdpe.docker_registry_manifest_cleanup_companion.registry` so we know which registry container to restart

## Environment Variables

### `REGISTRY_URL`

The base URL of your registry. *Required*.

### `REGISTRY_DIR`

The path to the base directory of your registry on the container. Default is `/registry`.

### `CLEANUP_SCHEDULE`

The cron schedule expression defining when the cleanup is run. Default is `0 3 * * *` (run at 03:00 daily.)

All environment variables will be passed to docker-registry-manifest-cleanup script ([documentation](https://github.com/mortensteenrasmussen/docker-registry-manifest-cleanup) - so you could use `DRY_RUN` if you liked).

# Thanks #

* [docker-registry-manifest-cleanup](https://github.com/mortensteenrasmussen/docker-registry-manifest-cleanup), obviously :)
* A little inspiration from [docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion)
