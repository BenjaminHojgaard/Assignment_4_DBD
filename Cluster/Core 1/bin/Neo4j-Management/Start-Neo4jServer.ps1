# Copyright (c) "Neo4j"
# Neo4j Sweden AB [http://neo4j.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.


<#
.SYNOPSIS
Starts a Neo4j Server instance

.DESCRIPTION
Starts a Neo4j Server instance either as a java console application or Windows Service

.PARAMETER Neo4jServer
An object representing a valid Neo4j Server object

.EXAMPLE
Start-Neo4jServer -Neo4jServer $ServerObject

Start the Neo4j Windows Windows Service for the Neo4j installation at $ServerObject

.OUTPUTS
System.Int32
0 = Service was started and is running
non-zero = an error occured

.NOTES
This function is private to the powershell module

#>
function Start-Neo4jServer
{
  [CmdletBinding(SupportsShouldProcess = $false,ConfirmImpact = 'Low',DefaultParameterSetName = 'WindowsService')]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $false)]
    [pscustomobject]$Neo4jServer

    ,[Parameter(Mandatory = $true,ParameterSetName = 'Console')]
    [switch]$Console

    ,[Parameter(Mandatory = $true,ParameterSetName = 'WindowsService')]
    [switch]$Service
  )

  begin
  {
  }

  process
  {
    # Running Neo4j as a console app
    if ($PsCmdlet.ParameterSetName -eq 'Console')
    {
      $JavaCMD = Get-Java -Neo4jServer $Neo4jServer -ForServer -ErrorAction Stop
      if ($JavaCMD -eq $null)
      {
        Write-Error 'Unable to locate Java'
        return 255
      }

      Write-Verbose "Starting Neo4j as a console with command line $($JavaCMD.java) $($JavaCMD.args)"
      $result = (Start-Process -FilePath $JavaCMD.java -ArgumentList $JavaCMD.args -Wait -NoNewWindow -Passthru -WorkingDirectory $Neo4jServer.Home)
      Write-Verbose "Returned exit code $($result.ExitCode)"

      Write-Output $result.exitCode
    }

    # Running Neo4j as a windows service
    if ($PsCmdlet.ParameterSetName -eq 'WindowsService')
    {
      $ServiceName = Get-Neo4jWindowsServiceName -Neo4jServer $Neo4jServer -ErrorAction Stop
      $Found = Get-Service -Name $ServiceName -ErrorAction 'SilentlyContinue'
      if ($Found)
      {
        $prunsrv = Get-Neo4jPrunsrv -Neo4jServer $Neo4jServer -ForServerStart
        if ($prunsrv -eq $null) { throw "Could not determine the command line for PRUNSRV" }

        Write-Verbose "Starting Neo4j as a service"
        $result = Invoke-ExternalCommand -Command $prunsrv.cmd -CommandArgs $prunsrv.args

        # Process the output
        if ($result.exitCode -eq 0) {
          Write-Host "Neo4j service started"
        } else {
          Write-Host "Neo4j service did not start"
          # Write out STDERR if it did not start
          Write-Host $result.capturedOutput
        }

        Write-Output $result.exitCode
      }
      else
      {
        Write-Host "Service start failed - service '$ServiceName' not found"
        Write-Output 1
      }
    }
  }

  end
  {
  }
}
