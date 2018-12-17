
function Set-InsecureSSL {
add-type @" 
    using System.Net; 
    using System.Security.Cryptography.X509Certificates; 
    public class TrustAllCertsPolicy : ICertificatePolicy { 
        public bool CheckValidationResult( 
            ServicePoint srvPoint, X509Certificate certificate, 
            WebRequest request, int certificateProblem) { 
            return true; 
        } 
    } 
"@  
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
}

function Invoke-HPEPduRequest {
    <#
        .SYNOPSIS
            Function for sending requests to the HPE PDU Api
        .DESCRIPTION
            This function is ment as an internal function to the other functions
            in the powershell module
        .NOTES
            Info
            Author : Rudi Martinsen / Intility AS
            Date : 17/11-2018
            Version : 0.2.3
            Revised : 17/12-2018
            Changelog:
            0.2.3 -- Outputting error message in verbose
            0.2.2 -- Putting response in variable
            0.2.1 -- Added help text
            0.2.0 -- Fixed support for credential object
        .LINK
            https://github.com/rumart/hpe-g2-pdu
        .LINK
            https://www.rudimartinsen.com/2018/11/19/exploring-the-hpe-g2-pdu-rest-api/
    #>
    [cmdletbinding()]
    param(
        $System,
        $Resource,
        $Username,
        $Password,
        $Credential,
        [switch]
        $IgnoreSSL
    )

    if($Credential){
        $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName+':'+$Credential.GetNetworkCredential().Password))
    }
    else{
        $unsecPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
        $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$UnsecPass))
    }

    $header = @{
      'Authorization' = "Basic $auth"
    }
    $uri = "https://$system" + $Resource

    if($IgnoreSSL){
        Set-InsecureSSL
    }

    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header -ErrorAction apiErr
    if($apiErr){
        Write-Verbose $apiErr.InnerException
    }
    $response
}

function Get-HPEPdu {
    <#
        .SYNOPSIS
            Get information about HPE Pdu(s)
        .DESCRIPTION
            This function works with HPE G2 Metered and Switched Power distribution units.
            Retrieve information about the Pdus connected to the specified Management Ip.
            When pulling all PDUs the output will list the available PDUs. If you specify a PDU Id you will get detailed information about the specified PDU.
        .NOTES
            Info
            Author : Rudi Martinsen / Intility AS
            Date : 17/11-2018
            Version : 0.2.2
            Revised : 17/12-2018
            Changelog:
            0.2.2 -- Added check on credentials
            0.2.1 -- Added help text
            0.2.0 -- Fixed support for credential object
        .LINK
            https://github.com/rumart/hpe-g2-pdu-api
        .LINK
            https://www.rudimartinsen.com/2018/11/19/exploring-the-hpe-g2-pdu-rest-api/
        .EXAMPLE
            PS C:\> Get-HPEPdu -System 10.10.10.10 -Username admin

            Id Path                           
            -- ----                           
            1  /redfish/v1/PowerDistribution/1
            2  /redfish/v1/PowerDistribution/2
            3  /redfish/v1/PowerDistribution/3
            4  /redfish/v1/PowerDistribution/4

            Retrieves a list of PDUs

        .EXAMPLE
            PS C:\> Get-HPEPdu -System 10.7.43.115 -PduId 1 -Credential $credential


            Core_location           : 
            @odata.context          : /redfish/v1/$metadata#PowerDistribution
            BreakerRating           : 0
            InputRating             : 16
            Model                   : 230V, 16A, 11.0kVA, 50/60Hz
            LoadsegmentMeasurement  : {@{@odata.id=/redfish/v1/PowerDistribution/1/PowerMeasurement/LoadsegmentMeasurement}}
            Core_u_position         : 
            @odata.type             : #PowerDistribution.1.0.0.PowerDistribution
            Panel_name              : 
            @odata.id               : /redfish/v1/PowerDistribution/1
            OutletMeasurement       : {@{@odata.id=/redfish/v1/PowerDistribution/1/PowerMeasurement/Loadsegment/1/OutletMeasurement}, @{@odata.id=/redfish/v1/PowerDistribution/1/PowerMeasurement/Loadsegment/2/OutletMeasurement}, @{@odata.id=/redfish/v1/PowerDistributio
                                      n/1/PowerMeasurement/Loadsegment/3/OutletMeasurement}, @{@odata.id=/redfish/v1/PowerDistribution/1/PowerMeasurement/Loadsegment/4/OutletMeasurement}...}
            Firmware_version        : 2.0.0.C
            Serial                  : xxxxxx
            Id                      : 1
            PartNumber              : P9S20A
            DeviceType              : PowerDistributionUnit
            PowerDistributionNumber : 1
            Boot_version            : 2.25
            Hardware_version        : HPE
            Voltage                 : 240
            KVARating               : 11
            Power_rating            : 11,0
            OutletControl           : {@{@odata.id=/redfish/v1/PowerDistribution/1/PowerControl/Loadsegment/1/OutletControl}, @{@odata.id=/redfish/v1/PowerDistribution/1/PowerControl/Loadsegment/2/OutletControl}, @{@odata.id=/redfish/v1/PowerDistribution/1/PowerControl
                                      /Loadsegment/3/OutletControl}, @{@odata.id=/redfish/v1/PowerDistribution/1/PowerControl/Loadsegment/4/OutletControl}...}

            
            This will prompt for credentials and connect to the specified IP to output details of the specified PDU
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        $System,
        [int]
        $PduId,
        [Parameter(Mandatory=$false,ParameterSetName="username")]
        $Username,
        [Parameter(Mandatory=$false,ParameterSetName="username")]
        [securestring]
        $Password,
        [Parameter(Mandatory=$false,ParameterSetName="credential")]
        $Credential,
        [switch]
        $IgnoreSSL = $true
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

    $Path = "/redfish/v1/PowerDistribution"

    if($PDUId){
        $Path += "/$PduId"
    }
    
    $response = Invoke-HPEPduRequest -System $System -Resource $Path -Credential $Credential -IgnoreSSL

    if($response.'@odata.type' -eq '#PowerDistributionCollection.1.0.0.PowerDistributionCollection'){
        $response.members | Select @{l="Id";e={$_."@odata.id".split("/")[-1]}},@{l="Path";e={$_."@odata.id"}}
    }
    elseif($response.'@odata.type' -eq '#PowerDistribution.1.0.0.PowerDistribution'){
        $response
    }
    elseif($response){
        Write-Warning "Unspecified output, the type is $($response.'@odata.type')"
    }
    else{
        #Write-Error "An error occured"
    }

}

