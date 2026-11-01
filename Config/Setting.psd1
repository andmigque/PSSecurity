@{
    HashIndexAlgorithm = 'SHA256'

    HashIndexInclude = @(
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

    HashIndexExclude = @(
        'bin'
        'obj'
        'node_modules'
        '.git'
        'Generated'
        '.vscode',
        '.svelte-kit',
        'test-results'
    )

    SensitivePattern = @{
        Secret              = @{
            PrivateKey     = '-----BEGIN [A-Z ]*PRIVATE KEY'
            AwsAccessKey   = 'AKIA[0-9A-Z]{16}'
            GitHubToken    = 'ghp_\w{36}|github_pat_'
            AssignedSecret = '(?i)(password|secret|token|apikey)\s*[:=]\s*[''"][^''"$]{4,}'
        }
        PersonalPath        = @{
            WindowsUserProfile = '(?i)C:\\Users\\\w+'
            LinuxHome          = '/home/\w+'
        }
        PersonalInformation = @{
            Email = '[\w.%+-]+@[\w.-]+\.[A-Za-z]{2,}'
        }
        Network             = @{
            IPv4Address = '\b(?:\d{1,3}\.){3}\d{1,3}\b'
        }
        Cui                 = @{
            Marking = '(?i)CUI//|Controlled Unclassified'
        }
    }
}
