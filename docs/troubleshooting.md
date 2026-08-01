# LFS Troubleshooting Guide

Common issues and solutions when building Linux From Scratch.

## Table of Contents

1. [Host System Issues](#host-system-issues)
2. [Compilation Errors](#compilation-errors)
3. [Chroot Issues](#chroot-issues)
4. [Boot Problems](#boot-problems)
5. [General Tips](#general-tips)

## Host System Issues

### /bin/sh Does Not Point to Bash

**Problem:**
```
ERROR: /bin/sh does not point to bash
```

**Solution:**
```bash
# Ubuntu/Debian
sudo dpkg-reconfigure dash
# Select "No"

# Or manually
sudo ln -sf /bin/bash /bin/sh
```

### Missing Required Tools

**Problem:**
```
bash: command not found: bison
bash: command not found: m4
```

**Solution:**

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y build-essential bison gawk texinfo
```

**Arch:**
```bash
sudo pacman -S base-devel bison gawk texinfo
```

**Fedora:**
```bash
sudo dnf groupinstall "Development Tools"
sudo dnf install bison gawk texinfo
```

### Tool Versions Too Old

**Problem:**
```
Version of bash is too old (need 3.2+, have 3.1)
```

**Solution:**
1. Update your host system
2. Use a newer distribution
3. Compile newer version manually (not recommended)

**Check all versions:**
```bash
./scripts/host-check.sh
```

### Insufficient Disk Space

**Problem:**
```
No space left on device
```

**Solution:**
```bash
# Check space
df -h $LFS

# Clean up if possible
sudo apt clean  # Ubuntu
sudo pacman -Sc  # Arch

# Or use larger partition
# Create new 40GB+ partition and remount
```

## Compilation Errors

### Package Won't Configure

**Problem:**
```
configure: error: C compiler cannot create executables
```

**Solutions:**

1. **Check compiler:**
```bash
gcc --version
g++ --version

# Test compilation
echo 'int main(){}' > test.c
gcc -o test test.c
./test
rm test test.c
```

2. **Check environment:**
```bash
echo $LFS
echo $LFS_TGT
echo $PATH

# Should be: $LFS/tools/bin:/usr/bin:/bin
```

3. **Reload environment:**
```bash
su - lfs
source ~/.bash_profile
```

### Make Fails with Errors

**Problem:**
```
make[2]: *** [foo.o] Error 1
make[1]: *** [all-recursive] Error 1
make: *** [all] Error 2
```

**Debugging Steps:**

1. **Read the actual error:**
```bash
# Scroll up to find the FIRST error
# Usually several lines above "Error 1"
```

2. **Check documentation:**
```bash
# Read the package's INSTALL or README
less INSTALL
less README
```

3. **Clean and retry:**
```bash
make clean
make
```

4. **Start fresh:**
```bash
cd $LFS/sources
rm -rf package-name
tar xf package-name.tar.xz
cd package-name
# Follow LFS book steps again
```

### Parallel Build Failures

**Problem:**
```
Intermittent build failures with -j flag
```

**Solution:**
```bash
# Some packages don't support parallel builds
# Remove MAKEFLAGS temporarily
unset MAKEFLAGS
make

# Or use -j1
make -j1

# After package is built, restore
export MAKEFLAGS="-j$(nproc)"
```

### Missing Dependencies

**Problem:**
```
configure: error: library XYZ not found
```

**Solution:**
1. Check if you followed book order
2. Verify previous package built successfully
3. Check if package is in `$LFS/tools` or `/usr`

```bash
# Search for library
find $LFS -name "libXYZ*"

# Check if previous package installed
ls $LFS/tools/lib/
ls $LFS/usr/lib/
```

### Test Suite Failures

**Problem:**
```
FAIL: test-xyz
```

**When to worry:**
- LFS book mentions test is important
- Multiple tests fail (>3)
- Core packages (glibc, gcc, binutils)

**When NOT to worry:**
- Book says "known failure"
- Only 1-2 tests fail
- Book says "safe to ignore"

**Solution:**
```bash
# Check LFS book errata
# https://www.linuxfromscratch.org/lfs/errata/stable/

# Check test output
make check 2>&1 | tee test-results.log
less test-results.log

# Continue if book says safe
```

## Chroot Issues

### Cannot Enter Chroot

**Problem:**
```
chroot: failed to run command '/bin/bash': No such file or directory
```

**Solutions:**

1. **Check bash installation:**
```bash
ls -la $LFS/bin/bash
# Should exist and be executable
```

2. **Check required mounts:**
```bash
# These must be mounted first:
mount -v --bind /dev $LFS/dev
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run
```

3. **Verify filesystem:**
```bash
# Ensure $LFS is mounted
mount | grep $LFS

# Check contents
ls -la $LFS/
# Should have: bin, boot, etc, lib, sbin, usr, var, etc.
```

### "Command not found" Inside Chroot

**Problem:**
```
bash: ls: command not found
```

**Solution:**
```bash
# Exit chroot
exit

# Check PATH inside chroot
chroot "$LFS" /usr/bin/env -i \
    HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login

# Verify tools exist
ls $LFS/bin/ls
ls $LFS/usr/bin/
```

### Lost in Chroot

**Problem:**
"I'm in chroot and something is wrong, how do I escape?"

**Solution:**
```bash
# Just exit
exit

# If that doesn't work
# Press Ctrl+D

# If completely stuck
# Open another terminal and find the process
ps aux | grep chroot
sudo kill -9 <PID>
```

### Chroot Environment Variables Wrong

**Problem:**
Environment variables not set correctly in chroot

**Solution:**
```bash
# Proper chroot command from LFS book:
chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin \
    /bin/bash --login +h

# Create /root/.bashrc inside chroot:
cat > /root/.bashrc << "EOF"
set +h
umask 022
LFS=/
LC_ALL=POSIX
PATH=/usr/bin:/usr/sbin
export LFS LC_ALL PATH
EOF
```

## Boot Problems

### Kernel Panic: No init found

**Problem:**
```
Kernel panic - not syncing: No working init found
```

**Solutions:**

1. **Wrong init path:**
```bash
# In bootloader config, try different init:
# For systemd:
init=/lib/systemd/systemd

# For sysvinit:
init=/sbin/init

# Generic:
init=/bin/bash  # Emergency shell
```

2. **Missing init:**
```bash
# Boot from live CD/USB
# Mount LFS partition
mount /dev/sdXY /mnt

# Check if init exists
ls -la /mnt/sbin/init  # sysvinit
ls -la /mnt/lib/systemd/systemd  # systemd

# If missing, re-enter chroot and rebuild
```

### GRUB Boot Failure

**Problem:**
```
error: unknown filesystem
grub rescue>
```

**Solution:**
```bash
# At grub rescue prompt:
set prefix=(hd0,1)/boot/grub
set root=(hd0,1)
insmod normal
normal

# Then boot and reinstall GRUB:
grub-install /dev/sdX
update-grub  # or grub-mkconfig -o /boot/grub/grub.cfg
```

### Cannot Mount Root Filesystem

**Problem:**
```
VFS: Cannot open root device "sdXY"
```

**Solutions:**

1. **Wrong device in /etc/fstab:**
```bash
# Edit /etc/fstab in chroot:
# Use UUID instead of /dev/sdXY
blkid  # Get UUID
# Edit fstab:
UUID=xxxx-xxxx / ext4 defaults 1 1
```

2. **Missing filesystem driver:**
```bash
# Rebuild kernel with ext4 support built-in (not module)
# In kernel config:
# File systems -> Ext4 filesystem support [*]
```

### System Boots but No Network

**Problem:**
Network interfaces don't come up

**Solutions:**

1. **Check interface names:**
```bash
ip link
# Note interface name (e.g., enp0s3, eth0)

# Update config files with correct name
# Systemd: /etc/systemd/network/
# Sysvinit: /etc/sysconfig/network-devices/
```

2. **Check network service:**
```bash
# systemd:
systemctl status systemd-networkd
systemctl enable systemd-networkd
systemctl start systemd-networkd

# sysvinit:
/etc/init.d/network start
```

## General Tips

### Save Your Work Frequently

```bash
# Take snapshots at key points:
# After Chapter 5:
tar czf lfs-ch5-$(date +%Y%m%d).tar.gz $LFS

# After successful chroot:
tar czf lfs-ch7-$(date +%Y%m%d).tar.gz $LFS

# Before kernel compilation:
tar czf lfs-ch10-$(date +%Y%m%d).tar.gz $LFS
```

### Keep Build Logs

```bash
# Log all output:
script -a build-log.txt

# Or per package:
./configure 2>&1 | tee configure.log
make 2>&1 | tee make.log
make install 2>&1 | tee install.log
```

### Use Version Control

```bash
# Track your build:
cd $LFS
git init
git add .
git commit -m "Completed Chapter 5"

# Create branches for experiments:
git branch experiment-systemd
```

### Read the Error Messages

**Most common mistake:** Not reading the actual error!

```bash
# When build fails, scroll UP
# The real error is usually several lines above "Error 1"

# Look for lines like:
# error: ...
# fatal: ...
# undefined reference to ...
```

### Search First

Before asking for help:

1. **Read LFS FAQ:** https://www.linuxfromscratch.org/faq/
2. **Check errata:** https://www.linuxfromscratch.org/lfs/errata/
3. **Search forums:** https://www.linuxquestions.org/questions/linux-from-scratch-13/
4. **Google the error:** Often others have hit the same issue

### When Asking for Help

Provide:
1. LFS version (e.g., 12.4)
2. Host system (e.g., Ubuntu 24.04)
3. Which chapter/package
4. Exact error message
5. What you tried already

## Emergency Recovery

### Start Over from Checkpoint

```bash
# If things go wrong:
# 1. Unmount LFS
umount -R $LFS

# 2. Restore from backup
tar xzf lfs-backup.tar.gz -C $LFS

# 3. Remount and continue
mount /dev/sdXY $LFS
# ... remount virtual filesystems
# ... enter chroot
```

### Complete Reset

```bash
# Nuclear option - use with extreme caution!
# ALWAYS verify $LFS is set before running this command
if [ -z "$LFS" ]; then
    echo "ERROR: \$LFS is not set! Aborting to prevent system damage."
    exit 1
fi

if [ "$LFS" = "/" ]; then
    echo "ERROR: \$LFS points to root! Aborting."
    exit 1
fi

echo "WARNING: This will delete everything in $LFS"
echo "Press Ctrl+C within 5 seconds to abort..."
sleep 5

rm -rf $LFS/*

# Start from Chapter 2 again
```

### Boot Rescue

If system won't boot:

1. **Boot from live USB/CD**
2. **Mount your LFS:**
```bash
mount /dev/sdXY /mnt
mount --bind /dev /mnt/dev
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
```
3. **Enter chroot:**
```bash
chroot /mnt /bin/bash
```
4. **Fix the problem**
5. **Reboot**

## Getting Help

### Official Resources
- **LFS FAQ:** https://www.linuxfromscratch.org/faq/
- **Mailing Lists:** https://www.linuxfromscratch.org/mail.html
- **IRC:** #lfs-support on Libera.Chat

### Community Forums
- **LinuxQuestions LFS:** https://www.linuxquestions.org/questions/linux-from-scratch-13/
- **Reddit:** r/linuxfromscratch
- **LFS Discord:** Check LFS website for invite

### Best Practices for Help
1. Be patient - volunteers respond when able
2. Provide complete information
3. Show what you've tried
4. Follow up when solved
5. Help others once you learn

## Prevention Tips

1. **Read ahead** - Know what's coming
2. **Don't skip steps** - Every command matters
3. **Verify downloads** - Use md5sums
4. **Check versions** - Run version-check.sh
5. **Take breaks** - Fresh eyes catch errors
6. **Keep notes** - Document your changes
7. **Test frequently** - Catch issues early

## Remember

- **Everyone struggles** - LFS is meant to be challenging
- **Errors are learning** - Each mistake teaches something
- **Community helps** - Don't hesitate to ask
- **Persistence pays off** - Finishing LFS is incredibly rewarding

Good luck, and happy troubleshooting!
