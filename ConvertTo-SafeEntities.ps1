﻿<#
.SYNOPSIS
Encode text as XML/HTML, escaping all characters outside 7-bit ASCII.

.INPUTS
System.String of HTML or XML data to encode.

.OUTPUTS
System.String of HTML or XML data, encoded.

.FUNCTIONALITY
Unicode

.LINK
https://docs.microsoft.com/dotnet/api/system.char.issurrogatepair

.LINK
https://docs.microsoft.com/dotnet/api/system.char.converttoutf32

.EXAMPLE
"$([char]0xD83D)$([char]0xDCA1) File $([char]0x2192) Save" |ConvertTo-SafeEntities.ps1

&#x1F4A1; File &#x2192; Save

This shows a UTF-16 surrogate pair, used internally by .NET strings, which is combined
into a single entity reference.

.EXAMPLE
"ETA: $([char]0xBD) hour" |ConvertTo-SafeEntities.ps1

ETA: &#xBD; hour
#>

#Requires -Version 3
[CmdletBinding()][OutputType([string])] Param(
<#
An HTML or XML string that may include emoji or other Unicode characters outside
the 7-bit ASCII range.
#>
[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)][string] $InputObject
)
Process {return [Text.Encodings.Web.HtmlEncoder]::Default.Encode($InputObject)}
