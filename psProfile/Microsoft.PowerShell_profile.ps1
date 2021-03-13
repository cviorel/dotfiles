
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

#region PSReadLine
$PSReadLineOptions = @{
  EditMode                      = "Vi"
  ExtraPromptLineCount          = 1
  MaximumHistoryCount           = 10000
  HistoryNoDuplicates           = $true
  HistorySearchCursorMovesToEnd = $true
  BellStyle                     = "None"
}
Set-PSReadLineOption @PSReadLineOptions

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -Chord Alt+d -Function KillWord
Set-PSReadLineKeyHandler -Chord Ctrl+k -Function CaptureScreen

# Don't save sensitive data
Set-PSReadLineOption -AddToHistoryHandler {
  param([string]$line)
  $sensitive = "password|asplaintext|token|key|secret"
  return ($line -notmatch $sensitive)
}

# Resolve full path
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+p' -ScriptBlock {
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  $tokens = $null
  $ast = $null
  $parseErrors = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)


  foreach ($token in $tokens) {
    $extent = $token.Extent
    if ($extent.StartOffset -le $cursor -and $extent.EndOffset -ge $cursor) {
      $tokenToChange = $token
      break
    }
  }

  if ($null -ne $tokenToChange) {
    $extent = $tokenToChange.Extent
    $tokenText = $extent.Text

    $pathValue = $tokenToChange.Value
    $resolvedPath = Resolve-Path -Path $pathValue -ErrorAction SilentlyContinue
    if ($resolvedPath) {
      $replacementText = $extent.Text.Replace($pathValue, $resolvedPath.Path)
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
        $extent.StartOffset,
        $tokenText.Length,
        $replacementText)
    }
  }
}
#endregion PSReadLine

if (Test-Path -Path "C:\Temp") {
  Set-Location -Path "C:\Temp"
}
