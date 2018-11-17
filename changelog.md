# Changelog

## version 0.2.1

Help text added to all functions

## version 0.2.0

All functions support the use of a PSCredential object which you can create before you use the functions and then pass this object to each function call. Username/password will still work as in the previous version

## version 0.1.0

Initial creation of the module with the following functions available.

* Get-HPEPdu
* Get-HPEPduLoadMeasurement
* Get-HPEPduOutlet
* Get-HPEPduOutletMeasurement
* Invoke-HPEPduRequest
* Set-InsecureSSL

The two latter functions are internal/private to the module

With the functions you can perform actions like:
* List all PDUs connected to the Management system (Get-HPEPdu)
* Retrieve details about a specific PDU (Get-HPEPdu -PduId x)
* Retrieve the outlets of a specific segment on a specific PDU (Get-HPEPduOutlet -PduId x -SegmentId y)
* Retrieve the load of a PDU (Get-HPEPduLoadMeasurement -PduId x)
* Retrieve the measurements of the outlets on a segment (Get-HPEPduOutletMeasurement -PduId x -SegmentId y)

All functions require you to authenticate (there is no "Connect" function). The username and password needs to be passed to each function call