# Arch Linux Host Setup for LFS

Guide for preparing Arch Linux as an LFS build host.

## Why Arch for LFS?

**Advantages:**
- Rolling release - Always up-to-date toolchain
- Minimal base system - Less interference
- Excellent documentation (ArchWiki)
- Package management philosophy similar to LFS
- Great for learning

**Considerations:**
- May have cutting-edge versions (sometimes too new)
- Requires more Linux knowledge
- Updates can occasionally break builds

## Prerequisites

- Arch Linux installed and updated
- Minimum 40GB free disk space
- 8GB RAM (16GB recommended)
- Internet connection
- Root/sudo access

## Step 1: Update System

```bash
sudo pacman -Syu
```

## Step 2: Install Build Requirements

Install base development tools:

```bash
sudo pacman -S --needed base-devel

# Additional LFS requirements
sudo pacman -S --needed \
  bash \
  binutils \
  bison \
  bzip2 \
  coreutils \
  diffutils \
  findutils \
  gawk \
  gcc \
  grep \
  gzip \
  m4 \
  make \
  patch \
  perl \
  python \
  sed \
  tar \
  texinfo \
  xz \
  wget \
  vim \
  git \
  ncurses \
  flex \
  bc \
  openssl \
  elfutils
```

## Step 3: Verify Host System

Create version check script:

```bash
cat > version-check.sh << "EOF"
#!/bin/bash
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
makeinfo --version | head -n1
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

## Step 4: Handle Arch-Specific Issues

### Fix /bin/sh Symlink

Arch uses bash by default, but verify:

```bash
ls -l /bin/sh
# Should point to bash

# If it doesn't:
sudo ln -sf /bin/bash /bin/sh
```

### Create Missing Symlinks

Some LFS scripts expect traditional paths:

```bash
# These may be needed depending on your Arch setup
if [ ! -e /bin/awk ]; then
  sudo ln -s /usr/bin/awk /bin/awk
fi

if [ ! -e /bin/yacc ]; then
  sudo ln -s /usr/bin/bison /bin/yacc
fi
```

### Handle /usr Merge

Arch uses merged /usr (no separate /bin, /sbin):

```bash
# This is fine - LFS will create its own structure
# Just be aware when following book instructions
```

## Step 5: Prepare Disk Space

### Option A: Dedicated Partition

```bash
# List disks
lsblk

# Create partition with fdisk, gdisk, or parted
sudo fdisk /dev/sdX

# Format
sudo mkfs.ext4 /dev/sdX1

# Mount
export LFS=/mnt/lfs
sudo mkdir -p $LFS
sudo mount /dev/sdX1 $LFS

# Add to /etc/fstab
echo '/dev/sdX1 /mnt/lfs ext4 defaults 0 0' | sudo tee -a /etc/fstab
```

### Option B: Btrfs Subvolume (Arch-Style)

If using Btrfs:

```bash
export LFS=/mnt/lfs
sudo btrfs subvolume create $LFS

# Snapshots for easy rollback
sudo btrfs subvolume snapshot $LFS $LFS-backup
```

### Option C: Loop Device

```bash
# Create 30GB image
dd if=/dev/zero of=~/lfs-disk.img bs=1G count=30

# Format
sudo mkfs.ext4 ~/lfs-disk.img

# Mount
export LFS=/mnt/lfs
sudo mkdir -p $LFS
sudo mount -o loop ~/lfs-disk.img $LFS
```

## Step 6: Set Up Environment

Add to `~/.bashrc`:

```bash
# LFS Build Environment
export LFS=/mnt/lfs
export LC_ALL=POSIX
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH
export CONFIG_SITE=$LFS/usr/share/config.site
export MAKEFLAGS="-j$(nproc)"
```

Source it:

```bash
source ~/.bashrc
```

## Step 7: Create Directory Structure

```bash
sudo mkdir -pv $LFS/{sources,tools,boot,etc,bin,lib,sbin,usr,var}

case $(uname -m) in
  x86_64) sudo mkdir -pv $LFS/lib64 ;;
esac

sudo mkdir -pv $LFS/tools
```

## Step 8: Create LFS User

```bash
sudo groupadd lfs
sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs
sudo passwd lfs

# Grant ownership
sudo chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) sudo chown -v lfs $LFS/lib64 ;;
esac

