# LFS Init System Guide: systemd vs sysvinit

Complete guide to choosing and building with different init systems.

## What is an Init System?

The **init system** is the first process started by the Linux kernel (PID 1). It's responsible for:
- Starting system services
- Managing daemons
- Handling system shutdown/reboot
- Managing runlevels/targets

Your choice significantly impacts system behavior and complexity.

## Quick Comparison

| Feature | systemd | sysvinit |
|---------|---------|----------|
| **Boot Speed** | Fast (parallel) | Slower (sequential) |
| **Complexity** | High (~150K LOC) | Low (~10K LOC) |
| **Learning Curve** | Steep | Gentle |
| **Dependencies** | Many (dbus, etc.) | Minimal |
| **Standard** | De facto modern | LSB official |
| **Logging** | journald (binary) | Text files |
| **Service Management** | systemctl | service/init scripts |
| **Adoption** | Vast majority of distros | Small minority of distros |

## systemd - Modern Standard

### Advantages

**1. Performance**
- Parallel service startup
- Socket-based activation
- Faster boot times (often 2-3x faster)

**2. Features**
- Automatic service dependencies
- Service monitoring and restart
- Built-in logging (journald)
- Timer units (cron replacement)
- Socket activation
- Resource control (cgroups)

**3. Standardization**
- Used by: Ubuntu, Fedora, Debian, Arch, RHEL, SUSE
- Well-documented
- Large community
- Modern software expects systemd

**4. Integration**
- Better hardware integration
- Automatic device management
- Network management (systemd-networkd)
- Time synchronization (systemd-timesyncd)

### Disadvantages

**1. Complexity**
- ~150,000 lines of code
- Many interconnected components
- Harder to debug
- Steeper learning curve

**2. Philosophy**
- "Does everything" approach
- Binary logs (not plain text)
- Tight integration (less modularity)
- Some consider it against Unix philosophy

**3. Dependencies**
- Requires dbus
- Requires more libraries
- Larger footprint

### When to Choose systemd

Choose systemd if you:
- Want modern features
- Need compatibility with mainstream software
- Value performance and boot speed
- Plan to use desktop environments
- Want easier service management
- Need complex service dependencies
- Are learning "industry standard" Linux

### Resources

- **LFS Book:** https://www.linuxfromscratch.org/lfs/view/stable-systemd/
- **systemd Documentation:** https://systemd.io/
- **ArchWiki:** https://wiki.archlinux.org/title/Systemd

## sysvinit - Traditional Simplicity

### Advantages

**1. Simplicity**
- ~10,000 lines of code
- Easy to understand
- Shell script-based
- Transparent operation

**2. Stability**
- Decades of testing
- Very predictable
- Hard to break
- Minimal changes

**3. Philosophy**
- Does one thing well
- Modular design
- Text-based configuration
- Unix philosophy adherent

**4. Standards**
- Official LSB standard
- Well-documented behavior
- Traditional approach

### Disadvantages

**1. Performance**
- Sequential startup (slower)
- No parallel service start
- Longer boot times

**2. Features**
- No automatic dependencies
- Manual service management
- No service monitoring
- Limited process control

**3. Modern Software**
- Some software requires systemd
- Desktop environments prefer systemd
- Less community support
- Shrinking adoption

### When to Choose sysvinit

Choose sysvinit if you:
- Prefer simplicity
- Want to learn traditional Unix
- Value transparency
- Don't need desktop environments
- Want minimal dependencies
- Prefer text-based configuration
- Are building embedded systems
- Want complete understanding

### Resources

- **LFS Book:** https://www.linuxfromscratch.org/lfs/view/stable/
- **LSB Specification:** https://refspecs.linuxfoundation.org/lsb.shtml

## Technical Differences

### Service Management

**systemd:**
```bash
# Start service
systemctl start sshd

# Enable at boot
systemctl enable sshd

# Check status
systemctl status sshd

# View logs
journalctl -u sshd
```

**sysvinit:**
```bash
# Start service
/etc/init.d/sshd start
# or
service sshd start

# Enable at boot
update-rc.d sshd defaults  # Debian-style
# or
chkconfig sshd on  # RHEL-style

# Check status
/etc/init.d/sshd status

# View logs
tail /var/log/messages
```

### Boot Process

