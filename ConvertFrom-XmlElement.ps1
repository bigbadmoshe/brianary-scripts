﻿<#
.SYNOPSIS
Converts named nodes of an element to properties of a PSObject, recursively.

.INPUTS
Microsoft.PowerShell.Commands.SelectXmlInfo output from Select-Xml.

.OUTPUTS
System.Management.Automation.PSCustomObject object created from selected XML.

.LINK
Select-Xml

.EXAMPLE
Select-Xml /configuration/appSettings/add web.config |ConvertFrom-XmlElement.ps1

key              value
---              -----
webPages:Enabled false
#>

#Requires -Version 3
[CmdletBinding()][OutputType([psobject])] Param(
# The element to convert to a PSObject.
[Parameter(ParameterSetName='Element',Position=0,Mandatory=$true,ValueFromPipeline=$true)][Xml.XmlElement] $Element,
# Output from the Select-Xml cmdlet.
[Parameter(ParameterSetName='SelectXmlInfo',Position=0,Mandatory=$true,ValueFromPipeline=$true)]
[Microsoft.PowerShell.Commands.SelectXmlInfo]$SelectXmlInfo
)
Process
{
    switch($PSCmdlet.ParameterSetName)
    {
        SelectXmlInfo { @($SelectXmlInfo |% {[Xml.XmlElement]$_.Node} |ConvertFrom-XmlElement.ps1) }
        Element
        {
            if(($Element.SelectNodes('*') |group Name |measure).Count -eq 1)
            {
                @($Element.SelectNodes('*') |ConvertFrom-XmlElement.ps1)
            }
            else
            {
                $properties = @{}
                $Element.Attributes |% {[void]$properties.Add($_.Name,$_.Value)}
                foreach($node in $Element.ChildNodes |? {$_.Name -and $_.Name -ne '#whitespace'})
                {
                    $subelements = $node.SelectNodes('*') |group Name
                    $value =
                        if($node.InnerText -and !$subelements)
                        {
                            $node.InnerText
                        }
                        elseif(($subelements |measure).Count -eq 1)
                        {
                            @($node.SelectNodes('*') |ConvertFrom-XmlElement.ps1)
                        }
                        else
                        {
                            ConvertFrom-XmlElement.ps1 $node
                        }
                    if(!$properties.Contains($node.Name))
                    { # new property
                        [void]$properties.Add($node.Name,$value)
                    }
                    else
                    { # property name collision!
                        if($properties[$node.Name] -isnot [Collections.Generic.List[object]])
                        { $properties[$node.Name] = ([Collections.Generic.List[object]]@($properties[$node.Name],$value)) }
                        else
                        { $properties[$node.Name].Add($value) }
                    }
                }
                New-Object PSObject -Property $properties
            }
        }
    }
}
