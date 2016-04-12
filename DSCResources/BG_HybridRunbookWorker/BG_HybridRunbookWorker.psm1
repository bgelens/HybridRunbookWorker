function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $Endpoint,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Token,

        [parameter(Mandatory = $true)]
        [System.String]
        $GroupName
    )
    $ModulePresent = TestRegModule
    if (-not $ModulePresent) {
        throw 'Unable to check because module is not available'
    }
    $Actived = TestRegRegistry
    if ($Actived) {
        $Ensure = 'Present'
    } else {
        $Ensure = 'Absent'
    }
    if ($Actived) {
        $Config = GetRegRegistry
        return @{
            Ensure = $Ensure
            GroupName = $config.RunbookWorkerGroup
            Endpoint = $Endpoint
            Token = $null
        }
    } else {
        return @{
            Ensure = $Ensure
            GroupName = $GroupName
            Endpoint = $Endpoint
            Token = $null
        }
    }
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $Endpoint,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Token,

        [parameter(Mandatory = $true)]
        [System.String]
        $GroupName
    )
    $ModulePresent = TestRegModule
    if (-not $ModulePresent) {
        throw 'Should never reached Set'
    }

    $Actived = TestRegRegistry

    if ($Ensure -eq 'Present' -and $Actived) {
        Remove-HybridRunbookWorker -Url $Endpoint -Key $Token.GetNetworkCredential().Password
        Add-HybridRunbookWorker -Url $Endpoint -GroupName $GroupName -Key $Token.GetNetworkCredential().Password
    } elseif ($Ensure -eq 'Present') {
        Add-HybridRunbookWorker -Url $Endpoint -GroupName $GroupName -Key $Token.GetNetworkCredential().Password
    } else {
        Remove-HybridRunbookWorker -Url $Endpoint -Key $Token.GetNetworkCredential().Password
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $Endpoint,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Token,

        [parameter(Mandatory = $true)]
        [System.String]
        $GroupName
    )
    $ModulePresent = TestRegModule
    if (-not $ModulePresent) {
        throw 'Module not present, cannot use this resource'
    }
    $Actived = TestRegRegistry
    if ($Ensure -eq 'Present') {
        if ($Actived) {
            $Config = GetRegRegistry
            if ($Config.RunbookWorkerGroup -eq $GroupName) {
                $true
            } else {
                $false
            }
        }
    } else {
        if ($Actived) {
            $false
        } else {
            $true
        }
    }
}

function TestRegModule {
    if (Get-Module -Name HybridRegistration -ListAvailable) {
        $true
    } else {
        $false
    }
}

function TestRegRegistry {
    Test-Path -Path HKLM:\SOFTWARE\Microsoft\HybridRunbookWorker
}

function GetRegRegistry {
    Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\HybridRunbookWorker
}

Export-ModuleMember -Function *-TargetResource
