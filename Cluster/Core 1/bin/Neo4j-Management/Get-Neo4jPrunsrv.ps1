# Copyright (c) "Neo4j"
# Neo4j Sweden AB [http://neo4j.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.


<#
.SYNOPSIS
Retrieves information about PRunSrv on the local machine to start Neo4j programs

.DESCRIPTION
Retrieves information about PRunSrv (Apache Commons Daemon) on the local machine to start Neo4j services and utilities, tailored to the type of Neo4j edition

.PARAMETER Neo4jServer
An object representing a valid Neo4j Server object

.PARAMETER ForServerInstall
Retrieve the PrunSrv command line to install a Neo4j Server

.PARAMETER ForServerUninstall
Retrieve the PrunSrv command line to uninstall a Neo4j Server

.PARAMETER ForServerUpdate
Retrieve the PrunSrv command line to update a Neo4j Server

.PARAMETER ForConsole
Retrieve the PrunSrv command line to start a Neo4j Server in the console.

.OUTPUTS
System.Collections.Hashtable

.NOTES
This function is private to the powershell module

#>
function Get-Neo4jPrunsrv
{
  [CmdletBinding(SupportsShouldProcess = $false,ConfirmImpact = 'Low',DefaultParameterSetName = 'ConsoleInvoke')]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $false)]
    [pscustomobject]$Neo4jServer

    ,[Parameter(Mandatory = $true,ValueFromPipeline = $false,ParameterSetName = 'ServerInstallInvoke')]
    [switch]$ForServerInstall

    ,[Parameter(Mandatory = $true,ValueFromPipeline = $false,ParameterSetName = 'ServerUninstallInvoke')]
    [switch]$ForServerUninstall

    ,[Parameter(Mandatory = $true,ValueFromPipeline = $false,ParameterSetName = 'ServerUpdateInvoke')]
    [switch]$ForServerUpdate

    ,[Parameter(Mandatory = $true,ValueFromPipeline = $false,ParameterSetName = 'ServerStartInvoke')]
    [switch]$ForServerStart

    ,[Parameter(Mandatory = $true,ValueFromPipeline = $false,ParameterSetName = 'ServerStopInvoke')]
    [switch]$ForServerStop

    ,[Parameter(Mandatory = $true,ValueFromPipeline = $false,ParameterSetName = 'ConsoleInvoke')]
    [switch]$ForConsole
  )

  begin
  {
  }

  process
  {
    $JavaCMD = Get-Java -Neo4jServer $Neo4jServer -ForServer -ErrorAction Stop
    if ($JavaCMD -eq $null)
    {
      Write-Error 'Unable to locate Java'
      return 255
    }

    # JVMDLL is in %JAVA_HOME%\bin\server\jvm.dll
    $JvmDLL = Join-Path -Path (Join-Path -Path (Split-Path $JavaCMD.java -Parent) -ChildPath 'server') -ChildPath 'jvm.dll'
    if (-not (Test-Path -Path $JvmDLL)) { throw "Could not locate JVM.DLL at $JvmDLL" }

    # Get the Service Name
    $Name = Get-Neo4jWindowsServiceName -Neo4jServer $Neo4jServer -ErrorAction Stop

    # Find PRUNSRV for this architecture
    # This check will return the OS architecture even when running a 32bit app on 64bit OS
    switch ((Get-WmiObject -Class Win32_Processor | Select-Object -First 1).Addresswidth) {
      32 { $PrunSrvName = 'prunsrv-i386.exe' } # 4 Bytes = 32bit
      64 { $PrunSrvName = 'prunsrv-amd64.exe' } # 8 Bytes = 64bit
      default { throw "Unable to determine the architecture of this operating system (Integer is $([IntPtr]::Size))" }
    }
    $PrunsrvCMD = Join-Path (Join-Path -Path (Join-Path -Path $Neo4jServer.Home -ChildPath 'bin') -ChildPath 'tools') -ChildPath $PrunSrvName
    if (-not (Test-Path -Path $PrunsrvCMD)) { throw "Could not find PRUNSRV at $PrunsrvCMD" }

    # Build the PRUNSRV command line
    switch ($PsCmdlet.ParameterSetName) {
      "ServerInstallInvoke" {
        $PrunArgs += @("`"//IS//$($Name)`"")
      }
      "ServerUpdateInvoke" {
        $PrunArgs += @("`"//US//$($Name)`"")
      }
      { @("ServerInstallInvoke","ServerUpdateInvoke") -contains $_ } {

        $JvmOptions = @()

        Write-Verbose "Reading JVM settings from configuration"
        # Try neo4j.conf first, but then fallback to neo4j-wrapper.conf for backwards compatibility reasons
        $setting = (Get-Neo4jSetting -ConfigurationFile 'neo4j.conf' -Name 'dbms.jvm.additional' -Neo4jServer $Neo4jServer)
        if ($setting -eq $null) {
          $setting = (Get-Neo4jSetting -ConfigurationFile 'neo4j-wrapper.conf' -Name 'dbms.jvm.additional' -Neo4jServer $Neo4jServer)
        }

        if ($setting -ne $null) {
          # Procrun expects us to split each option with `;` if these characters are used inside the actual option values
          # that will cause problems in parsing. To overcome the problem, we need to escape those characters by placing 
          # them inside single quotes.
          $settingsEscaped = @()
          foreach ($option in $setting.value) {
            $settingsEscaped += $option -replace "([;])",'''$1'''
          }

          $JvmOptions = [array](Merge-Neo4jJavaSettings -Source $JvmOptions -Add $settingsEscaped)
        }

        # Pass through appropriate args from Java invocation to Prunsrv
        # These options take priority over settings in the wrapper
        Write-Verbose "Reading JVM settings from console java invocation"
        $cmdSettings = ($JavaCMD.args | Where-Object { $_ -match '(^-D|^-X)' } | % { $_ -replace "([;])",'''$1''' })
        $JvmOptions = [array](Merge-Neo4jJavaSettings -Source $JvmOptions -Add $cmdSettings)

        $PrunArgs += @("`"--StartMode=jvm`"",
          "`"--StartMethod=start`"",
          "`"--ServiceUser=LocalSystem`"",
          "`"--StartPath=$($Neo4jServer.Home)`"",
          "`"--StartParams=--config-dir=$($Neo4jServer.ConfDir)`"",
          "`"++StartParams=--home-dir=$($Neo4jServer.Home)`"",
          "`"--StopMode=jvm`"",
          "`"--StopMethod=stop`"",
          "`"--StopPath=$($Neo4jServer.Home)`"",
          "`"--Description=Neo4j Graph Database - $($Neo4jServer.Home)`"",
          "`"--DisplayName=Neo4j Graph Database - $Name`"",
          "`"--Jvm=$($JvmDLL)`"",
          "`"--LogPath=$($Neo4jServer.LogDir)`"",
          "`"--StdOutput=$(Join-Path -Path $Neo4jServer.LogDir -ChildPath 'neo4j.log')`"",
          "`"--StdError=$(Join-Path -Path $Neo4jServer.LogDir -ChildPath 'service-error.log')`"",
          "`"--LogPrefix=neo4j-service`"",
          "`"--Classpath=lib/*;plugins/*`"",
          "`"--JvmOptions=$($JvmOptions -join ';')`"",
          "`"--Startup=auto`""
        )

        # Check if Java invocation includes Java memory sizing
        $JavaCMD.args | ForEach-Object -Process {
          if ($Matches -ne $null) { $Matches.Clear() }
          if ($_ -match '^-Xms([\d]+)m$') {
            $PrunArgs += "`"--JvmMs`""
            $PrunArgs += "`"$($matches[1])`""
            Write-Verbose "Use JVM Start Memory of $($matches[1]) MB"
          }
          if ($Matches -ne $null) { $Matches.Clear() }
          if ($_ -match '^-Xmx([\d]+)m$') {
            $PrunArgs += "`"--JvmMx`""
            $PrunArgs += "`"$($matches[1])`""

            Write-Verbose "Use JVM Max Memory of $($matches[1]) MB"
          }
        }

        if ($Neo4jServer.ServerType -eq 'Enterprise') { $serverMainClass = 'com.neo4j.server.enterprise.EnterpriseEntryPoint' }
        if ($Neo4jServer.ServerType -eq 'Community') { $serverMainClass = 'org.neo4j.server.CommunityEntryPoint' }
        if ($serverMainClass -eq '') { Write-Error "Unable to determine the Server Main Class from the server information"; return $null }
        $PrunArgs += @("`"--StopClass=$($serverMainClass)`"",
          "`"--StartClass=$($serverMainClass)`"")
      }
      "ServerUninstallInvoke" { $PrunArgs += @("`"//DS//$($Name)`"") }
      "ServerStartInvoke" { $PrunArgs += @("`"//ES//$($Name)`"") }
      "ServerStopInvoke" { $PrunArgs += @("`"//SS//$($Name)`"") }
      "ConsoleInvoke" { $PrunArgs += @("`"//TS//$($Name)`"") }
      default {
        throw "Unknown ParameterSetName $($PsCmdlet.ParameterSetName)"
        return $null
      }
    }

    Write-Output @{ 'cmd' = $PrunsrvCMD; 'args' = $PrunArgs }
  }

  end
  {
  }
}
