$x=1
$a=0
while ($x -eq 1) {
    if((Test-Connection -Count 1 172.16.1.1) -eq $null) {$a = ++$a}
    else {$a = 0}
    if ($a -gt 5) {
        rasdial ah hetzner MZ8K0cWy25
        Send-MailMessage -SmtpServer owa.frhc.group -From vmwarerobot@ffin.ru -To support@ffin.ru -Subject 'VPN-RECONNECT' -Body 'VPN-RECONNECT'
        Start-Sleep -Seconds 60
        }
    }

