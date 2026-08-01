#!/bin/bash
# LFS Host System Requirements Checker
# Based on LFS 12.4 requirements
# https://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html

# Note: Not using 'set -e' because we want to collect all errors before exiting

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "LFS Host System Requirements Checker"
echo "LFS Version: 12.4"
echo "======================================"
echo ""

# Track failures
FAILURES=0
WARNINGS=0

check_command() {
    local cmd="$1"
    local min_version="$2"
    local version_flag="${3:---version}"

    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}[FAIL]${NC} $cmd not found"
        ((FAILURES++))
        return 1
    fi

    echo -e "${GREEN}[PASS]${NC} $cmd found"

    # Show version
    if [ "$version_flag" != "none" ]; then
        version_output=$("$cmd" "$version_flag" 2>&1 | head -n1)
        echo "       Version: $version_output"
    fi

    return 0
}

check_version() {
    local name=$1
    local current=$2
    local minimum=$3

    # Simple version comparison (works for most cases)
    if [ "$(printf '%s\n' "$minimum" "$current" | sort -V | head -n1)" = "$minimum" ]; then
        echo -e "${GREEN}[PASS]${NC} $name version $current >= $minimum"
    else
        echo -e "${YELLOW}[WARN]${NC} $name version $current may be too old (minimum: $minimum)"
        ((WARNINGS++))
    fi
}

# Check Bash
echo "Checking Bash..."
check_command bash "3.2"
bash_version=$(bash --version | head -n1 | grep -oP '\d+\.\d+\.\d+' | head -n1)
check_version "Bash" "$bash_version" "3.2"

# Check /bin/sh
echo ""
echo "Checking /bin/sh symlink..."
sh_target=$(readlink -f /bin/sh)
if [[ $sh_target == *bash* ]]; then
    echo -e "${GREEN}[PASS]${NC} /bin/sh -> $sh_target (bash)"
else
    echo -e "${RED}[FAIL]${NC} /bin/sh -> $sh_target (not bash!)"
    echo "       Run: sudo ln -sf /bin/bash /bin/sh"
    ((FAILURES++))
fi

# Check Binutils
echo ""
echo "Checking Binutils..."
check_command ld "2.13.1"

# Check Bison
echo ""
echo "Checking Bison..."
check_command bison "2.7"

# Check Coreutils
echo ""
echo "Checking Coreutils..."
check_command chown "8.1"

# Check Diffutils
echo ""
echo "Checking Diffutils..."
check_command diff "2.8.1"

# Check Findutils
echo ""
echo "Checking Findutils..."
check_command find "4.2.31"

# Check Gawk
echo ""
echo "Checking Gawk..."
check_command gawk "4.0.1"

# Check GCC
echo ""
echo "Checking GCC..."
check_command gcc "5.2"
gcc_version=$(gcc --version | head -n1 | grep -oP '\d+\.\d+\.\d+' | head -n1)
check_version "GCC" "$gcc_version" "5.2"

# Check G++
echo ""
echo "Checking G++..."
check_command g++ "5.2"

# Test g++ compilation
echo ""
echo "Testing g++ compilation..."
echo 'int main(){}' > /tmp/dummy.c
if g++ -o /tmp/dummy /tmp/dummy.c 2>/dev/null; then
    echo -e "${GREEN}[PASS]${NC} g++ can compile C++ code"
    rm -f /tmp/dummy.c /tmp/dummy
else
    echo -e "${RED}[FAIL]${NC} g++ compilation failed"
    ((FAILURES++))
    rm -f /tmp/dummy.c
fi

# Check Grep
echo ""
echo "Checking Grep..."
check_command grep "2.5.1a"

# Check Gzip
echo ""
echo "Checking Gzip..."
check_command gzip "1.3.12"

# Check M4
echo ""
echo "Checking M4..."
check_command m4 "1.4.10"

# Check Make
echo ""
echo "Checking Make..."
check_command make "4.0"

# Check Patch
echo ""
echo "Checking Patch..."
check_command patch "2.5.4"

# Check Perl
echo ""
echo "Checking Perl..."
check_command perl "5.8.8"

# Check Python
echo ""
echo "Checking Python..."
check_command python3 "3.4"

# Check Sed
echo ""
echo "Checking Sed..."
check_command sed "4.1.5"

