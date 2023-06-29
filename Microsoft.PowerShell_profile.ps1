# Import z for fast directory seeking
Import-Module z
# Import terminal-icons to display file type icons in PowerShell
Import-Module Terminal-Icons
# Set EDITOR environmental variable for PSFzf
$Env:EDITOR = "nvim"
# Hook Stupid Fast Scoop Utils
Invoke-Expression (&sfsu hook)
# Inport PSColor module
#Import-Module PSColor
# Configure oh-my-posh
#oh-my-posh init pwsh --config 'C:\Users\struna01\scoop\apps\oh-my-posh\current\themes\emodipt-extend.omp.json' | Invoke-Expression
#oh-my-posh init pwsh --config 'C:\Users\struna01\scoop\apps\oh-my-posh\current\themes\iterm2.omp.json' | Invoke-Expression
#oh-my-posh init pwsh --config 'C:\Users\struna01\scoop\apps\oh-my-posh\current\themes\lambdageneration.omp.json' | Invoke-Expression
#oh-my-posh init pwsh --config 'C:\Users\struna01\scoop\apps\oh-my-posh\current\themes\microverse-power.omp.json' | Invoke-Expression
#oh-my-posh init pwsh --config 'C:\Users\struna01\scoop\apps\oh-my-posh\current\themes\powerlevel10k_rainbow.omp.json' | Invoke-Expression
oh-my-posh init pwsh --config 'C:\Users\struna01\scoop\apps\oh-my-posh\current\themes\slimfat.omp.json' --manual | Invoke-Expression

$Env:VIRTUAL_ENV_DISABLE_PROMPT = "1"

<#
.SYNOPSIS
    Runs fzf using bat as a preview window
#>
function fzbat
{
    Param()
    fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'
}

<#
.SYNOPSIS
    Picks $total words from the EFF wordlist
#>
function words
{
    Param (
        [Switch] $join,
        [Switch] $nums,
        [Switch] $caps,
        [Parameter(Mandatory=$false)] [Int]$total = 1
    )
    $words = Import-Csv "$home\Documents\PowerShell\eff_words.csv" -Header "word"
    $chosen = Get-Random $words -Count $total | Select-Object -Expand "word"
    if ($caps)
    {
        $chosen = $chosen | ForEach-Object {$_.substring(0,1).toupper()+$_.substring(1)}
    }
    if ($nums)
    {
        $chosen = $chosen | ForEach-Object {"$($_)$(Get-Random -Maximum 10)"}
    }
    if ($join)
    {
        $chosen = $chosen | Join-String -Separator "-"
    }
    $chosen
}

<#
.SYNOPSIS
    Runs a script at a given time
#>
function Schedule-Script
{
    Param (
        [Parameter(Mandatory=$true)] [String]$when,
        [Parameter(Mandatory=$false)] [String]$command = "python.exe",
        [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)] [String]$commandArgs = "-c `"print(`"Hello, World!`");input()`""
    )
    $action = New-ScheduledTaskAction -Execute $command -Argument $commandArgs
    $trigger = New-ScheduledTaskTrigger -Daily -At $when
    $name =  "$when-$(words)" -Replace "[^a-zA-z0-9]","-"
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskPath "\Script\" -TaskName $name -Description "Script"
}

# Run neofetch
#neofetch
