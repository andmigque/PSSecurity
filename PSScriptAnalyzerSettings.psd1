@{
    IncludeDefaultRules = $true
    Severity            = @('Error', 'Warning', 'Information')
    Rules               = @{
        PSPlaceOpenBrace                          = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace                         = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }
        PSUseConsistentIndentation                = @{
            Enable              = $true
            IndentationSize     = 4
            Kind                = 'space'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
        }
        PSUseConsistentWhitespace                 = @{
            Enable                                  = $true
            CheckInnerBrace                         = $true
            CheckOpenBrace                          = $true
            CheckOpenParen                          = $true
            CheckOperator                           = $true
            CheckPipe                               = $true
            CheckPipeForRedundantWhitespace         = $true
            CheckSeparator                          = $true
            CheckParameter                          = $true
            IgnoreAssignmentOperatorInsideHashTable = $true
        }
        PSAlignAssignmentStatement                = @{
            Enable         = $true
            CheckHashtable = $true
        }
        PSAvoidLongLines                          = @{
            Enable            = $true
            MaximumLineLength = 140
        }
        PSAvoidSemicolonsAsLineTerminators        = @{
            Enable = $true
        }
        PSAvoidUsingDoubleQuotesForConstantString = @{
            Enable = $true
        }
        PSAvoidExclaimOperator                    = @{
            Enable = $true
        }
        PSUseCorrectCasing                        = @{
            Enable = $true
        }
        PSAvoidUsingCmdletAliases                 = @{
            Enable = $true
        }
        PSAvoidUsingPositionalParameters          = @{
            Enable           = $true
            CommandAllowList = @()
        }
        PSReviewUnusedParameter                   = @{
            Enable = $true
        }
        PSUseConsistentParameterSetName           = @{
            Enable = $true
        }
        PSUseConsistentParametersKind             = @{
            Enable = $true
        }
        PSUseSingleValueFromPipelineParameter     = @{
            Enable = $true
        }
        PSUseSingularNouns                        = @{
            Enable = $true
        }
        PSUseCompatibleSyntax                     = @{
            Enable         = $true
            TargetVersions = @('7.0')
        }
    }
}
