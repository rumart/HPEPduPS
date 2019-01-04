
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
            Version : 1.0.0
            Revised : 04/01-2019
            Changelog:
            1.0.0 -- Bumped version number
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