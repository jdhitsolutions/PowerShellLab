#requires -version 5.0

#Download the latest 64bit version of VSCode

[CmdletBinding(DefaultParameterSetName="VM")]
Param(
    [Parameter(Mandatory,ParameterSetName='VM')]
    #specify the name of a VM
    [string]$VMName,
    [Parameter(Mandatory,ParameterSetName='VM')]
    #Specify the user credential
    [pscredential]$Credential,
    [Parameter(Mandatory,ParameterSetName="session")]
    #specify an existing PSSession object
    [System.Management.Automation.Runspaces.PSSession]$Session    
)

Try {
    if ($PSCmdlet.ParameterSetName -eq 'VM') {
        Write-Host "Creating PSSession to $VMName" -ForegroundColor cyan
        $session = New-PSSession @PSBoundParameters -ErrorAction stop
    }

    $sb = {
        $path = "C:\"
        $uri = 'https://go.microsoft.com/fwlink/?Linkid=852157'
        $out = Join-Path -Path $Path -ChildPath VSCodeSetup-x64.exe
        
        Invoke-WebRequest -Uri $uri -OutFile $out
               
        if (Test-path $out) {
        Write-Host "Installing VSCode from $out" -foreground green
$loadInf = '@
[Setup]
Lang=english
Dir=C:\Program Files\Microsoft VS Code
Group=Visual Studio Code
NoIcons=0
Tasks=desktopicon,addcontextmenufiles,addcontextmenufolders,addtopath
@'
        $infPath = "${env:TEMP}\load.inf"
        $loadInf | Out-File $infPath
        
        Start-Process -FilePath $out -ArgumentList "/VERYSILENT /LOADINF=${infPath}" -Wait
        
        }
        else {
            Write-Warning "failed to find $out"
        }
        #>
    }

    Invoke-Command -ScriptBlock $sb -Session $session

    if ($PSCmdlet.ParameterSetName -eq 'VM') {
        Write-Host "Removing PSSession" -ForegroundColor cyan
        $Session | Remove-PSSession
    }
}
Catch {
    Throw $_
}

