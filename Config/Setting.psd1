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
}
