# Docker-Based LFS Build Guide

This guide shows you how to build Linux From Scratch in a Docker container for maximum isolation and reproducibility.

## Why Docker for LFS?

**Advantages:**
- **Isolation** - Build doesn't affect your host system
- **Reproducibility** - Same environment every time
- **Portability** - Works on any system with Docker (Linux, macOS, Windows)
- **Easy Reset** - Restart from scratch anytime
- **Parallel Builds** - Build multiple versions simultaneously

**Disadvantages:**
- Requires Docker knowledge
- Slightly more complex setup
- Cannot directly test bootloader installation

## Prerequisites

1. **Docker or Podman installed**
   - Linux: `sudo apt install docker.io` (Ubuntu/Debian)
   - macOS/Windows: [Docker Desktop](https://www.docker.com/products/docker-desktop/)

2. **System Resources**
   - 8GB+ RAM available for Docker
   - 30GB+ disk space
   - 4+ CPU cores recommended

3. **Basic Docker Knowledge**
   - Understanding of containers
   - Familiar with `docker run`, `docker build`

## Quick Start

### Option 1: Using Pre-configured Dockerfile (Coming Soon)

```bash
# Clone this repository
git clone https://github.com/OpenPolytechnicBITProjectGroup/LinuxFromScratch.git
cd LinuxFromScratch

# Build the Docker image
docker build -t lfs-builder -f scripts/docker/Dockerfile .

# Run the container
docker run -it --name lfs-build lfs-builder

# Inside container, follow LFS book instructions
```

### Option 2: Manual Docker Setup

Start with a base Ubuntu container and set up manually:

```bash
# Start Ubuntu container with enough resources
docker run -it \
  --name lfs-build \
  --memory="8g" \
  --cpus="4" \
  -v lfs-volume:/mnt/lfs \
  ubuntu:24.04 /bin/bash

# Inside container, install prerequisites
apt update
apt install -y \
  bash binutils bison gawk gcc g++ \
  make patch perl python3 sed tar texinfo \
  xz-utils wget vim less

# Create LFS user and directory structure
export LFS=/mnt/lfs
mkdir -pv $LFS
mkdir -v $LFS/{sources,tools,boot,etc,bin,lib,sbin,usr,var}

# Continue with LFS book from Chapter 3
```

## Detailed Build Process

### Step 1: Create Base Container

Create a `Dockerfile` for your LFS build environment:

```dockerfile
FROM ubuntu:24.04

# Install host system requirements
RUN apt-get update && apt-get install -y \
    bash binutils bison bzip2 coreutils diffutils \
    findutils gawk gcc g++ grep gzip m4 make patch \
    perl python3 sed tar texinfo xz-utils wget vim \
    && rm -rf /var/lib/apt/lists/*

# Set up LFS environment
ENV LFS=/mnt/lfs
ENV LC_ALL=POSIX
ENV LFS_TGT=x86_64-lfs-linux-gnu
ENV PATH=/tools/bin:/bin:/usr/bin

# Create directory structure
RUN mkdir -pv $LFS/{sources,tools,boot,etc,bin,lib,sbin,usr,var}

# Create lfs user
RUN groupadd lfs && \
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs && \
    chown -v lfs $LFS/{sources,tools}

WORKDIR $LFS

CMD ["/bin/bash"]
```

### Step 2: Build the Image

```bash
docker build -t lfs-builder:12.4 .
```

### Step 3: Run the Container

```bash
# Create a persistent volume for your build
docker volume create lfs-build-volume

# Run the container
docker run -it \
  --name lfs-12.4 \
  --hostname lfs-builder \
  --memory="8g" \
  --cpus="4" \
  -v lfs-build-volume:/mnt/lfs \
  lfs-builder:12.4
```

### Step 4: Download Sources

Inside the container:

```bash
# Switch to lfs user
su - lfs

# Download wget-list
cd $LFS/sources
wget https://www.linuxfromscratch.org/lfs/view/stable/wget-list

# Download all source packages
wget --input-file=wget-list --continue --directory-prefix=$LFS/sources

# Download md5sums
wget https://www.linuxfromscratch.org/lfs/view/stable/md5sums

# Verify downloads
pushd $LFS/sources
md5sum -c md5sums
popd
```

### Step 5: Follow LFS Book

Now follow the [official LFS book](https://www.linuxfromscratch.org/lfs/view/stable/) starting from Chapter 5.

Key chapters:
- **Chapter 5**: Compiling a Cross-Toolchain
- **Chapter 6**: Cross Compiling Temporary Tools
- **Chapter 7**: Entering Chroot and Building Additional Tools
- **Chapter 8**: Installing Basic System Software
- **Chapter 9**: System Configuration
- **Chapter 10**: Making the LFS System Bootable

## Managing Your Build

### Save Your Progress

```bash
# Commit container state
docker commit lfs-12.4 lfs-builder:12.4-progress-1

# Export volume as backup
docker run --rm -v lfs-build-volume:/data -v $(pwd):/backup \
  ubuntu tar czf /backup/lfs-backup.tar.gz /data
```

### Resume After Interruption

```bash
# Restart stopped container
docker start -i lfs-12.4

# Or start new container from saved image
docker run -it \
  -v lfs-build-volume:/mnt/lfs \
  lfs-builder:12.4-progress-1
```

### Parallel Builds

Build multiple LFS versions simultaneously:

```bash
# Build 1: systemd version
docker run -it --name lfs-systemd \
  -v lfs-systemd-vol:/mnt/lfs \
  lfs-builder:12.4

# Build 2: sysvinit version
docker run -it --name lfs-sysvinit \
  -v lfs-sysvinit-vol:/mnt/lfs \
  lfs-builder:12.4
```

## Exporting Your Build

Once complete, extract the built system:

```bash
# Export the LFS filesystem
docker run --rm \
  -v lfs-build-volume:/mnt/lfs \
  -v $(pwd):/output \
  ubuntu:24.04 \
  bash -c "cd /mnt/lfs && tar czf /output/lfs-system.tar.gz ."

# Create bootable ISO (requires additional tools)
# See: https://www.linuxfromscratch.org/hints/downloads/files/lfs-livecd.txt
```

## Testing Your Build

You can't directly boot from Docker, but you can:

1. **Export to VM**
   ```bash
   # Extract to VM disk image
   # Convert to QEMU/VirtualBox format
   ```

2. **Test in Chroot**
   ```bash
   # Inside container, enter chroot
   chroot "$LFS" /usr/bin/env -i \
     HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
     PATH=/bin:/usr/bin:/sbin:/usr/sbin \
     /bin/bash --login

   # Test basic commands
   ls /
   uname -a
   gcc --version
   ```

3. **Extract and Boot in QEMU**
   ```bash
   # Convert to bootable QEMU image
   # See scripts/export-to-qemu.sh (coming soon)
   ```

## Automation

### Automated Build Script

Create `scripts/docker/automated-build.sh`:

```bash
#!/bin/bash
# Automated LFS build in Docker
# WARNING: This takes 4-12 hours!

set -e

LFS=/mnt/lfs
export LFS

# Source package list
wget https://www.linuxfromscratch.org/lfs/view/stable/wget-list

# Download all packages
wget --input-file=wget-list --continue --directory-prefix=$LFS/sources

# Verify checksums
cd $LFS/sources
wget https://www.linuxfromscratch.org/lfs/view/stable/md5sums
md5sum -c md5sums

# Continue with automated compilation
# (See ALFS project for full automation)
```

## Troubleshooting

### Container Runs Out of Memory

```bash
# Increase memory allocation
docker run -it --memory="16g" ...
```

### Disk Space Issues

```bash
# Check volume usage
docker system df -v

# Clean up
docker system prune -a --volumes
```

### Build Fails at Specific Package

```bash
# Save current state
docker commit lfs-12.4 lfs-builder:12.4-checkpoint

# Investigate logs
# Fix issue
# Resume build
```

### Permission Errors

```bash
# Inside container, ensure correct ownership
chown -R lfs:lfs $LFS/sources
```

## Advanced: Multi-stage Build

For a truly automated Docker-based LFS:

```dockerfile
# Stage 1: Build toolchain
FROM ubuntu:24.04 AS toolchain
# ... build cross-toolchain ...

# Stage 2: Build system
FROM toolchain AS system
# ... build LFS system ...

# Stage 3: Final image
FROM scratch
COPY --from=system /mnt/lfs /
CMD ["/bin/bash"]
```

See [ALFS project](https://www.linuxfromscratch.org/alfs/) for fully automated builds.

## References

- [LFS Book](https://www.linuxfromscratch.org/lfs/view/stable/)
- [Docker Documentation](https://docs.docker.com/)
- [LFS Docker Projects on GitHub](https://github.com/search?q=lfs+docker)
- [ALFS (Automated LFS)](https://www.linuxfromscratch.org/alfs/)

## Next Steps

After completing your Docker-based LFS build:

1. Test the system in a VM
2. Add BLFS packages for a complete desktop
3. Create bootable ISO
4. Automate the entire process

Happy building!
