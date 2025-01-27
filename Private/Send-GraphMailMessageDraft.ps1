﻿function Send-GraphMailMessageDraft {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [System.Diagnostics.Stopwatch] $StopWatch,
        [string] $MailSentTo,
        [string] $FromField,
        [System.Collections.IDictionary] $Authorization,
        [switch] $Suppress,
        [PSCustomObject] $DraftMessage

    )
    Try {
        if ($PSCmdlet.ShouldProcess("$MailSentTo", 'Send-EmailMessage')) {
            $Uri = "https://graph.microsoft.com/v1.0/users('" + $FromField + "')/messages/" + $DraftMessage.id + "/send"
            $null = Invoke-RestMethod -Uri $Uri -Headers $Authorization -Method POST -ContentType 'application/json; charset=UTF-8' -ErrorAction Stop
            if (-not $Suppress) {
                [PSCustomObject] @{
                    Status        = $True
                    Error         = ''
                    SentTo        = $MailSentTo
                    SentFrom      = $FromField
                    Message       = ''
                    TimeToExecute = $StopWatch.Elapsed
                }
            }
        } else {
            if (-not $Suppress) {
                [PSCustomObject] @{
                    Status        = $false
                    Error         = 'Email not sent (WhatIf)'
                    SentTo        = $MailSentTo
                    SentFrom      = $FromField
                    Message       = ''
                    TimeToExecute = $StopWatch.Elapsed
                }
            }
        }
    } catch {
        if ($PSBoundParameters.ErrorAction -eq 'Stop') {
            Write-Error $_
            return
        }
        $RestError = $_.ErrorDetails.Message
        $RestMessage = $_.Exception.Message
        if ($RestError) {
            try {
                $ErrorMessage = ConvertFrom-Json -InputObject $RestError -ErrorAction Stop
                $ErrorText = $ErrorMessage.error.message
                Write-Warning -Message "Send-GraphMailMessageDraft - Error: $($RestMessage) $($ErrorText)"
            } catch {
                $ErrorText = ''
                Write-Warning -Message "Send-GraphMailMessageDraft - Error: $($RestMessage)"
            }
        } else {
            Write-Warning -Message "Send-GraphMailMessageDraft - Error: $($_.Exception.Message)"
        }
        if ($_.ErrorDetails.RecommendedAction) {
            Write-Warning -Message "Send-GraphMailMessageDraft - Recommended action: $RecommendedAction"
        }
        if (-not $Suppress) {
            [PSCustomObject] @{
                Status        = $False
                Error         = if ($RestError) { "$($RestMessage) $($ErrorText)" }  else { $RestMessage }
                SentTo        = $MailSentTo
                SentFrom      = $FromField
                Message       = ''
                TimeToExecute = $StopWatch.Elapsed
            }
        }
    }
}