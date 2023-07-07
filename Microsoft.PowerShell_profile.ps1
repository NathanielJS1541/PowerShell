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
#oh-my-posh init pwsh --config '~\scoop\apps\oh-my-posh\current\themes\emodipt-extend.omp.json' | Invoke-Expression
#oh-my-posh init pwsh --config '~\scoop\apps\oh-my-posh\current\themes\iterm2.omp.json' | Invoke-Expression
#oh-my-posh init pwsh --config '~\scoop\apps\oh-my-posh\current\themes\lambdageneration.omp.json' | Invoke-Expression
#oh-my-posh init pwsh --config '~\scoop\apps\oh-my-posh\current\themes\microverse-power.omp.json' | Invoke-Expression
#oh-my-posh init pwsh --config '~\scoop\apps\oh-my-posh\current\themes\powerlevel10k_rainbow.omp.json' | Invoke-Expression
oh-my-posh init pwsh --config '~\scoop\apps\oh-my-posh\current\themes\slimfat.omp.json' --manual | Invoke-Expression

# Disable python venv prompt, as it is shown in oh-my-posh
$Env:VIRTUAL_ENV_DISABLE_PROMPT = "1"

<#
.SYNOPSIS
    Runs fzf using bat as a preview window.
#>
function fzbat
{
    Param()
    fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'
}

<#
.SYNOPSIS
    Picks $total words from the EFF wordlist.
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
    Runs a script at a given time.
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

<#
.SYNOPSIS
    Clears the command history, including the saved-to-file history, if applicable.
    From mklement0 at https://stackoverflow.com/questions/13257775/powershells-clear-history-doesnt-clear-history
#>
function Clear-SavedHistory
{
    [CmdletBinding(ConfirmImpact='High', SupportsShouldProcess)]
    param()

    # Debugging: For testing you can simulate not having PSReadline loaded with
    #            Remove-Module PSReadline -Force
    $havePSReadline = ($null -ne (Get-Module -EA SilentlyContinue PSReadline))

    Write-Verbose "PSReadline present: $havePSReadline"
    $target = if ($havePSReadline) { "entire command history, including from previous sessions" } else { "command history" }

    if (-not $pscmdlet.ShouldProcess($target))
    {
        return
    }

    if ($havePSReadline)
    {
        Clear-Host

        # Remove PSReadline's saved-history file.
        if (Test-Path (Get-PSReadlineOption).HistorySavePath)
        {
            # Abort, if the file for some reason cannot be removed.
            Remove-Item -EA Stop (Get-PSReadlineOption).HistorySavePath

            # To be safe, we recreate the file (empty).
            $null = New-Item -Type File -Path (Get-PSReadlineOption).HistorySavePath
        }

        # Clear PowerShell's own history
        Clear-History

        # Clear PSReadline's *session* history.
        # General caveat (doesn't apply here, because we're removing the saved-history file):
        #   * By default (-HistorySaveStyle SaveIncrementally), if you use
        #     [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory(), any sensitive
        #     commands *have already been saved to the history*, so they'll *reappear in the next session*.
        #   * Placing `Set-PSReadlineOption -HistorySaveStyle SaveAtExit` in your profile
        #     SHOULD help that, but as of PSReadline v1.2, this option is BROKEN (saves nothing).
        [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
    }
    else
    {
        # Without PSReadline, we only have a *session* history.
        Clear-Host

        # Clear the doskey library's buffer, used pre-PSReadline.
        # !! Unfortunately, this requires sending key combination Alt+F7.
        # Thanks, https://stackoverflow.com/a/13257933/45375
        $null = [system.reflection.assembly]::loadwithpartialname("System.Windows.Forms")
        [System.Windows.Forms.SendKeys]::Sendwait('%{F7 2}')

        # Clear PowerShell's own history
        Clear-History
    }
}

# Run neofetch
#neofetch
