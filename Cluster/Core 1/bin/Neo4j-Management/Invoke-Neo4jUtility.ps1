# Copyright (c) "Neo4j"
# Neo4j Sweden AB [http://neo4j.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.


<#
.SYNOPSIS
Invokes various Neo4j Utilities

.DESCRIPTION
Invokes various Neo4j Utilities.  This is a generic utility function called by the external functions e.g. Admin

.PARAMETER Command
A string of the command to run.

.PARAMETER CommandArgs
Command line arguments to pass to the utility

.OUTPUTS
System.Int32
0 = Success
non-zero = an error occured

.NOTES
Only supported on version 4.x Neo4j Community and Enterprise Edition databases

.NOTES
This function is private to the powershell module

#>
function Invoke-Neo4jUtility
{
  [CmdletBinding(SupportsShouldProcess = $false,ConfirmImpact = 'Low')]
  param(
    [Parameter(Mandatory = $false,ValueFromPipeline = $false,Position = 0)]
    [string]$Command = ''

    ,[Parameter(Mandatory = $false,ValueFromRemainingArguments = $true)]
    [object[]]$CommandArgs = @()
  )

  begin
  {
  }

  process
  {
    # Determine the Neo4j Home Directory.  Uses the NEO4J_HOME environment variable or a parent directory of this script
    $Neo4jHome = Get-Neo4jEnv 'NEO4J_HOME'
    if (($Neo4jHome -eq $null) -or (-not (Test-Path -Path $Neo4jHome))) {
      $Neo4jHome = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    }
    if ($Neo4jHome -eq $null) { throw "Could not determine the Neo4j home Directory.  Set the NEO4J_HOME environment variable and retry" }
    Write-Verbose "Neo4j Root is '$Neo4jHome'"

    $thisServer = Get-Neo4jServer -Neo4jHome $Neo4jHome -ErrorAction Stop
    if ($thisServer -eq $null) { throw "Unable to determine the Neo4j Server installation information" }
    Write-Verbose "Neo4j Server Type is '$($thisServer.ServerType)'"
    Write-Verbose "Neo4j Version is '$($thisServer.ServerVersion)'"
    Write-Verbose "Neo4j Database Mode is '$($thisServer.DatabaseMode)'"

    $GetJavaParams = @{}
    switch ($Command.Trim().ToLower())
    {
      "admintool" {
        Write-Verbose "Admintool command specified"
        $GetJavaParams = @{
          StartingClass = 'org.neo4j.cli.AdminTool';
        }
        break
      }
      "import" {
        Write-Verbose "Import command specified"
        $GetJavaParams = @{
          StartingClass = 'org.neo4j.tooling.ImportTool';
        }
        break
      }
      default {
        Write-Host "Unknown utility $Command"
        return 255
      }
    }

    # Generate the required Java invocation
    $JavaCMD = Get-Java -Neo4jServer $thisServer -ForUtility @GetJavaParams
    if ($JavaCMD -eq $null) { throw 'Unable to locate Java' }

    $ShellArgs = $JavaCMD.args
    if ($ShellArgs -eq $null) { $ShellArgs = @() }

    # Parameters need to be wrapped in double quotes to avoid issues in case they contain spaces.
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-7#parameters
    # https://github.com/PowerShell/PowerShell/issues/5576
    foreach ($CmdArg in $CommandArgs) {
      if ($CmdArg -match '^".*"$' -or $CmdArg -match "^'.*'$") {
        $ShellArgs += $CmdArg
      } else {
        $ShellArgs += "`"$CmdArg`""
      }
    }

    Write-Verbose "Starting neo4j utility using command line $($JavaCMD.java) $ShellArgs"
    $result = (Start-Process -FilePath $JavaCMD.java -ArgumentList $ShellArgs -Wait -NoNewWindow -Passthru)
    return $result.exitCode
  }

  end
  {
  }
}
