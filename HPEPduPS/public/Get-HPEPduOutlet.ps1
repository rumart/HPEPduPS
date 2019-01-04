
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
            Version : 1.0.0
            Revised : 04/01-2019
            Changelog:
            1.0.0 -- Bumped version number
            0.3.0 -- Setting params as mandatory
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

    $Path = "/redfish/v1/PowerDistribution/$PduId/PowerControl/Loadsegment/$SegmentId/OutletControl"

    $response = Invoke-HPEPduRequest -System $System -Resource $Path -Credential $Credential -IgnoreSSL

    if($response.'@odata.type' -eq '#OutletControl.1.0.0.OutletControl'){
        $response.Outlets
    }
    
}