function Get-HPEPduOutlet {
    <#
        .SYNOPSIS
            Get information about HPE Pdu Outlets
        .DESCRIPTION
            This function works with HPE G2 Metered and Switched Power distribution units.
            Retrieve information about the Outlets of the Pdu specified.
        .NOTES
            Info
            Author : Rudi Martinsen / Intility AS
            Date : 17/11-2018
            Version : 0.2.2
            Revised : 17/12-2018
            Changelog:
            0.2.2 -- Added check on credentials
            0.2.1 -- Added help text
            0.2.0 -- Fixed support for credential object
        .LINK
            https://github.com/rumart/hpe-g2-pdu-api
        .LINK
            https://www.rudimartinsen.com/2018/11/19/exploring-the-hpe-g2-pdu-rest-api/
        .EXAMPLE
            PS C:\> Get-HPEPduOutlet -System 10.10.10.10 -PDUId 1 -SegmentId 1 -Credential $credential

            OutletNumber : 2
            StartupState : on
            OutletName   : OUTLET 2
            OnDelay      : 0
            OffDelay     : 0
            RebootDelay  : 5
            OutletStatus : on

            OutletNumber : 3
            StartupState : on
            OutletName   : OUTLET 3
            OnDelay      : 0
            OffDelay     : 0
            RebootDelay  : 5
            OutletStatus : on

            OutletNumber : 4
            StartupState : on
            OutletName   : OUTLET 4
            OnDelay      : 0
            OffDelay     : 0
            RebootDelay  : 5
            OutletStatus : on

            OutletNumber : 5
            StartupState : on
            OutletName   : OUTLET 5
            OnDelay      : 0
            OffDelay     : 0
            RebootDelay  : 5
            OutletStatus : on

    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        $System,
        [int]
        $PDUId,
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

    $Path = "/redfish/v1/PowerDistribution/$PduId/PowerControl/Loadsegment/$SegmentId/OutletControl"

    $response = Invoke-HPEPduRequest -System $System -Resource $Path -Credential $Credential -IgnoreSSL

    if($response.'@odata.type' -eq '#OutletControl.1.0.0.OutletControl'){
        $response.Outlets
    }
    
}

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
            Version : 0.2.2
            Revised : 17/12-2018
            Changelog:
            0.2.2 -- Added check on credentials
            0.2.1 -- Added help text
            0.2.0 -- Fixed support for credential object
        .LINK
            https://github.com/rumart/hpe-g2-pdu-api
        .LINK
            https://www.rudimartinsen.com/2018/11/19/exploring-the-hpe-g2-pdu-rest-api/
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
            Version : 0.2.2
            Revised : 17/12-2018
            Changelog:
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
        $System,
        [int]
        $PDUId,
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
