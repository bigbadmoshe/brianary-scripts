﻿<#
.SYNOPSIS
Tests copying objects as an HTML table.
#>

Describe 'Copy-Html' -Tag Copy-Html {
	BeforeAll {
		if(!(Get-Module -List PSScriptAnalyzer)) {Install-Module PSScriptAnalyzer -Force}
		$scriptsdir,$sep = (Split-Path $PSScriptRoot),[io.path]::PathSeparator
		if($scriptsdir -notin ($env:Path -split $sep)) {$env:Path += "$sep$scriptsdir"}
	}
	Context 'Copies objects as an HTML table' -Tag CopyHtml,Copy,Html {
		It "Should copy objects as HTML" -TestCases @(
			@{ InputObject = '[{Id: 1, Name: "First"}, {Id: 2, Name: "Second"}, {Id: 3, Name: "Third"}]' |ConvertFrom-Json
				Result = @'
*<tr><th>Id</th><th>Name</th></tr>
<tr><td align="right">1</td><td>First</td></tr>
<tr><td align="right">2</td><td>Second</td></tr>
<tr><td align="right">3</td><td>Third</td></tr>
</table>*
'@ }
		) {
			Param([object] $InputObject, [object] $Result)
			$InputObject |Copy-Html.ps1 Id,Name
			powershell -nol -noni -nop -c "Get-Clipboard -TextFormatType Html" |Out-String |
				Should -BeLikeExactly $Result -Because 'pipeline should work'
			Copy-Html.ps1 Id,Name -InputObject $InputObject
			powershell -nol -noni -nop -c "Get-Clipboard -TextFormatType Html" |Out-String |
				Should -BeLikeExactly $Result -Because 'parameter should work'
		}
	}

}
