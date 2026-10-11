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
}
