﻿<#
.Synopsis
    Grants certificate file read access to an app pool or user.
    
.Parameter AppPool
    The name of the application pool to grant access.

.Parameter UserName
    The username to grant access to.

.Parameter Certificate
    The certificate to grant access to.

.Link
    Get-Acl

.Link
    Set-Acl

.Link
    Find-Certificate.ps1

.Link
    Get-CertificatePermissions.ps1

.Link
    Show-CertificatePermissions.ps1
    
.Link
    http://stackoverflow.com/a/21713869/54323

.Link
    https://technet.microsoft.com/library/ee909471.aspx

.Example
    Grant-AppPoolCertAccess.ps1 -AppPool ExampleAppPool -Certificate $cert
    Grants the ExampleAppPool app pool access to read the cert in $cert.

.Example
    Find-Certificate.ps1 -FindValue ExampleCert -FindType FindBySubjectName -StoreName TrustedPeople -StoreLocation LocalMachine |Grant-AppPoolCertAccess.ps1 ExampleAppPool
    Grants the ExampleAppPool app pool access to read the found ExampleCert.
    
    For more information about options for -FindType:
    https://msdn.microsoft.com/en-us/library/system.security.cryptography.x509certificates.x509findtype%28v=vs.110%29.aspx
#>

#requires -version 3
#requires -Module WebAdministration
[CmdletBinding()] Param(
[Parameter(Position=0,Mandatory=$true,ParameterSetName='AppPool')]
[ValidateScript({Test-Path IIS:\AppPools\$_})][string]$AppPool,
[Parameter(Position=0,Mandatory=$true,ParameterSetName='UserName')]
[string]$UserName,
[Parameter(Position=1,Mandatory=$true,ValueFromPipeline=$true)]
[System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
)
Begin{try{Get-Command Get-Acl -CommandType Cmdlet |Out-Null}catch{throw 'The Get-Acl command is missing.'}}
Process
{
    if(!$UserName) {$UserName="IIS AppPool\${AppPool}"}
    if($UserName -notlike '*\*') {$UserName = "$env:USERDOMAIN\$UserName"}
    $path = Get-CertificatePath.ps1 $Certificate
    $acl = Get-Acl $path
    $acl.SetAccessRule((New-Object Security.AccessControl.FileSystemAccessRule $UserName,'Read','Allow'))
    Set-Acl $path $acl
    Show-CertificatePermissions.ps1 $Certificate
}