sudo chown -v lfs $LFS/sources
```

Configure lfs user:

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

## Step 9: Download Sources

```bash
cd $LFS/sources

# Download package list
wget https://www.linuxfromscratch.org/lfs/view/stable/wget-list

# Download all packages
wget --input-file=wget-list --continue

# Download checksums
wget https://www.linuxfromscratch.org/lfs/view/stable/md5sums

# Verify
md5sum -c md5sums
```

## Arch-Specific Optimizations

### Use ccache

```bash
sudo pacman -S ccache

# Add to ~/.bashrc
export PATH="/usr/lib/ccache/bin:$PATH"
```

### Enable Parallel Compilation

Arch handles parallel builds well:

```bash
# In ~/.bashrc
export MAKEFLAGS="-j$(nproc)"
```

### Use tmpfs for Fast Builds

If you have 32GB+ RAM:

```bash
sudo mount -t tmpfs -o size=20G tmpfs $LFS/sources
# Or add to /etc/fstab:
# tmpfs /mnt/lfs/sources tmpfs size=20G 0 0
```

### Modern CPU Optimizations

Arch systems often have modern CPUs. Use native optimizations:

```bash
# Add to package build flags (when LFS allows)
export CFLAGS="-march=native -O2 -pipe"
export CXXFLAGS="$CFLAGS"
```

**Warning**: Only use during builds, not in bootstrap toolchain!

## Troubleshooting

### GCC Version Too New

If LFS book expects older GCC:

```bash
# Install older GCC from AUR if needed
yay -S gcc10  # or appropriate version

# Use specific version
export CC=gcc-10
export CXX=g++-10
```

### Python2 vs Python3

Arch defaults to Python 3:

```bash
# If LFS requires python2
sudo pacman -S python2

# Create symlink if needed
sudo ln -s /usr/bin/python2 /usr/bin/python
```

### Missing Libraries

```bash
# Install library packages
sudo pacman -S gmp mpfr libmpc isl

# Development headers usually included
```

### Filesystem Permissions

```bash
# Reset permissions
sudo chown -R lfs:lfs $LFS/sources $LFS/tools
sudo chmod -R u+w $LFS/sources
```

### /tools Symlink Issues

Arch uses /usr merge, so `/tools` doesn't exist by default:

```bash
# Create /tools for LFS
sudo mkdir /tools
sudo chown -v lfs:lfs /tools
```

## Arch-Specific Tips

### Snapshot with Btrfs

If using Btrfs:

```bash
# Snapshot before major steps
sudo btrfs subvolume snapshot $LFS $LFS-ch5-complete
sudo btrfs subvolume snapshot $LFS $LFS-ch6-complete

# Rollback if needed
sudo btrfs subvolume delete $LFS
sudo btrfs subvolume snapshot $LFS-ch5-complete $LFS
```

### Package Cache

Keep downloaded sources:

```bash
# Arch's package cache
ls /var/cache/pacman/pkg/

# Don't need to redownload if rebuilding
```

### AUR Helpers

Some tools available in AUR:

```bash
# Install yay or paru
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Useful AUR packages
yay -S alfs  # Automated LFS scripts
```

## Performance on Arch

Arch systems are typically fast for LFS:

- Rolling release = Latest compilers
- Minimal base = Less resource usage
- Good defaults = Optimal performance

**Expected build time:** 3-6 hours on modern hardware

## Compatibility Notes

### LFS 12.4 with Arch (2025)

**Compatible:**
- GCC 14+ (Arch has 14.2)
- Binutils 2.43+ (Arch has latest)
- Python 3.12+ (Arch has 3.12)
- All other tools current

**Potential Issues:**
- Extremely new versions may have incompatibilities
- Check LFS errata page
- Consider downgrading specific packages if needed

### Using Arch Testing Repository

**Not recommended** during LFS build:

```bash
# Stick to stable repos
# Avoid [testing] during build
```

## Next Steps

You're ready to build! Follow the LFS book from Chapter 5:

1. Build cross-toolchain
2. Build temporary tools
3. Enter chroot
4. Build final system

## References

- [LFS Book](https://www.linuxfromscratch.org/lfs/view/stable/)
- [Arch Wiki - Linux From Scratch](https://wiki.archlinux.org/)
- [LFS Host Requirements](https://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html)

Happy building, Arch style!
