cd "C:\Scripts"
Import-Module -Name VMware.VimAutomation.HorizonView
Import-Module -Name VMware.Hv.Helper

$smtpserver = ""
$smtpfrom = ""
$smtpto = ""
$adminacc = ""
$credsFile = ""
$firedou = ""
$Horizonsrv = ""

$securePassword = Get-Content $CredsFile | ConvertTo-SecureString
$credentials = New-Object System.Management.Automation.PSCredential ($adminacc, $securePassword)
$hvserver = Connect-HVServer -server $Horizonsrv  -Credential $credentials
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"
$messagebody = @()
$services=$hvserver.extensiondata
$desktopvms = Get-HVMachinesummary
foreach ($desktopvm in $desktopvms) {  
    $username = $desktopvm.namesdata.username
    if ($username.Length -ne '0') 
        {
        $cutuser = ($username.split("\"))[1]
        $user_fired = Get-ADUser -Filter {(enabled -eq 'false') -and (samaccountname -eq $cutuser)} -SearchBase $firedou
            if ($user_fired -ne $null) 
                {
                $machineid = $desktopvm.id
                $machineservice=new-object vmware.hv.machineservice
                $machineinfohelper=$machineservice.read($services, $machineid)
                $machineinfohelper.getbasehelper().setuser($null)
                $machineservice.update($services, $machineinfohelper)
                echo 'Virtual Desktop:'$desktopvm.base.Name | Tee-Object c:\Scripts\log.log -Append
                echo 'User:'$user_fired.samaccountname | Tee-Object c:\Scripts\log.log -Append
                echo 'Result:' "Successful removed" | Tee-Object c:\Scripts\log.log -Append
                echo '--------------------------------------------------------------' | Tee-Object c:\Scripts\log.log -Append
                $messagebody = $messagebody + ($user_fired | Select-Object @{Name="User";Expression={$_.samaccountname}} ,@{Name="Virtual Desktop";Expression={$desktopvm.base.Name}} ,@{Name="Result";Expression={"Successful removed"}})
                }
        $user_fired = $null
        }
}
$date = Get-Date
$date = $date.ToString("yyyy-MM-dd-hh-mm-ss")
$fpath = "C:\Scripts\log.log" 
$isfile = Test-Path $fpath 
if($isfile -eq "True") {
Rename-Item c:\Scripts\log.log horizon$date.log
$Body = $messagebody | ConvertTo-Html -head $style | Out-String
}
else {New-Item c:\Scripts\horizon$date.log
echo 'no users to unassign' > c:\Scripts\horizon$date.log
$Body = "No users to unassign"
}

Send-MailMessage -SmtpServer $smtpserver -From $smtpfrom -To $smtpto -Subject 'Horizon automatic unassign' -BodyAsHtml -Body $body