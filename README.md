![Build status](https://ci.appveyor.com/api/projects/status/9ftybkutu10h8yvl?svg=true)

# HPEPduPS
Powershell module as a wrapper for the REST Api in HPE G2 Metered and switched PDUs

The module currently includes four functions for working with the PDU API:
- Get-HPEPdu
    - Get information about the PDUs connected to the system
- Get-HPEPduLoadMeasurement
    - Get current load on the specified PDU
- Get-HPEPduOutlet
    - Get information about outlets on the specified segments
- Get-HPEPduOutletMeasurement
    - Get current load on the specified Outlet

A few examples on the usage:
```powershell
PS C:\> Get-Command -Module HPEPduPS

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Get-HPEPdu                                         1.0.0      HPEPduPS
Function        Get-HPEPduLoadMeasurement                          1.0.0      HPEPduPS
Function        Get-HPEPduOutlet                                   1.0.0      HPEPduPS
Function        Get-HPEPduOutletMeasurement                        1.0.0      HPEPduPS
```

```powershell
PS C:\> Get-HPEPdu -System 1.1.1.1 -Username admin
Please specify password: *********

Id Path
-- ----
1  /redfish/v1/PowerDistribution/1
2  /redfish/v1/PowerDistribution/2
3  /redfish/v1/PowerDistribution/3
4  /redfish/v1/PowerDistribution/4
```

The functions support both username/password auth as well as a PS credential object
```powershell
PS C:\> Get-HPEPdu -System 1.1.1.1 -PduId 1 -Credential $cred


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
OutletMeasurement       : {@{@odata.id=/redfish/v1/PowerDistribution/1/PowerMeasurement/Loadsegment/1/OutletMeasurement}, @{@odata.id=/redfish/
                          v1/PowerDistribution/1/PowerMeasurement/Loadsegment/2/OutletMeasurement}, @{@odata.id=/redfish/v1/PowerDistribution/1
                          /PowerMeasurement/Loadsegment/3/OutletMeasurement}, @{@odata.id=/redfish/v1/PowerDistribution/1/PowerMeasurement/Load
                          segment/4/OutletMeasurement}...}
Firmware_version        : 2.0.0.C
Serial                  : CNxxxx
Id                      : 1
PartNumber              : P9S20A
DeviceType              : PowerDistributionUnit
PowerDistributionNumber : 1
Boot_version            : 2.25
Hardware_version        : HPE
Voltage                 : 240
KVARating               : 11
Power_rating            : 11,0
OutletControl           : {@{@odata.id=/redfish/v1/PowerDistribution/1/PowerControl/Loadsegment/1/OutletControl}, @{@odata.id=/redfish/v1/Power
                          Distribution/1/PowerControl/Loadsegment/2/OutletControl}, @{@odata.id=/redfish/v1/PowerDistribution/1/PowerControl/Lo
                          adsegment/3/OutletControl}, @{@odata.id=/redfish/v1/PowerDistribution/1/PowerControl/Loadsegment/4/OutletControl}...}

```

All functions have help functionality included


Please refer to this [repository](https://github.com/rumart/hpe-g2-pdu-api) for more information about the PDU Rest API.

[Changelog](https://github.com/rumart/HPEPduPS/blob/master/changelog.md)