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
            Version : 1.0.0
            Revised : 04/01-2019
            Changelog:
            1.0.0 -- Bumped version number
            0.2.4 -- Fixed wrong param name in API request
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

    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header -ErrorVariable apiErr
    if($apiErr){
        Write-Verbose $apiErr.InnerException
    }
    $response
}