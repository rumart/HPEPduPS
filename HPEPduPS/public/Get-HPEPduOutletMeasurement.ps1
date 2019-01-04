
function Get-HPEPduOutletMeasurement {
    <#
        .SYNOPSIS
            Get measurements of HPE Pdu outlets
        .DESCRIPTION
            This function works with HPE G2 Metered and Switched Power distribution units.
            Retrieve information about measurements of the Outlets of the Pdu segment specified.
        .NOTES
            Info
            Author : Rudi Martinsen / Intility AS
            Date : 17/11-2018
            Version : 1.0.0
            Revised : 04/01-2019
            Changelog:
            1.0.0 -- Bumped version number
            0.3.0 -- Setting pduid as a mandatory variable
            0.2.2 -- Added check on credentials
            0.2.1 -- Added help text
            0.2.0 -- Fixed support for credential object
        .LINK
            https://github.com/rumart/hpe-g2-pdu-api
        .LINK
            https://www.rudimartinsen.com/2018/11/19/exploring-the-hpe-g2-pdu-rest-api/
        .EXAMPLE
            PS C:\> Get-HPEPduOutletMeasurement -System 10.10.10.10 -PDUId 1 -SegmentId 1 -Credential $credential


            AlarmStatus                 : Normal
            OutletNumber                : 1
            EnergyConsumedWattHour      : 860869
            ConsumedCurrent             : 0
            PowerFactor                 : 0
            OutputVoltage               : 226
            LoadPercentage              : 0
            PowerConsumedVoltageAmphere : 156103974
            OutletStatus                : ON
            PowerConsumedWatts          : 148

            AlarmStatus                 : Normal
            OutletNumber                : 2
            EnergyConsumedWattHour      : 140982
            ConsumedCurrent             : 0
            PowerFactor                 : 0
            OutputVoltage               : 226
            LoadPercentage              : 0
            PowerConsumedVoltageAmphere : 39422484
            OutletStatus                : ON
            PowerConsumedWatts          : 18

            AlarmStatus                 : Normal
            OutletNumber                : 3
            EnergyConsumedWattHour      : 94229
            ConsumedCurrent             : 0
            PowerFactor                 : 0
            OutputVoltage               : 226
            LoadPercentage              : 0
            PowerConsumedVoltageAmphere : 223394076
            OutletStatus                : ON
            PowerConsumedWatts          : 218

            AlarmStatus                 : Normal
            OutletNumber                : 4
            EnergyConsumedWattHour      : 666750
            ConsumedCurrent             : 0
            PowerFactor                 : 0
            OutputVoltage               : 226
            LoadPercentage              : 0
            PowerConsumedVoltageAmphere : 40328748
            OutletStatus                : ON
            PowerConsumedWatts          : 3

    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        $System,
        [Parameter(Mandatory=$true)]
        [int]
        $PDUId,
        [Parameter(Mandatory=$true)]
        [int]
        $SegmentId,
        [Parameter(Mandatory=$false,ParameterSetName="username")]
        $Username,
        [Parameter(Mandatory=$false,ParameterSetName="username")]
        [securestring]
        $Password,
        [Parameter(Mandatory=$false,ParameterSetName="credential")]
        $Credential,
        [switch]
        $IgnoreSSL
    )
    
    if($Username){
        if(!$Password -or $Password -eq ""){
            $Password = (Read-Host -Prompt "Please specify password" -AsSecureString)
        }
        $Credential = New-Object System.Management.Automation.PSCredential($Username,$Password)
    }
    elseif($Credential){
    }
    else{
        Write-Error "Username or Credential object not specified. Please specify valid credentials for connecting to the PDU"
    }

    $Path = "/redfish/v1/PowerDistribution/$PduId/PowerMeasurement/Loadsegment/$SegmentId/OutletMeasurement"

    $response = Invoke-HPEPduRequest -System $System -Resource $Path -Credential $Credential -IgnoreSSL

    if($response.'@odata.type' -eq '#OutletMeasurement.1.0.0.OutletMeasurement'){
        $response.Outlets
    }
    
}
