# PowerShellLab #

These files are used for configuration with the [Autolab](https://github.com/theJasonHelmick/PS-AutoLab-Env) project. The intent is to setup a small domain environment for testing and teaching PowerShell.

## Domain Setup
Domain name: Company.pri
Password for all accounts is: `P@ssw0rd`

The user Art Deco (ArtD) is a member of the Domain Admins group.
The user April Showers (AprilS) is a member of the Domain Admins group.

## Servers
All servers run an evaluation version of Windows Server 2016 Core:

- DOM1 Domain Controller
- SRV1 Member server
- SRV2 Member server
- SRV3 Workgroup server

## Desktops
- Win10 - Windows 10 Enterprise (evaluation version) with Remote Server Administration Tools (RSAT) installed. 
- PowerShell remoting has been enabled. You will need to run `Update-Help` and manually install items like [VS Code](https://code.visualstudio.com/Download).

## Notes
- All computers are set for Mountain Time with a location of Phoenix, Arizona.
- It is strongly recommended that you run Windows update on the virtual machines, especially the Windows 10 client.

*Last updated August 24, 2017*