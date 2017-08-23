#requires -version 5.0

#test if VM setup is complete


#The password will be passed by the control script WaitforVM.pSRV2
#You can manually set it while developing this Pester test
$LabData = Import-PowerShellDataFile -Path .\*.psd1
$Secure = ConvertTo-SecureString -String "$($labdata.allnodes.labpassword)" -AsPlainText -Force 
$Domain = "company"
$cred = New-Object PSCredential "Company\Administrator",$Secure
$wgcred = New-Object PSCredential  "SRV3\administrator",$secure

Describe DC1 {

$dc = New-PSSession -VMName DC -Credential $cred -ErrorAction SilentlyContinue
#set error action preference to suppress all error messsages
if ($dc) {
    Invoke-Command { $errorActionPreference = 'silentlyContinue'} -session $dc
}

It "[DC1] Should accept domain admin credential" {
    $dc.Count | Should Be 1
}

#test for features
$feat = Invoke-Command { Get-WindowsFeature | Where installed} -session $dc
$needed = 'AD-Domain-Services','DNS','RSAT-AD-Tools',
'RSAT-AD-PowerShell'
foreach ($item in $needed) {
    It "[DC1] Should have feature $item installed" {
        $feat.Name -contains $item | Should Be "True"
    }
}

It "[DC1] Should have an IP address of 192.168.3.10" {
    $i = Invoke-command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -Session $dc
    $i.ipv4Address | should be '192.168.3.10'
}

It "[DC1] Should have a domain name of $domain" {
    $r = Invoke-command { Get-ADDomain -ErrorAction SilentlyContinue } -session $dc
    $r.name | should Be $domain
}

$OUs = Invoke-command { Get-ADorganizationalUnit -filter * -ErrorAction SilentlyContinue} -session $dc
$needed = 'IT','Dev','Marketing','Sales','Accounting','JEA_Operators','Servers'
foreach ($item in $needed) {
    It "[DC1] Should have organizational unit $item" {
    $OUs.name -contains $item | Should Be "True"
    }
}
$groups = Invoke-Command { Get-ADGroup -filter * -ErrorAction SilentlyContinue} -session $DC
$target = "IT","Sales","Marketing","Accounting","JEA Operators"
foreach ($item in $target) {

 It "[DC1] Should have a group called $item" {
    $groups.Name -contains $item | Should Be "True"
 }

}

$users= Invoke-Command { Get-AdUser -filter * -ErrorAction SilentlyContinue} -session $dc
It "[DC1] Should have at least 15 user accounts" {
    $users.count | should BeGreaterThan 15
}

$computer = Invoke-Command { Get-ADComputer -filter * -ErrorAction SilentlyContinue} -session $dc
It "[DC1] Should have a computer account for Client" {
    $computer.name -contains "cli1" | Should Be "True"
} 

It "[DC1] Should have a computer account for SRV1" {
    $computer.name -contains "SRV1" | Should Be "True"
} 

It "[DC1] Should have a computer account for SRV2" {
    $computer.name -contains "SRV2" | Should Be "True"
} 

} #DC

Describe SRV1 {
    $SRV1 = New-PSSession -VMName SRV1 -Credential $cred -ErrorAction SilentlyContinue
It "[SRV1] Should accept domain admin credential" {
    $SRV1.Count | Should Be 1
}

It "[SRV1] Should have an IP address of 192.168.3.50" {
    $i = Invoke-command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -Session $SRV1
    $i.ipv4Address | should be '192.168.3.50'
}
$dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $SRV1
It "[SRV1] Should have a DNS server configuration of 192.168.3.10" {                        
  $dns.ServerAddresses -contains '192.168.3.10' | Should Be "True"           
}
} #SRV2

Describe SRV2 {
    $SRV2 = New-PSSession -VMName SRV2 -Credential $cred -ErrorAction SilentlyContinue
It "[SRV2] Should accept domain admin credential" {
    $SRV2.Count | Should Be 1
}

It "[SRV2] Should have an IP address of 192.168.3.51" {
    $i = Invoke-command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -Session $SRV2
    $i.ipv4Address | should be '192.168.3.51'
}
$dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $SRV2
It "[SRV2] Should have a DNS server configuration of 192.168.3.10" {                        
  $dns.ServerAddresses -contains '192.168.3.10' | Should Be "True"           
}
} #SRV2


Describe SRV3 {

It "[SRV3] Should respond to WSMan requests" { 
  $script:sess = New-PSSession -VMName SRV3 -Credential $wgCred -ErrorAction Stop
  $script:sess.Computername | Should Be 'SRV3'
}

It "[SRV3] Should have an IP address of 192.168.3.60" {
 $r = Invoke-Command { Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4} -session $script:sess
 $r.IPv4Address | Should Be '192.168.3.60'
}

It "[SRV3] Should belong to the Workgroup domain" {
  $sys = Invoke-Command { Get-CimInstance Win32_computersystem} -session $script:sess
  $sys.Domain | Should Be "Workgroup"
}

}
#>

Describe Cli1 {

$cl = New-PSSession -VMName cli1 -Credential $cred -ErrorAction SilentlyContinue
It "[CLI] Should accept domain admin credential" {
    $cl = New-PSSession -VMName cli1 -Credential $cred -ErrorAction SilentlyContinue
    $cl.Count | Should Be 1
}

It "[CLI] Should have an IP address of 192.168.3.100" {
    $i = Invoke-command -ScriptBlock { Get-NetIPAddress -interfacealias 'Ethernet' -AddressFamily IPv4} -session $cl
    $i.ipv4Address | should be '192.168.3.100'
}

$dns = Invoke-Command {Get-DnsClientServerAddress -InterfaceAlias ethernet -AddressFamily IPv4} -session $cl
It "[CLI] Should have a DNS server configuration of 192.168.3.10" {                        
  $dns.ServerAddresses -contains '192.168.3.10' | Should Be "True"           
}

} #client

Get-PSSession | Remove-PSSession
