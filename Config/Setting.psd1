@{
    HashIndexAlgorithm         = 'SHA256'

    HashIndexInclude           = @(
        '*.md'
        '*.ps1'
        '*.psm1'
        '*.cs'
        '*.psd1'
        '*.ts'
        '*.sql'
        '*.json'
        '*.csv'
        '*.zip'
        '*.js'
        '*.cshtml',
        '*.mjs',
        '*.cjs'
    )

    HashIndexExclude           = @(
        'bin'
        'obj'
        'node_modules'
        '.git'
        'Generated'
        '.vscode',
        '.svelte-kit',
        'test-results'
    )

    WorldWritableIncludePath   = @('/')

    WorldWritableExcludePath   = @(
        '/tmp/*'
        '/var/tmp/*'
        '/dev/shm/*'
    )

    SuidIncludePath        = @('/')

    SuidExcludePath        = @(
        '/tmp/*'
        '/var/tmp/*'
        '/dev/shm/*'
    )

    SuidKnownGoodPath      = @(
        '/usr/bin/sudo'
        '/usr/bin/su'
        '/usr/bin/passwd'
        '/usr/bin/chsh'
        '/usr/bin/chfn'
        '/usr/bin/newgrp'
        '/usr/bin/gpasswd'
        '/usr/bin/chage'
        '/usr/bin/mount'
        '/usr/bin/umount'
        '/usr/bin/pkexec'
        '/usr/bin/sg'
        '/usr/sbin/unix_chkpwd'
        '/usr/lib/snapd/snap-confine'
        '/usr/lib/openssh/ssh-keysign'
        '/usr/bin/fusermount3'
        '/usr/bin/bwrap'
        '/usr/bin/newuidmap'
        '/usr/bin/newgidmap'
    )

    SudoersFilePath            = '/etc/sudoers'

    SudoersIncludeDirPath      = '/etc/sudoers.d'

    SudoersKnownGoodSpec       = @(
        'root ALL=(ALL:ALL) ALL'
        'root ALL=(ALL) ALL'
    )

    SshdBinary = @{
        Linux   = 'sshd'
        MacOS   = 'sshd'
        Windows = 'sshd.exe'
    }

    SshdConfigPath = @{
        Linux   = '/etc/ssh/sshd_config'
        MacOS   = '/etc/ssh/sshd_config'
        Windows = 'C:\ProgramData\ssh\sshd_config'
    }

    SysctlHardening            = @(
        @{ Key = 'net.ipv4.conf.all.rp_filter'; Value = '1'; Purpose = 'Enable strict reverse path filtering to drop spoofed packets.' }
        @{ Key = 'net.ipv4.conf.default.rp_filter'; Value = '1'; Purpose = 'Apply reverse path filtering to interfaces created later.' }
        @{ Key = 'net.ipv4.ip_forward'; Value = '0'; Purpose = 'Disable packet forwarding between interfaces.' }
        @{ Key = 'net.ipv4.tcp_syncookies'; Value = '1'; Purpose = 'Enable SYN cookies to survive SYN flood attacks.' }
        @{ Key = 'kernel.randomize_va_space'; Value = '2'; Purpose = 'Enable full address space layout randomization.' }
        @{ Key = 'kernel.kptr_restrict'; Value = '2'; Purpose = 'Hide kernel pointers from unprivileged memory reads.' }
        @{ Key = 'kernel.dmesg_restrict'; Value = '1'; Purpose = 'Restrict the kernel ring buffer to privileged users.' }

        # Additional process hardening
        @{ Key = 'fs.suid_dumpable'; Value = '0'; Purpose = 'Forbid core dumps from SUID processes.' }
        @{ Key = 'kernel.sysrq'; Value = '0'; Purpose = 'Disable magic SysRq kernel commands.' }
        @{ Key = 'kernel.yama.ptrace_scope'; Value = '1'; Purpose = 'Limit ptrace to descendant processes.' }
        @{ Key = 'kernel.unprivileged_bpf_disabled'; Value = '2'; Purpose = 'Deny BPF to unprivileged users until reboot.' }
        @{ Key = 'net.core.bpf_jit_harden'; Value = '2'; Purpose = 'Harden the BPF JIT for all users.' }
        @{ Key = 'fs.protected_hardlinks'; Value = '1'; Purpose = 'Prevent hard links to files the caller does not own.' }
        @{ Key = 'fs.protected_symlinks'; Value = '1'; Purpose = 'Restrict symlink follows in sticky world-writable directories.' }
        @{ Key = 'fs.protected_fifos'; Value = '2'; Purpose = 'Guard FIFO creation in shared directories.' }
        @{ Key = 'fs.protected_regular'; Value = '2'; Purpose = 'Guard regular-file creation in shared directories.' }

        # Additional network hardening
        @{ Key = 'net.ipv4.conf.all.accept_source_route'; Value = '0'; Purpose = 'Drop packets that name their own route.' }
        @{ Key = 'net.ipv4.conf.default.accept_source_route'; Value = '0'; Purpose = 'Apply source route rejection to interfaces created later.' }
        @{ Key = 'net.ipv4.conf.all.accept_redirects'; Value = '0'; Purpose = 'Ignore ICMP redirects that can rewrite routes.' }
        @{ Key = 'net.ipv4.conf.default.accept_redirects'; Value = '0'; Purpose = 'Apply redirect rejection to interfaces created later.' }
        @{ Key = 'net.ipv4.conf.all.secure_redirects'; Value = '0'; Purpose = 'Ignore redirects even toward known gateways.' }
        @{ Key = 'net.ipv4.conf.default.secure_redirects'; Value = '0'; Purpose = 'Apply secure redirect rejection to interfaces created later.' }
        @{ Key = 'net.ipv4.conf.all.send_redirects'; Value = '0'; Purpose = 'Do not send ICMP redirects.' }
        @{ Key = 'net.ipv4.conf.default.send_redirects'; Value = '0'; Purpose = 'Apply send redirect silence to interfaces created later.' }
        @{ Key = 'net.ipv4.conf.all.log_martians'; Value = '1'; Purpose = 'Log packets with impossible source addresses.' }
        @{ Key = 'net.ipv4.conf.default.log_martians'; Value = '1'; Purpose = 'Apply martian logging to interfaces created later.' }
        @{ Key = 'net.ipv4.icmp_echo_ignore_broadcasts'; Value = '1'; Purpose = 'Ignore broadcast pings to blunt smurf attacks.' }
        @{ Key = 'net.ipv4.icmp_ignore_bogus_error_responses'; Value = '1'; Purpose = 'Ignore invalid ICMP error replies.' }
        @{ Key = 'net.ipv6.conf.all.accept_redirects'; Value = '0'; Purpose = 'Ignore IPv6 ICMP redirects.' }
        @{ Key = 'net.ipv6.conf.default.accept_redirects'; Value = '0'; Purpose = 'Apply IPv6 redirect rejection to interfaces created later.' }
    )

    ModprobeBlacklist          = @(
        # Unused filesystems, CIS 1.1.1.1 through 1.1.1.7
        @{ Module = 'cramfs'; Purpose = 'Disable the compressed ROM filesystem from embedded devices.' }
        @{ Module = 'freevxfs'; Purpose = 'Disable the Veritas VxFS driver.' }
        @{ Module = 'jffs2'; Purpose = 'Disable the flash filesystem for embedded devices.' }
        @{ Module = 'hfs'; Purpose = 'Disable the Hierarchical File System driver.' }
        @{ Module = 'hfsplus'; Purpose = 'Disable the Mac HFS+ filesystem driver.' }
        @{ Module = 'squashfs'; Purpose = 'Disable the compressed read-only filesystem used by live media.' }
        @{ Module = 'udf'; Purpose = 'Disable the filesystem used by DVD media.' }

        # Removable media and uncommon network protocols, CIS 1.1.23 and 3.4.1 through 3.4.4
        @{ Module = 'usb-storage'; Purpose = 'Block USB mass storage devices at the module level.' }
        @{ Module = 'dccp'; Purpose = 'Disable the Datagram Congestion Control Protocol.' }
        @{ Module = 'sctp'; Purpose = 'Disable the Stream Control Transmission Protocol.' }
        @{ Module = 'rds'; Purpose = 'Disable the Reliable Datagram Sockets protocol.' }
        @{ Module = 'tipc'; Purpose = 'Disable the Transparent Inter-Process Communication protocol.' }
    )

    LinuxFilePermissions       = @(
        # Account databases and their backups, CIS 6.1.2 through 6.1.9
        @{ Path = '/etc/passwd'; Owner = 'root'; Group = 'root'; Mode = '644'; Purpose = 'Keep the account list root-writable only.' }
        @{ Path = '/etc/shadow'; Owner = 'root'; Group = 'shadow'; Mode = '640'; Purpose = 'Restrict password hashes to root or the shadow group.' }
        @{ Path = '/etc/group'; Owner = 'root'; Group = 'root'; Mode = '644'; Purpose = 'Keep the group list root-writable only.' }
        @{ Path = '/etc/gshadow'; Owner = 'root'; Group = 'shadow'; Mode = '640'; Purpose = 'Restrict secure group data to root or the shadow group.' }
        @{ Path = '/etc/passwd-'; Owner = 'root'; Group = 'root'; Mode = '600'; Purpose = 'Restrict the passwd backup file to root.' }
        @{ Path = '/etc/shadow-'; Owner = 'root'; Group = 'shadow'; Mode = '640'; Purpose = 'Restrict the shadow backup file to root or the shadow group.' }
        @{ Path = '/etc/group-'; Owner = 'root'; Group = 'root'; Mode = '644'; Purpose = 'Keep the group backup file root-writable only.' }
        @{ Path = '/etc/gshadow-'; Owner = 'root'; Group = 'shadow'; Mode = '640'; Purpose = 'Restrict the gshadow backup file to root or the shadow group.' }

        # TCP wrapper lists and login banners, CIS 3.3.4, 3.3.5, and 1.7.1.4 through 1.7.1.6
        @{ Path = '/etc/hosts.allow'; Owner = 'root'; Group = 'root'; Mode = '644'; Purpose = 'Keep the wrapper allow list root-writable only.' }
        @{ Path = '/etc/hosts.deny'; Owner = 'root'; Group = 'root'; Mode = '644'; Purpose = 'Keep the wrapper deny list root-writable only.' }
        @{ Path = '/etc/motd'; Owner = 'root'; Group = 'root'; Mode = '644'; Purpose = 'Keep the message of the day root-writable only.' }
        @{ Path = '/etc/issue'; Owner = 'root'; Group = 'root'; Mode = '644'; Purpose = 'Keep the local login banner root-writable only.' }
        @{ Path = '/etc/issue.net'; Owner = 'root'; Group = 'root'; Mode = '644'; Purpose = 'Keep the network login banner root-writable only.' }
    )

    LoginDefPolicy             = @(
        @{ Key = 'PASS_MAX_DAYS'; Value = '365'; Purpose = 'Force passwords to expire after at most 365 days.' }
        @{ Key = 'PASS_MIN_DAYS'; Value = '7'; Purpose = 'Require at least seven days between password changes.' }
        @{ Key = 'PASS_WARN_AGE'; Value = '7'; Purpose = 'Warn users seven days before their password expires.' }
    )

    LoginDefsPath              = '/etc/login.defs'
}