**systemd:**
1. Kernel loads systemd (PID 1)
2. systemd reads `/etc/systemd/system/default.target`
3. Activates target and dependencies in parallel
4. Uses socket/D-Bus activation
5. Fast, complex dependency tree

**sysvinit:**
1. Kernel loads init (PID 1)
2. init reads `/etc/inittab`
3. Runs scripts in `/etc/rc.d/` sequentially
4. Follows runlevel order (0-6)
5. Simple, predictable order

### Configuration

**systemd:**
- Unit files in `/etc/systemd/system/`
- INI-style format
- Example: `sshd.service`
```ini
[Unit]
Description=OpenSSH server daemon
After=network.target

[Service]
ExecStart=/usr/sbin/sshd -D
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

**sysvinit:**
- Shell scripts in `/etc/init.d/`
- Bash script format
- Example: `/etc/init.d/sshd`
```bash
#!/bin/bash
case "$1" in
  start)
    /usr/sbin/sshd
    ;;
  stop)
    killall sshd
    ;;
esac
```

## Building LFS with Your Choice

### For systemd Build

```bash
# Download systemd book
wget https://www.linuxfromscratch.org/lfs/downloads/stable-systemd/LFS-BOOK-12.4-systemd.pdf

# Follow systemd-specific instructions
# Key packages: systemd, dbus, polkit

# Boot with systemd
# Kernel command line: init=/lib/systemd/systemd
```

### For sysvinit Build

```bash
# Download sysvinit book
wget https://www.linuxfromscratch.org/lfs/downloads/stable/LFS-BOOK-12.4.pdf

# Follow sysvinit instructions
# Key packages: sysvinit, eudev (udev replacement)

# Boot with sysvinit
# Kernel command line: init=/sbin/init
```

## Can You Switch Later?

**Technically yes, but difficult:**

### systemd → sysvinit
- Remove systemd packages
- Install sysvinit + eudev
- Rewrite all service scripts
- Update bootloader
- **Difficulty:** Very Hard

### sysvinit → systemd
- Install systemd + dbus
- Remove sysvinit
- Create systemd unit files
- Update bootloader
- **Difficulty:** Hard

**Recommendation:** Choose carefully at build time!

## Real-World Examples

### systemd Systems
- Ubuntu Desktop
- Fedora Workstation
- Arch Linux
- Debian (default)
- Red Hat Enterprise Linux 7+

### sysvinit Systems
- Devuan (systemd-free Debian)
- Slackware (optional)
- Void Linux (optional)
- Gentoo (optional)
- Embedded systems

## Decision Matrix

### Choose systemd if you want:
- [ ] Desktop environment (GNOME, KDE)
- [ ] Fast boot times
- [ ] Modern software compatibility
- [ ] Industry-standard experience
- [ ] Advanced service management
- [ ] To use Docker/containers

### Choose sysvinit if you want:
- [ ] Maximum simplicity
- [ ] Educational experience
- [ ] Traditional Unix learning
- [ ] Minimal system
- [ ] Server without desktop
- [ ] Complete transparency

## My Recommendation

**For Learning:** Start with **sysvinit**
- Easier to understand
- Better for learning fundamentals
- Teaches traditional Unix concepts
- You can always build systemd later

**For Daily Use:** Use **systemd**
- Modern software expects it
- Desktop environments need it
- Better hardware support
- Industry standard

**Best of Both Worlds:**
1. First LFS build: Use sysvinit to learn
2. Second LFS build: Use systemd for features
3. Compare and understand both!

## Additional Resources

### Books
- Both versions available at https://www.linuxfromscratch.org/lfs/
- Same structure, different Chapter 7-8

### Documentation
- systemd: `man systemd`, `man systemctl`
- sysvinit: `man init`, `man inittab`

### Communities
- LFS Forums: https://www.linuxquestions.org/questions/linux-from-scratch-13/
- systemd GitHub: https://github.com/systemd/systemd
- sysvinit: Traditional Unix/Linux forums

## Summary

Both init systems work perfectly for LFS:

- **systemd**: Modern, feature-rich, complex
- **sysvinit**: Traditional, simple, transparent

Neither is "better" - they serve different philosophies and needs. LFS lets you experience both!

Choose based on your goals:
- **Learning Linux internals?** → sysvinit
- **Daily driver system?** → systemd
- **Can't decide?** → Build both! (on different partitions)

Happy building!
