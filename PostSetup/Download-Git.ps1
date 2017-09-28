
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
    [System.Management.Automation.Runspaces.PSSession[]]$Session    
)

Try {
    if ($PSCmdlet.ParameterSetName -eq 'VM') {
        Write-Host "Creating PSSession to $VMName" -ForegroundColor cyan
        $session = New-PSSession @PSBoundParameters -ErrorAction stop
    }

    $sb = {
        #download the latest 64bit version of Git for Windows
        $uri = 'https://git-scm.com/download/win'
        #path to store the downloaded file
        $path = "C:\"

        #get the web page
        $page = Invoke-WebRequest -Uri $uri -UseBasicParsing -DisableKeepAlive

        #get the download link
        $dl = ($page.links | where-object outerhtml -match 'git-.*-64-bit.exe' | Select-Object -first 1 * ).href

        #split out the filename
        $filename = split-path $dl -leaf

        #construct a filepath for the download
        $out = Join-Path -Path $path -ChildPath $filename

        #download the file
        Invoke-WebRequest -uri $dl -OutFile $out -UseBasicParsing -DisableKeepAlive

        #check it out
        Get-item $out
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


