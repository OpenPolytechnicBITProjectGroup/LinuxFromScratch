# LFS Build Environment Dockerfile
# Based on Ubuntu 24.04 LTS
# For LFS 12.4

FROM ubuntu:24.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Update and install all required packages for LFS host system
RUN apt-get update && apt-get install -y \
    bash \
    binutils \
    bison \
    bzip2 \
    coreutils \
    diffutils \
    findutils \
    gawk \
    gcc \
    g++ \
    grep \
    gzip \
    m4 \
    make \
    patch \
    perl \
    python3 \
    sed \
    tar \
    texinfo \
    xz-utils \
    wget \
    vim \
    build-essential \
    git \
    libncurses-dev \
    flex \
    bc \
    libssl-dev \
    libelf-dev \
    file \
    less \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set up LFS environment variables
ENV LFS=/mnt/lfs
ENV LC_ALL=POSIX
ENV LFS_TGT=x86_64-lfs-linux-gnu
ENV PATH=/tools/bin:${LFS}/tools/bin:/usr/bin:/bin
ENV CONFIG_SITE=${LFS}/usr/share/config.site

# Enable parallel compilation (adjust based on available cores)
ENV MAKEFLAGS="-j$(nproc)"

# Create LFS directory structure
RUN mkdir -pv ${LFS}/{sources,tools,boot,etc,bin,lib,sbin,usr,var} && \
    mkdir -pv ${LFS}/lib64 && \
    mkdir -pv ${LFS}/usr/{bin,lib,sbin}

# Create lfs user and group
RUN groupadd lfs && \
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs && \
    echo "lfs:lfs" | chpasswd && \
    chown -v lfs ${LFS}/{sources,tools,boot,etc,bin,lib,sbin,usr,var,lib64}

# Set up lfs user environment
USER lfs
WORKDIR /home/lfs

RUN echo 'exec env -i HOME=$HOME TERM=$TERM PS1='"'"'\u:\w\$ '"'"' /bin/bash' > ~/.bash_profile && \
    echo 'set +h' > ~/.bashrc && \
    echo 'umask 022' >> ~/.bashrc && \
    echo 'LFS=/mnt/lfs' >> ~/.bashrc && \
    echo 'LC_ALL=POSIX' >> ~/.bashrc && \
    echo 'LFS_TGT=$(uname -m)-lfs-linux-gnu' >> ~/.bashrc && \
    echo 'PATH=/usr/bin' >> ~/.bashrc && \
    echo 'if [ ! -L /bin ]; then PATH=/bin:$PATH; fi' >> ~/.bashrc && \
    echo 'PATH=$LFS/tools/bin:$PATH' >> ~/.bashrc && \
    echo 'CONFIG_SITE=$LFS/usr/share/config.site' >> ~/.bashrc && \
    echo 'export LFS LC_ALL LFS_TGT PATH CONFIG_SITE' >> ~/.bashrc && \
    echo 'export MAKEFLAGS="-j$(nproc)"' >> ~/.bashrc

# Switch back to root for final setup
USER root

# Create volume mount point for persistent LFS build
VOLUME ["${LFS}"]

# Set working directory
WORKDIR ${LFS}

# Create helper scripts
RUN echo '#!/bin/bash' > /usr/local/bin/lfs-shell && \
    echo 'su - lfs' >> /usr/local/bin/lfs-shell && \
    chmod +x /usr/local/bin/lfs-shell

RUN echo '#!/bin/bash' > /usr/local/bin/download-sources && \
    echo 'cd ${LFS}/sources' >> /usr/local/bin/download-sources && \
    echo 'wget https://www.linuxfromscratch.org/lfs/view/stable/wget-list' >> /usr/local/bin/download-sources && \
    echo 'wget --input-file=wget-list --continue --directory-prefix=${LFS}/sources' >> /usr/local/bin/download-sources && \
    echo 'wget https://www.linuxfromscratch.org/lfs/view/stable/md5sums' >> /usr/local/bin/download-sources && \
    echo 'md5sum -c md5sums' >> /usr/local/bin/download-sources && \
    chmod +x /usr/local/bin/download-sources

# Create welcome message
RUN echo '#!/bin/bash' > /usr/local/bin/welcome && \
    echo 'echo "=========================================="' >> /usr/local/bin/welcome && \
    echo 'echo "LFS 12.4 Build Environment"' >> /usr/local/bin/welcome && \
    echo 'echo "=========================================="' >> /usr/local/bin/welcome && \
    echo 'echo ""' >> /usr/local/bin/welcome && \
    echo 'echo "Quick start:"' >> /usr/local/bin/welcome && \
    echo 'echo "  1. Download sources: download-sources"' >> /usr/local/bin/welcome && \
    echo 'echo "  2. Switch to lfs user: lfs-shell"' >> /usr/local/bin/welcome && \
    echo 'echo "  3. Follow LFS book from Chapter 5"' >> /usr/local/bin/welcome && \
    echo 'echo ""' >> /usr/local/bin/welcome && \
    echo 'echo "LFS Book: https://www.linuxfromscratch.org/lfs/view/stable/"' >> /usr/local/bin/welcome && \
    echo 'echo ""' >> /usr/local/bin/welcome && \
    echo 'echo "Environment:"' >> /usr/local/bin/welcome && \
    echo 'echo "  LFS=${LFS}"' >> /usr/local/bin/welcome && \
    echo 'echo "  LFS_TGT=${LFS_TGT}"' >> /usr/local/bin/welcome && \
    echo 'echo "  MAKEFLAGS=${MAKEFLAGS}"' >> /usr/local/bin/welcome && \
    echo 'echo ""' >> /usr/local/bin/welcome && \
    chmod +x /usr/local/bin/welcome

# Set entrypoint to show welcome message
ENTRYPOINT ["/bin/bash", "-c", "welcome && exec /bin/bash"]

# Metadata
LABEL maintainer="LFS Build Team"
LABEL description="Linux From Scratch 12.4 build environment based on Ubuntu 24.04"
LABEL version="12.4"
