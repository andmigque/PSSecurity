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

    SshdBinary     = 'sshd'

    SshdConfigPath = '/etc/ssh/sshd_config'

    SysctlHardening            = @(
        @{ Key = 'net.ipv4.conf.all.rp_filter'; Value = '1'; Purpose = 'Enable strict reverse path filtering to drop spoofed packets.' }
        @{ Key = 'net.ipv4.conf.default.rp_filter'; Value = '1'; Purpose = 'Apply reverse path filtering to interfaces created later.' }
        @{ Key = 'net.ipv4.ip_forward'; Value = '0'; Purpose = 'Disable packet forwarding between interfaces.' }
        @{ Key = 'net.ipv4.tcp_syncookies'; Value = '1'; Purpose = 'Enable SYN cookies to survive SYN flood attacks.' }
        @{ Key = 'kernel.randomize_va_space'; Value = '2'; Purpose = 'Enable full address space layout randomization.' }
        @{ Key = 'kernel.kptr_restrict'; Value = '2'; Purpose = 'Hide kernel pointers from unprivileged memory reads.' }
        @{ Key = 'kernel.dmesg_restrict'; Value = '1'; Purpose = 'Restrict the kernel ring buffer to privileged users.' }
    )
}
