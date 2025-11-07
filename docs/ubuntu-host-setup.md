# Ubuntu Host Setup for LFS

Complete guide for preparing an Ubuntu system as an LFS build host.

## Supported Ubuntu Versions

- **Ubuntu 24.04 LTS (Noble)** - Recommended
- **Ubuntu 22.04 LTS (Jammy)** - Recommended
- **Ubuntu 23.10** - Supported
- **Ubuntu 20.04 LTS** - Minimum, may need updates

## Prerequisites

- Fresh Ubuntu installation (physical machine or VM)
- Minimum 40GB free disk space
- 8GB RAM (16GB recommended)
- Internet connection
- sudo/root access

## Step 1: Update System

```bash
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
```

## Step 2: Install Build Requirements

Install all required packages for LFS host system:

```bash
sudo apt install -y \
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
  libelf-dev
```

## Step 3: Verify Host System Requirements

Create a version check script:

```bash
cat > version-check.sh << "EOF"
#!/bin/bash
# Simple script to list version numbers of critical development tools
export LC_ALL=C

bash --version | head -n1 | cut -d" " -f2-4
MYSH=$(readlink -f /bin/sh)
echo "/bin/sh -> $MYSH"
echo $MYSH | grep -q bash || echo "ERROR: /bin/sh does not point to bash"
unset MYSH

echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
bison --version | head -n1

if [ -h /usr/bin/yacc ]; then
  echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
elif [ -x /usr/bin/yacc ]; then
  echo yacc is `/usr/bin/yacc --version | head -n1`
else
  echo "yacc not found"
fi

echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1

if [ -h /usr/bin/awk ]; then
  echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
elif [ -x /usr/bin/awk ]; then
  echo awk is `/usr/bin/awk --version | head -n1`
else
  echo "awk not found"
fi

gcc --version | head -n1
g++ --version | head -n1
grep --version | head -n1
gzip --version | head -n1
cat /proc/version
m4 --version | head -n1
make --version | head -n1
patch --version | head -n1
echo Perl `perl -V:version`
python3 --version
sed --version | head -n1
tar --version | head -n1
makeinfo --version | head -n1  # texinfo version
xz --version | head -n1

echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
if [ -x dummy ]
  then echo "g++ compilation OK";
  else echo "g++ compilation failed"; fi
rm -f dummy.c dummy
EOF

chmod +x version-check.sh
./version-check.sh
```

All versions should meet or exceed LFS requirements. If any fail, see Troubleshooting section.

## Step 4: Prepare Disk Space

### Option A: Use Existing Partition

```bash
# Create LFS directory
export LFS=/mnt/lfs
sudo mkdir -pv $LFS

# Make it writable (temporary)
sudo chmod 777 $LFS
```

### Option B: Create New Partition (Recommended)

If building on a system with free space:

```bash
# List disks
lsblk

# Example: Using /dev/sdb as LFS disk
# Create partition
sudo fdisk /dev/sdb
# Commands: n (new), p (primary), 1, [enter], [enter], w (write)

# Format as ext4
sudo mkfs.ext4 /dev/sdb1

# Mount
export LFS=/mnt/lfs
sudo mkdir -pv $LFS
sudo mount -v -t ext4 /dev/sdb1 $LFS

# Make persistent across reboots
echo '/dev/sdb1 /mnt/lfs ext4 defaults 1 1' | sudo tee -a /etc/fstab
```

### Option C: Use Loop Device (Testing)

For testing without a dedicated partition:

```bash
# Create 30GB disk image
dd if=/dev/zero of=lfs-disk.img bs=1G count=30

# Create filesystem
sudo mkfs.ext4 lfs-disk.img

# Mount as loop device
export LFS=/mnt/lfs
sudo mkdir -pv $LFS
sudo mount -o loop lfs-disk.img $LFS
```

## Step 5: Set Up Environment

Add to your `~/.bashrc`:

```bash
# LFS Environment Variables
export LFS=/mnt/lfs
export LC_ALL=POSIX
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH
export CONFIG_SITE=$LFS/usr/share/config.site
export MAKEFLAGS="-j$(nproc)"
```

Reload:

```bash
source ~/.bashrc
echo $LFS  # Should show /mnt/lfs
```

## Step 6: Create Directory Structure

