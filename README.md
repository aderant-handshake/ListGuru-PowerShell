# ListGuru-PowerShell
PowerShell script to help automate maintenance and reporting of the Handshake ListGuru Feature

These utilities are provided as is and are designed to aid in maintenance of Handshake ListGuru Tables.  They are not built for the Handshake List Mirroring product that is used
in SharePoint Online. 

## Usage 
After downloading the files you must edit file **lgm-utility-config.json** with values to match your environment. The properties in that file are : 
| Property Name | Sample Value | R/O | Notes |
| ------------- | ------------ | --- | ----- |  
| LGMSQLServer | SQL-DEMO | Required | ListGuru SQL Server; No Default |
| LGMDatabase | Handshake | Required | ListGuru/Handshake Database Name |
| LGMTable | SPListGuruMirrorInfo | Required | ListGuru Mirror TableName |
| LGMUserName | hsService | Optional | if blank, current credentials used, unless there is an LGMCred value below |
| LGMCred | hsServiceCred | Optional | Named Credentials setup in the Windows Credentials Manager (pending implementation) |

## Utilities 

### Invoke-LGM-RemirrorByTableName
This utility will remirror all SharePoint Lists and Libraries connected to a single Mirror Table. 

Arguments : 
| Parameter | Type | Note |
|-|-|-|
| MirrorTableName | string | Table Name from SPListGuruMirrorInfo.[MirrorTableName] |
| rebuild | switch | switch to force a SQL Table Rebuild - warning this will empty and then repopulate the SQL Table |

Example
```powershell
.\Invoke-LGM-RemirrorByTableName.ps1 -MirrorTableName Connect_FirmNews -rebuild
```
