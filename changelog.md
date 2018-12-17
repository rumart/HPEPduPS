# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## version 0.2.3 - 2018-12-17
### Changed
- Added check on username and credential parameter

## version 0.2.2 - 2018-11-18
### Changed
- Updated changelog with Keep a changelog changes

## version 0.2.1 - 2018-11-17
### Added
- Help text added to all functions

## version 0.2.0 - 2018-11-17
### Added

- All functions support the use of a PSCredential object which you can create before you use the functions and then pass this object to each function call. Username/password will still work as in the previous version

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