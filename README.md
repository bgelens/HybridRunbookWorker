# HybridRunbookWorker
DSC Resource to enable or disable the Hybrid Runbook Worker functionality of OMS managed machine

## Initial Release
* Enable Hybrid Runbook Worker if Agent is already installed.
* Change WorkerGroup
* Remove Hybrid Runbook Worker

## Example 1
```powershell
configuration Onboard {
    Import-DscResource -ModuleName HybridRunbookWorker

    HybridRunbookWorker Onboard {
        Ensure = 'Present'
        Endpoint = 'https://we-agentservice-prod-1.azure-automation.net/accounts/<subid>'
        Token = (Get-Credential -Message 'Enter AA Key' -UserName 'AAKey')
        GroupName = 'MyGroup'
    }
}
```
## Example 2
```powershell
Configuration HybridRunbookWorkerConfig {

    Import-DscResource -ModuleName @{ModuleName='xPSDesiredStateConfiguration'; ModuleVersion='3.9.0.0'}
    Import-DscResource -ModuleName HybridRunbookWorker

    $OmsWorkspaceId = Get-AutomationVariable WorkspaceID
    $OmsWorkspaceKey = Get-AutomationVariable WorkspaceKey

    $OIPackageLocalPath = "C:\MMASetup-AMD64.exe"

    Node $AllNodes.NodeName {
        # Download a package
        xRemoteFile OIPackage {
            Uri = "https://opsinsight.blob.core.windows.net/publicfiles/MMASetup-AMD64.exe"
            DestinationPath = $OIPackageLocalPath
        }

        # Application
        Package OI {
            Ensure = "Present"
            Path = $OIPackageLocalPath
            Name = "Microsoft Monitoring Agent"
            ProductId = ""
            Arguments = '/C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=' + $OmsWorkspaceID + ' OPINSIGHTS_WORKSPACE_KEY=' + $OmsWorkspaceKey + ' AcceptEndUserLicenseAgreement=1"'
            DependsOn = "[xRemoteFile]OIPackage"
        }
        
        # Service state
        Service OIService {
            Name = "HealthService"
            State = "Running"
            DependsOn = "[Package]OI"
        }


        HybridRunbookWorker Onboard {
            Ensure    = 'Present'
            Endpoint  = Get-AutomationVariable AutomationEndpoint
            Token     = Get-AutomationPSCredential AutomationCredential
            GroupName = $Node.NodeName
            DependsOn = '[Package]OI'
        }
    }
}

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = 'TestHybridWorker'
            PSDscAllowPlainTextPassword = $true
            
        },
        @{
            NodeName = 'ProdHybridWorker'
            PSDscAllowPlainTextPassword = $true
        }
    )
} 
```