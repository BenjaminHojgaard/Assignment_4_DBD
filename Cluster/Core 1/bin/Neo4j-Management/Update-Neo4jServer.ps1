#
# Copyright (c) "Neo4j"
# Neo4j Sweden AB [http://neo4j.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.
#


<#
.SYNOPSIS
Update an installed Neo4j Server Windows Service

.DESCRIPTION
Update an installed Neo4j Server Windows Service

.PARAMETER Neo4jServer
An object representing a valid Neo4j Server

.EXAMPLE
Update-Neo4jServer $ServerObject

Update the Neo4j Windows Service for the Neo4j installation at $ServerObject

.OUTPUTS
System.Int32
0 = Service is successfully updated
non-zero = an error occured

.NOTES
This function is private to the powershell module

#>
function Update-Neo4jServer
{
  [CmdletBinding(SupportsShouldProcess = $false,ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
    [pscustomobject]$Neo4jServer
  )

  begin
  {
  }

  process
  {
    $ServiceName = Get-Neo4jWindowsServiceName -Neo4jServer $Neo4jServer -ErrorAction Stop
    $Found = Get-Service -Name $ServiceName -ErrorAction 'SilentlyContinue'
    if ($Found)
    {
      $prunsrv = Get-Neo4jPrunsrv -Neo4jServer $Neo4jServer -ForServerUpdate
      if ($prunsrv -eq $null) { throw "Could not determine the command line for PRUNSRV" }

      Write-Verbose "Updating installed Neo4j service"
      $result = Invoke-ExternalCommand -Command $prunsrv.cmd -CommandArgs $prunsrv.args

      # Process the output
      if ($result.exitCode -eq 0) {
        Write-Host "Neo4j service updated"
      } else {
        Write-Host "Neo4j service did not update"
        # Write out STDERR if it did not update
        Write-Host $result.capturedOutput
      }

      Write-Output $result.exitCode
    } else {
      Write-Host "Service update failed - service '$ServiceName' not found"
      Write-Output 1
    }
  }

  end
  {
  }
}

