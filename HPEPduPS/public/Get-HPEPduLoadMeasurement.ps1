
function Get-HPEPduLoadMeasurement {
    <#
        .SYNOPSIS
            Get load measurements of HPE Pdu segments
        .DESCRIPTION
            This function works with HPE G2 Metered and Switched Power distribution units.
            Retrieves load measurements of the segments of the Pdu specified.
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
        .LINK
            https://www.rudimartinsen.com/2019/01/04/hpe-pdu-powershell-module/
        .EXAMPLE
            PS C:\> Get-HPEPduLoadMeasurement -System 10.10.10.10 -PDUId 1 -Credential $credential


            Current        : 0
            LoadSegmentId  : 1
            BreakerStatus  : Normal
            AppearantPower : 0
            RatedCurrent   : 0
            voltage        : 0
            ActivePower    : 0
            RealPower      : 0
            PowerFactor    : 1
            Energy         : 0

            Current        : 1
            LoadSegmentId  : 2
            BreakerStatus  : Normal
            AppearantPower : 400
            RatedCurrent   : 0
            voltage        : 226
            ActivePower    : 385
            RealPower      : 55016
            PowerFactor    : 0
            Energy         : 0

            Current        : 0
            LoadSegmentId  : 3
            BreakerStatus  : Normal
            AppearantPower : 79
            RatedCurrent   : 0
            voltage        : 226
            ActivePower    : 22
            RealPower      : 38781
            PowerFactor    : 0
            Energy         : 0

            Current        : 0
            LoadSegmentId  : 4
            BreakerStatus  : Normal
            AppearantPower : 0
            RatedCurrent   : 0
            voltage        : 227
            ActivePower    : 0
            RealPower      : 0
            PowerFactor    : 1
            Energy         : 0

            Current        : 0
            LoadSegmentId  : 5
            BreakerStatus  : Normal
            AppearantPower : 0
            RatedCurrent   : 0
            voltage        : 227
            ActivePower    : 0
            RealPower      : 0
            PowerFactor    : 1
            Energy         : 0

            Current        : 0
            LoadSegmentId  : 6
            BreakerStatus  : Normal
            AppearantPower : 0
            RatedCurrent   : 0
            voltage        : 230
            ActivePower    : 0
            RealPower      : 0
            PowerFactor    : 1
            Energy         : 0

    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        $System,
        [Parameter(Mandatory=$true)]
        [int]
        $PDUId,
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

    $Path = "/redfish/v1/PowerDistribution/$PduId/PowerMeasurement/LoadsegmentMeasurement"

    $response = Invoke-HPEPduRequest -System $System -Resource $Path -Credential $Credential -IgnoreSSL

    if($response.'@odata.type' -eq '#PowerMeasurement.1.0.0.PowerMeasurement'){
        $response.Loadsegments
    }
    
}
