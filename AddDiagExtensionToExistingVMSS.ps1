# This sample is provided as is and is not meant for use on a production environment. It is provided only for illustrative purposes. The end user must test and modify the sample to suit their target environment.                                                                                                                                     ########
# Microsoft can make no representation concerning the content of this sample. Microsoft is providing this information only as a convenience to you. This is to inform you that Microsoft has not tested the sample and therefore cannot make any representations regarding the quality, safety, or suitability of any code or information found here.   #########
#################################################################################################################################################################################################################################################################################################################################################################
#Install Diag ext into existing VMSS

Param(
  [Parameter(Mandatory = $true, 
             HelpMessage="Name of the Storage Account for Diagnostics Extension.  The Storage account needs to exist before running this script")]
  [ValidateNotNullOrEmpty()]
  [string]$storageAccountName,

  [Parameter(Mandatory = $true, 
             HelpMessage="Storage account Key. This can be found in Azure Portal -> Storage account > Access Keys ")]
  [ValidateNotNullOrEmpty()]
  [string]$storageAccountKey,

    [Parameter(Mandatory = $true, 
             HelpMessage="Name of the resource group for VMSS.")]
  [ValidateNotNullOrEmpty()]
  [string]$VMSSResourceGroup,
    [Parameter(Mandatory = $true, 
             HelpMessage="Name of the VMSS")]
  [ValidateNotNullOrEmpty()]
  [string]$VMSSName


  )
$wadlogs = '<WadCfg> <DiagnosticMonitorConfiguration overallQuotaInMB="4096" xmlns="http://schemas.microsoft.com/ServiceHosting/2010/10/DiagnosticsConfiguration"> <DiagnosticInfrastructureLogs scheduledTransferLogLevelFilter="Error"/> <WindowsEventLog scheduledTransferPeriod="PT1M" > <DataSource name="Application!*[System[(Level = 1 or Level = 2)]]" /> <DataSource name="Security!*[System[(Level = 1 or Level = 2)]]" /> <DataSource name="System!*[System[(Level = 1 or Level = 2)]]" /></WindowsEventLog>'
$wadperfcounters1 =  '<PerformanceCounters scheduledTransferPeriod="PT1M"><PerformanceCounterConfiguration counterSpecifier="\Processor(_Total)\% Processor Time" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU utilization" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Processor(_Total)\% Privileged Time" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU privileged time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Processor(_Total)\% User Time" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU user time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Processor Information(_Total)\Processor Frequency" sampleRate="PT15S" unit="Count"><annotation displayName="CPU frequency" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\System\Processes" sampleRate="PT15S" unit="Count"><annotation displayName="Processes" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Process(_Total)\Thread Count" sampleRate="PT15S" unit="Count"><annotation displayName="Threads" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Process(_Total)\Handle Count" sampleRate="PT15S" unit="Count"><annotation displayName="Handles" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\% Committed Bytes In Use" sampleRate="PT15S" unit="Percent"><annotation displayName="Memory usage" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\Available Bytes" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory available" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\Committed Bytes" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory committed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\Memory\Commit Limit" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory commit limit" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk(_Total)\% Disk Time" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk active time" locale="en-us"/></PerformanceCounterConfiguration>'
$wadperfcounters2 =  '<PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk(_Total)\% Disk Read Time" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk active read time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk(_Total)\% Disk Write Time" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk active write time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk(_Total)\Disk Transfers/sec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk operations" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk(_Total)\Disk Reads/sec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk read operations" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk(_Total)\Disk Writes/sec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk write operations" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk(_Total)\Disk Bytes/sec" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk speed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk(_Total)\Disk Read Bytes/sec" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk read speed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\PhysicalDisk(_Total)\Disk Write Bytes/sec" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk write speed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\LogicalDisk(_Total)\% Free Space" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk free space (percentage)" locale="en-us"/></PerformanceCounterConfiguration></PerformanceCounters>'

$wadcfgxstart = $wadlogs + $wadperfcounters1 + $wadperfcounters2 + '<Metrics resourceId="'
$wadmetricsresourceid =  '/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/resourceGroups/vmsstest/providers/Microsoft.Compute/virtualMachineScaleSets/diagtest6'
$wadcfgxend = '"><MetricAggregation scheduledTransferPeriod="PT1H"/><MetricAggregation scheduledTransferPeriod="PT1M"/></Metrics></DiagnosticMonitorConfiguration></WadCfg>'
 
$xmlCfg = $wadcfgxstart + $wadmetricsresourceid + $wadcfgxend 
 
#Encode the XML config
$xmlCfg = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($xmlCfg))
 
 
$settings = @{"xmlCfg" = $xmlCfg; "storageAccount" = $storageAccountName}
 
 
$exname = "Microsoft.Insights.VMDiagnosticsSettings"
$publisher =  "Microsoft.Azure.Diagnostics"
$type =  "IaaSDiagnostics"
$typeHandlerVersion = "1.5"
 
 
$protectedSettings = @{ "storageAccountName" = $storageAccountName;"storageAccountKey" = $storageAccountKey; "storageAccountEndPoint" = "https://core.windows.net"}
 
#Get the VMSS object
$apivmss = Get-AzureRmVmss -ResourceGroupName $VMSSResourceGroup -VMScaleSetName $VMSSName
 
#Add the extension
Add-AzureRmVmssExtension -VirtualMachineScaleSet $apivmss -Name $exname -Publisher $publisher -Type $type -TypeHandlerVersion $typeHandlerVersion -AutoUpgradeMinorVersion $true -Setting $settings -ProtectedSetting $protectedSettings
 
#Update the VMSS model
Update-AzureRmVmss -VirtualMachineScaleSet $apivmss -ResourceGroupName $VMSSResourceGroup -Name $VMSSName
