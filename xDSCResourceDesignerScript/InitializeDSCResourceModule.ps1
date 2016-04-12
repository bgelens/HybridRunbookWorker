New-xDscResource -ModuleName HybridRunbookWorker -Name BG_HybridRunbookWorker -FriendlyName HybridRunbookWorker -Path C:\GIT\ -ClassVersion 1.0.0.0 -Property @(
    New-xDscResourceProperty -Name Ensure -Type String -ValidateSet 'Present','Absent' -Attribute Required
    New-xDscResourceProperty -Name Endpoint -Type String -Attribute Key
    New-xDscResourceProperty -Name Token -Type PSCredential -Attribute Required
    New-xDscResourceProperty -Name GroupName -Type String -Attribute Required
)