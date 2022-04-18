﻿<#
.SYNOPSIS
Execute a command by using matching dictionary entries as parameters.

.INPUTS
System.Collections.IDictionary, the parameters to supply to the command.

.LINK
Select-DictionaryKeys.ps1

.LINK
ConvertTo-PowerShell.ps1

.LINK
Get-Command

.EXAMPLE
@{Object="Hello, world!"} |Invoke-CommandWithParams.ps1 Write-Host

Hello, world!

.EXAMPLE
$PSBoundParameters |Invoke-CommandWithParams.ps1 Send-MailMessage -OnlyMatches

Uses any of the calling script's parameters matching those found in the Send-MailMessage param list to call the command.
#>

[CmdletBinding()] Param(
# The name of a command to run using the parameter dictionary.
[Parameter(Position=0,Mandatory=$true)][Alias('CommandName')][string]$Name,
# A dictionary of parameters to supply to the command.
[Parameter(Mandatory=$true,ValueFromPipeline=$true)][Alias('Hashset')][Collections.IDictionary]$Dictionary,
# A list of dictionary keys to omit when sending dictionary parameters to the command.
[Alias('Except')][string[]]$ExcludeKeys,
<#
Compares the keys in the parameter dictionary with the parameters supported by the command,
omitting any dictionary entries that do not map to known command parameters.
No checking for valid parameter sets is performed.
#>
[Alias('Matching','')][switch]$OnlyMatches
)
Begin
{
    if($OnlyMatches)
    {
        [string[]]$exceptParams = [string[]][System.Management.Automation.PSCmdlet]::CommonParameters +
            [string[]][System.Management.Automation.PSCmdlet]::OptionalCommonParameters
        Write-Verbose "Common parameters ($($exceptParams.Length)): $exceptParams"
        if($ExcludeKeys) {$exceptParams += $ExcludeKeys}
        Write-Verbose "Excluding parameters ($($exceptParams.Length)): $exceptParams"
        [string[]]$params = (Get-Command $Name).Parameters.Keys |? {$_ -notin $exceptParams}
        Write-Verbose "Parameters ($($params.Length)): $params"
    }
}
Process
{
    $selectedParams =
        if($OnlyMatches) {$Dictionary |Select-DictionaryKeys.ps1 -Keys $params -SkipNullValues}
        else {$Dictionary}
    Write-Verbose "$Name $($selectedParams.Keys |% {"-$_ $(ConvertTo-PowerShell.ps1 $selectedParams.$_ -IndentBy '')"})"
    &$Name @selectedParams
}