# Check Tar
echo ""
echo "Checking Tar..."
check_command tar "1.22"

# Check Texinfo
echo ""
echo "Checking Texinfo..."
check_command makeinfo "5.0"

# Check Xz
echo ""
echo "Checking Xz..."
check_command xz "5.0.0"

# Check kernel version
echo ""
echo "Checking Linux kernel..."
kernel_version=$(uname -r | grep -oP '^\d+\.\d+')
echo "Kernel version: $kernel_version"
if [ "$(printf '%s\n' "4.19" "$kernel_version" | sort -V | head -n1)" = "4.19" ]; then
    echo -e "${GREEN}[PASS]${NC} Kernel version $kernel_version >= 4.19"
else
    echo -e "${RED}[FAIL]${NC} Kernel version $kernel_version < 4.19 (minimum)"
    ((FAILURES++))
fi

# Check optional but recommended tools
echo ""
echo "======================================"
echo "Optional but Recommended Tools"
echo "======================================"

# These are optional, so don't increment failure counter
check_command wget "" 2>/dev/null || echo -e "${YELLOW}[INFO]${NC} wget not found (recommended for downloading sources)"
check_command vim "" 2>/dev/null || echo -e "${YELLOW}[INFO]${NC} vim not found (recommended for editing)"
check_command git "" 2>/dev/null || echo -e "${YELLOW}[INFO]${NC} git not found (optional for version control)"

# Check system resources
echo ""
echo "======================================"
echo "System Resources"
echo "======================================"

# Check CPU cores
cpu_cores=$(nproc)
echo "CPU cores: $cpu_cores"
if [ "$cpu_cores" -ge 4 ]; then
    echo -e "${GREEN}[GOOD]${NC} 4+ cores available (recommended)"
else
    echo -e "${YELLOW}[WARN]${NC} Less than 4 cores (build will be slower)"
    ((WARNINGS++))
fi

# Check RAM
total_ram=$(free -g | awk '/^Mem:/{print $2}')
echo "Total RAM: ${total_ram}GB"
if [ "$total_ram" -ge 8 ]; then
    echo -e "${GREEN}[GOOD]${NC} 8GB+ RAM available (recommended)"
else
    echo -e "${YELLOW}[WARN]${NC} Less than 8GB RAM (may need swap)"
    ((WARNINGS++))
fi

# Check disk space at $LFS or suggest location
if [ -n "$LFS" ] && [ -d "$LFS" ]; then
    disk_space=$(df -BG "$LFS" | tail -1 | awk '{print $4}' | sed 's/G//')
    echo "Disk space at \$LFS ($LFS): ${disk_space}GB available"
    if [ "$disk_space" -ge 30 ]; then
        echo -e "${GREEN}[GOOD]${NC} 30GB+ disk space available"
    else
        echo -e "${RED}[FAIL]${NC} Less than 30GB available at \$LFS"
        ((FAILURES++))
    fi
else
    echo "LFS environment variable not set"
    echo "Checking root partition..."
    disk_space=$(df -BG / | tail -1 | awk '{print $4}' | sed 's/G//')
    echo "Disk space at /: ${disk_space}GB available"
    if [ "$disk_space" -ge 40 ]; then
        echo -e "${GREEN}[GOOD]${NC} Sufficient space for LFS build"
    else
        echo -e "${YELLOW}[WARN]${NC} May need dedicated partition for LFS"
        ((WARNINGS++))
    fi
fi

# Summary
echo ""
echo "======================================"
echo "Summary"
echo "======================================"

if [ $FAILURES -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo "Your system is ready to build LFS."
elif [ $FAILURES -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s)${NC}"
    echo "Your system should work, but may have performance issues."
else
    echo -e "${RED}✗ $FAILURES failure(s), $WARNINGS warning(s)${NC}"
    echo "Please fix the failures before building LFS."
    exit 1
fi

# Suggestions
echo ""
echo "Next steps:"
echo "1. Set up your LFS partition: export LFS=/mnt/lfs"
echo "2. Download the LFS book: https://www.linuxfromscratch.org/lfs/view/stable/"
echo "3. Follow Chapter 2 to prepare your environment"
echo "4. Start building from Chapter 5!"

exit 0
