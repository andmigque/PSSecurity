@{
    # Applied by Set-LinuxFilePermission. Every rule holds on any distribution.
    # Path accepts wildcards. A path that does not exist is skipped.
    # Mode is a floor: bits the mode does not allow are removed, and none are added.
    # Owner and Group are optional, and set together when present.
    Rule = @(
        # Account databases and their backups, CIS 6.1.2 through 6.1.5
        @{ Path = '/etc/passwd'; Owner = 'root'; Group = 'root'; Mode = '644' }
        @{ Path = '/etc/group'; Owner = 'root'; Group = 'root'; Mode = '644' }
        @{ Path = '/etc/passwd-'; Owner = 'root'; Group = 'root'; Mode = '600' }
        @{ Path = '/etc/group-'; Owner = 'root'; Group = 'root'; Mode = '644' }

        # Login banners, CIS 1.7.1.4 through 1.7.1.6
        @{ Path = '/etc/motd'; Owner = 'root'; Group = 'root'; Mode = '644' }
        @{ Path = '/etc/issue'; Owner = 'root'; Group = 'root'; Mode = '644' }
        @{ Path = '/etc/issue.net'; Owner = 'root'; Group = 'root'; Mode = '644' }

        # Cron directories, CIS 5.1.3 through 5.1.7. Only the directories change; the
        # scripts inside keep their modes, so a job disabled with chmod -x stays disabled.
        @{ Path = '/etc/cron.d'; Owner = 'root'; Group = 'root'; Mode = '700' }
        @{ Path = '/etc/cron.hourly'; Owner = 'root'; Group = 'root'; Mode = '700' }
        @{ Path = '/etc/cron.daily'; Owner = 'root'; Group = 'root'; Mode = '700' }
        @{ Path = '/etc/cron.weekly'; Owner = 'root'; Group = 'root'; Mode = '700' }
        @{ Path = '/etc/cron.monthly'; Owner = 'root'; Group = 'root'; Mode = '700' }

        # Home directories, CIS 6.2.x. Ownership never changes; files inside keep their modes.
        @{ Path = '/home/*'; Mode = '750' }
        @{ Path = '/root'; Mode = '700' }
    )
}
