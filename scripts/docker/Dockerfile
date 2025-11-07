# LFS Build Environment Dockerfile
# Based on Ubuntu 24.04 LTS
# For LFS 12.4

FROM ubuntu:24.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Update and install all required packages for LFS host system
# Note: Package names are for Ubuntu/Debian. Other distributions may use different names:
#   - libncurses-dev (Debian/Ubuntu) vs ncurses-devel (RPM-based)
#   - libssl-dev (Debian/Ubuntu) vs openssl-devel (RPM-based)
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
# Note: No password is set for security. Use 'docker exec' or 'su - lfs' as root to access.
RUN groupadd lfs && \
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs && \
    chown -v lfs ${LFS}/{sources,tools,boot,etc,bin,lib,sbin,usr,var,lib64}

# Set up lfs user environment
USER lfs
WORKDIR /home/lfs

# Create .bash_profile for lfs user
RUN cat > ~/.bash_profile << 'EOF'
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

# Create .bashrc for lfs user
RUN cat > ~/.bashrc << 'EOF'
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS="-j$(nproc)"
EOF

# Switch back to root for final setup
USER root

# Create volume mount point for persistent LFS build
VOLUME ["${LFS}"]

# Set working directory
WORKDIR ${LFS}

# Create helper script: lfs-shell
RUN cat > /usr/local/bin/lfs-shell << 'EOF' && chmod +x /usr/local/bin/lfs-shell
#!/bin/bash
su - lfs
EOF

# Create helper script: download-sources
RUN cat > /usr/local/bin/download-sources << 'EOF' && chmod +x /usr/local/bin/download-sources
#!/bin/bash
cd ${LFS}/sources
wget https://www.linuxfromscratch.org/lfs/view/stable/wget-list
wget --input-file=wget-list --continue --directory-prefix=${LFS}/sources
wget https://www.linuxfromscratch.org/lfs/view/stable/md5sums
md5sum -c md5sums
EOF

# Create helper script: welcome message
RUN cat > /usr/local/bin/welcome << 'EOF' && chmod +x /usr/local/bin/welcome
#!/bin/bash
echo "=========================================="
echo "LFS 12.4 Build Environment"
echo "=========================================="
echo ""
echo "Quick start:"
echo "  1. Download sources: download-sources"
echo "  2. Switch to lfs user: lfs-shell"
echo "  3. Follow LFS book from Chapter 5"
echo ""
echo "LFS Book: https://www.linuxfromscratch.org/lfs/view/stable/"
echo ""
echo "Environment:"
echo "  LFS=${LFS}"
echo "  LFS_TGT=${LFS_TGT}"
echo "  MAKEFLAGS=${MAKEFLAGS}"
echo ""
echo "Note: lfs user has no password. Access via 'lfs-shell' as root."
echo ""
EOF

# Set entrypoint to show welcome message
ENTRYPOINT ["/bin/bash", "-c", "welcome && exec /bin/bash"]

# Metadata
LABEL maintainer="LFS Build Team"
LABEL description="Linux From Scratch 12.4 build environment based on Ubuntu 24.04"
LABEL version="12.4"
