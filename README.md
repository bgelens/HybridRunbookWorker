# HybridRunbookWorker
DSC Resource to enable or disable the Hybrid Runbook Worker functionality of OMS managed machine

## Initial Release
* Enable Hybrid Runbook Worker if Agent is already installed.
* Change WorkerGroup
* Remove Hybrid Runbook Worker

## Example
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