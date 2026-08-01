# Docker Build Environment for LFS

Quick start guide for building LFS in Docker.

## Build the Image

```bash
cd scripts/docker
docker build -t lfs-builder:12.4 .
```

## Run the Container

```bash
# Create persistent volume
docker volume create lfs-build

# Run container
docker run -it \
  --name lfs-12.4 \
  --hostname lfs-builder \
  -v lfs-build:/mnt/lfs \
  lfs-builder:12.4
```

## Inside the Container

```bash
# Download sources
download-sources

# Switch to lfs user
lfs-shell

# Now follow LFS book from Chapter 5
# https://www.linuxfromscratch.org/lfs/view/stable/
```

## Save Your Progress

```bash
# From another terminal:
docker commit lfs-12.4 lfs-builder:12.4-ch5-complete
```

## Resume Later

```bash
# Start stopped container
docker start -i lfs-12.4

# Or start new from saved image
docker run -it \
  -v lfs-build:/mnt/lfs \
  lfs-builder:12.4-ch5-complete
```

See [../../docs/docker-build.md](../../docs/docker-build.md) for complete documentation.