```bash
sudo mkdir -pv $LFS/{sources,tools,boot,etc,bin,lib,sbin,usr,var}

case $(uname -m) in
  x86_64) sudo mkdir -pv $LFS/lib64 ;;
esac

# Create cross-compiler location
sudo mkdir -pv $LFS/tools
```

## Step 7: Create LFS User

Create a dedicated user for building:

```bash
sudo groupadd lfs
sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs
sudo passwd lfs  # Set password

# Grant ownership
sudo chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) sudo chown -v lfs $LFS/lib64 ;;
esac

sudo chown -v lfs $LFS/sources
```

Set up lfs user environment:

```bash
sudo su - lfs

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
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

source ~/.bash_profile
```

## Step 8: Download Sources

As the `lfs` user:

```bash
cd $LFS/sources

# Download package list
wget https://www.linuxfromscratch.org/lfs/view/stable/wget-list

# Download all sources
wget --input-file=wget-list --continue --directory-prefix=$LFS/sources

# Download checksums
wget https://www.linuxfromscratch.org/lfs/view/stable/md5sums

# Verify integrity
md5sum -c md5sums
```

## Step 9: Ready to Build!

You're now ready to follow the LFS book:

```bash
# Start from Chapter 5
# https://www.linuxfromscratch.org/lfs/view/stable/chapter05/chapter05.html
```

## Optimizations for Ubuntu

### Use All CPU Cores

Ubuntu typically has good multi-core support:

```bash
export MAKEFLAGS="-j$(nproc)"
```

### Use ccache (Optional)

Speed up recompilation:

```bash
sudo apt install ccache
export PATH="/usr/lib/ccache:$PATH"
```

### RAM Disk for Sources (Optional)

If you have 32GB+ RAM:

```bash
# Create 20GB tmpfs
sudo mkdir -p /mnt/ramdisk
sudo mount -t tmpfs -o size=20G tmpfs /mnt/ramdisk

# Copy sources
cp -a $LFS/sources/* /mnt/ramdisk/
export LFS_SOURCES=/mnt/ramdisk
```

## Troubleshooting

### /bin/sh Not Pointing to Bash

```bash
sudo dpkg-reconfigure dash
# Select "No" to use bash as /bin/sh
```

### Missing symlinks

```bash
sudo ln -sf /usr/bin/awk /bin/awk
sudo ln -sf /usr/bin/yacc /bin/yacc
```

### Insufficient Disk Space

```bash
# Clean apt cache
sudo apt clean

# Remove old kernels
sudo apt autoremove --purge

# Check space
df -h $LFS
```

### Permission Denied Errors

```bash
# Ensure lfs user owns directories
sudo chown -R lfs:lfs $LFS/sources
sudo chown -R lfs:lfs $LFS/tools
```

### Build Failures Due to Missing Dependencies

```bash
# Install additional development packages
sudo apt install -y linux-headers-$(uname -r)
sudo apt install -y libgmp-dev libmpfr-dev libmpc-dev
```

## Ubuntu-Specific Notes

### 24.04 LTS Considerations

- Uses GCC 13 by default (perfect for LFS 12.4)
- Python 3.12 is default (compatible)
- Modern binutils 2.42 (meets requirements)

### 22.04 LTS Considerations

- Uses GCC 11 (meets minimum requirements)
- May need to update some packages
- Very stable for LFS builds

### WSL2 (Windows Subsystem for Linux)

LFS can be built on WSL2 Ubuntu:

```bash
# Install Ubuntu 24.04 from Microsoft Store

# Enable systemd (if needed)
sudo -e /etc/wsl.conf
# Add:
# [boot]
# systemd=true

# Restart WSL
wsl --shutdown
```

**Note**: Cannot test bootloader on WSL2. Use VM for final boot testing.

## Performance Tips

1. **Use SSD** - Much faster than HDD
2. **Close unnecessary apps** - Free up RAM
3. **Disable unnecessary services** - Save CPU cycles
4. **Use `nice` for background builds** - Don't freeze desktop

```bash
# Run builds with lower priority
nice -n 19 make -j$(nproc)
```

## Next Steps

After setup:
1. Follow LFS book from Chapter 5
2. Build cross-toolchain
3. Build temporary tools
4. Enter chroot
5. Build final system

Expected build time on modern Ubuntu system: **4-8 hours**

## References

- [LFS Host Requirements](https://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html)
- [Ubuntu Documentation](https://help.ubuntu.com/)
- [LFS FAQ](https://www.linuxfromscratch.org/faq/)

Good luck with your build!
