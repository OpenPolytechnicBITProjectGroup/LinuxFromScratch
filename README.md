# Linux From Scratch (LFS) Build Documentation

A comprehensive repository for building a custom Linux operating system from scratch, with support for modern host systems, containerized builds, and multiple init system options.

## Overview

**Linux From Scratch (LFS)** is an educational project that guides you through building your own custom Linux distribution from source code. This repository provides documentation, guides, and resources to help you complete an LFS build using modern tools and approaches.

### What You'll Learn

- How Linux systems are built from the ground up
- The purpose and interaction of core system components
- Compiler toolchains, cross-compilation, and bootstrapping
- Package management and dependency resolution
- Init systems (systemd vs sysvinit)
- System configuration and optimization

## Current LFS Version

This repository is being updated to support **LFS 12.4** (released September 2025).

**Included Resources:**
- LFS Book 8.1 (systemd) - Historical reference (see `LFS-BOOK-8.1-systemd.pdf`)
- Installation guides for various approaches
- Modern build documentation

**Latest Version:** [LFS 12.4](https://www.linuxfromscratch.org/lfs/view/stable/) (released September 1, 2025) includes:
- Linux Kernel 6.15.1
- GCC 15.2
- Glibc 2.42
- Binutils 2.45
- Python 3.13.7

## Build Approaches

### 1. Modern Docker/Container Build (Recommended)

Build LFS in an isolated, reproducible container environment.

**Advantages:**
- Clean, isolated build environment
- Works on any system with Docker
- Reproducible builds
- Parallel builds supported
- Easy to reset and retry

**Requirements:**
- Docker or Podman installed
- 8GB+ RAM recommended
- 30GB+ disk space
- Multi-core CPU (4+ cores recommended)

**Quick Start:**
```bash
# Documentation coming soon
# See docs/docker-build.md (planned)
```

### 2. Native Host System Build

Build directly on a Linux host system.

**Supported Host Systems:**

#### Modern Distributions (Recommended)
- **Ubuntu 22.04/24.04 LTS** - Excellent package availability
- **Arch Linux** - Rolling release, always current
- **Fedora 39+** - Modern toolchain
- **Debian 12+** - Stable and well-tested

#### Legacy Support
- **Slackware** - Original approach (see `Install on VMWare (basic)`)

**Host Requirements:**
- Bash 3.2+
- Binutils 2.13.1+
- Bison 2.7+
- Coreutils 8.1+
- GCC 5.2+ (with C and C++ support)
- Gawk 4.0.1+
- Make 4.0+
- Patch 2.5.4+
- Perl 5.8.8+
- Python 3.4+
- Tar 1.22+
- Texinfo 5.0+

See [LFS Host Requirements](https://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html) for the complete list.

### 3. Virtual Machine Build

Build in a VM for isolation and experimentation.

**Supported Platforms:**
- VMWare Workstation/Player
- VirtualBox
- KVM/QEMU
- Hyper-V

**Recommended VM Specs:**
- 4+ CPU cores
- 8GB+ RAM
- 40GB+ disk space
- Enable hardware virtualization (VT-x/AMD-V)

## Init System Options

LFS supports two init systems - choose based on your needs:

### systemd (Recommended for Modern Systems)

**Advantages:**
- Parallel service startup (faster boot)
- Dependency-based activation
- Centralized logging (journald)
- Service monitoring and auto-restart
- Standard on most modern distributions
- Better hardware integration

**Use When:**
- You want modern features
- Performance is important
- You need compatibility with mainstream Linux

### sysvinit (Traditional)

**Advantages:**
- Simple and minimal (~10K lines of code)
- Easy to understand and debug
- Stable and predictable
- LSB (Linux Standards Base) compliant
- Fewer dependencies

**Use When:**
- You prefer simplicity
- You're learning init systems
- You want minimal dependencies
- You have legacy requirements

Both versions are documented in official LFS books available at [linuxfromscratch.org](https://www.linuxfromscratch.org/).

## Repository Structure

```
.
├── README.md                          # This file
├── LFS-BOOK-8.1-systemd.pdf          # Historical LFS 8.1 book
├── Install on VMWare (basic)          # Legacy Slackware/VMWare guide
├── docs/                              # Additional documentation (planned)
│   ├── docker-build.md                # Container-based build guide
│   ├── ubuntu-host-setup.md           # Ubuntu host preparation
│   ├── arch-host-setup.md             # Arch Linux host preparation
│   └── troubleshooting.md             # Common issues and solutions
├── scripts/                           # Build automation scripts (planned)
│   ├── host-check.sh                  # Verify host requirements
│   └── docker/                        # Docker build configurations
└── LICENSE                            # Project license
```

## Getting Started

### Step 1: Choose Your Approach

Decide between Docker (easiest), native host, or VM build.

### Step 2: Prepare Your Environment

**For Docker:**
```bash
# Install Docker
# See: https://docs.docker.com/get-docker/

# Verify installation
docker --version
```

**For Native Host (Ubuntu example):**
```bash
# Install required packages
sudo apt update
sudo apt install build-essential bison gawk texinfo

# Run host system check (script coming soon)
# ./scripts/host-check.sh
```

**For VM:**
- Set up VM with your preferred hypervisor
- Install a minimal Linux distribution
- Follow native host instructions

### Step 3: Download LFS Book

Get the latest LFS book for your chosen init system:

- **Systemd:** https://www.linuxfromscratch.org/lfs/view/stable-systemd/
- **Sysvinit:** https://www.linuxfromscratch.org/lfs/view/stable/

### Step 4: Follow the Build Process

The LFS book provides step-by-step instructions. Key phases:

1. **Prepare the Host** - Set up partitions and environment
2. **Build Temporary Toolchain** - Create minimal cross-compilation tools
3. **Build LFS System** - Compile all packages for final system
4. **Configure System** - Set up boot, networking, users
5. **Make Bootable** - Install bootloader (GRUB)

**Estimated Time:** 4-12 hours depending on hardware and experience

## Beyond LFS

Once you've built LFS, consider:

- **BLFS (Beyond Linux From Scratch)** - Add desktop environments, browsers, etc.
- **ALFS (Automated Linux From Scratch)** - Automate the build process
- **CLFS (Cross Linux From Scratch)** - Build for different architectures
- **Gentoo** - Source-based distribution with package management
- **NixOS** - Declarative system configuration

## Resources

### Official LFS Resources
- [LFS Homepage](https://www.linuxfromscratch.org/)
- [LFS Book (Stable)](https://www.linuxfromscratch.org/lfs/view/stable/)
- [LFS FAQ](https://www.linuxfromscratch.org/faq/)
- [LFS Mailing Lists](https://www.linuxfromscratch.org/mail.html)

### Community
- [LFS Forums](https://www.linuxquestions.org/questions/linux-from-scratch-13/)
- [r/linuxfromscratch](https://www.reddit.com/r/linuxfromscratch/)
- IRC: #lfs-support on Libera.Chat

### Alternative Educational Projects
- [Gentoo Linux](https://www.gentoo.org/) - Source-based with Portage
- [Arch Linux](https://archlinux.org/) - Build-it-yourself philosophy
- [NixOS](https://nixos.org/) - Declarative system configuration

## Contributing

Contributions welcome! Please feel free to:
- Submit issues for documentation improvements
- Share your build experiences and tips
- Add automation scripts
- Improve guides for different host systems

## License

This repository contains documentation and guides for educational purposes.

The LFS book is licensed under the [MIT License](https://www.linuxfromscratch.org/lfs/view/stable/prologue/license.html).

See [LICENSE](LICENSE) for details on other content in this repository.

## Acknowledgments

- The [Linux From Scratch](https://www.linuxfromscratch.org/) project and community
- All contributors to the LFS book and supporting projects
- Original Slackware-based approach documented in this repository

---

**Ready to build Linux from scratch? Start with the [official LFS book](https://www.linuxfromscratch.org/lfs/view/stable/) and dive in!**
