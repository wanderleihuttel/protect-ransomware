# http://blog.netwrix.com/2016/04/11/ransomware-protection-using-fsrm-and-powershell/
# https://fsrm.experiant.ca/
# Criar um novo grupo de triagem
# new-FsrmFileGroup -name "Arquivos Ransomware" -IncludePattern @((Invoke-WebRequest -Uri "https://fsrm.experiant.ca/api/v1/combined").content | convertfrom-json | % {$_.filters})
# Atualizar o grupo de triagem
# Set-FsrmFileGroup -name "Arquivos Ransomware" -IncludePattern @((Invoke-WebRequest -Uri "https://fsrm.experiant.ca/api/v1/combined").content | convertfrom-json | % {$_.filters})

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Parâmetros recebidos da triagem de arquivos
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$SourceIoOwner      = $args[0]  # Dono do arquivo
$SourceFilePath     = $args[1]  # Caminho do arquivo
$FileScreenPath     = $args[2]  # Caminho da triagem
$FileServer         = $args[3]  # Servidor
$ViolatedFileGroup  = $args[4]  # Regra que foi violada
$DateTimeIncident   = Get-Date -f "dd/MM/yyyy HH:mm:ss"


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Configuração do email
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$Username = "usuario@dominio.com.br"
$Password = "password"
$SMTPServer = "smtp.dominio.com.br"
$SMTPPort = "587"
$Credencial = New-Object -TypeName pscredential -ArgumentList ($Username,(ConvertTo-SecureString -String $Password -AsPlainText -Force))
$EmailCC = "admin1@dominio.com.br"
$EmailBcc = "admin2@dominio.com.br"
$Subject = "Foi detectado um arquivo não autorizado do grupo '$ViolatedFileGroup'"
$Body = "Um arquivo não permitido foi detectado na triagem do grupo de '$ViolatedFileGroup'. Por medida de segurança todos os compartilhamentos de rede do usuário foram bloqueados.`n
Usuário:  $SourceIoOwner`nArquivo:  $SourceFilePath em $FileScreenPath`nServidor: $FileServer`nData:     $DateTimeIncident`n`n`nContate o setor de TI imediatamente!"


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Envia o email
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$Message = New-Object System.Net.Mail.MailMessage
$Message.Subject = $Subject
$Message.Body = $Body
$Message.IsBodyHtml = $false
$Message.To.Add( $SourceIoOwner.ToLower().Split("\")[1] + "@" + $Username.Split("{[@|=]}")[1] )
$Message.CC.Add($EmailCC)
$Message.BCC.Add($EmailBcc)
$Message.From = $Username.Replace("=", "@") # For providers that use = instead @ to identify username
$SMTP = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort);
$SMTP.EnableSSL = $false   # gmail needs $true
$SMTP.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
$SMTP.Send($Message)


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Bloqueia o acesso de todos compartilhamentos do usuário
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Get-SmbShare -Special $false | ForEach-Object { Block-SmbShareAccess -Name $_.Name -AccountName $SourceIoOwner -Force}


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Comando para desbloquear todas os compartilhamentos
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Get-SmbShare -Special $false | ForEach-Object { Unblock-SmbShareAccess -Name $_.Name -AccountName 'UserName' -Force }


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Configuração do Bot do Telegram
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$ApiToken = "DIGITE AQUI O API TOKEN DO BOT"  # Api Token Bot Telegram
$ChatID = "DIGITE AQUI  CHAT ID"              # Chat ID Bot Telegram
$Message = ">>>> 💾 Arquivo não autorizado ❌ <<<<\n\nUm arquivo não permitido foi detectado na triagem do grupo de '$ViolatedFileGroup'. Por medida de segurança todos os compartilhamentos de rede do usuário foram bloqueados.\n\nUsuário:  $SourceIoOwner\nArquivo:  $SourceFilePath em $FileScreenPath\nServidor: $FileServer\nData:     $DateTimeIncident"
$Message = $Message.replace("\n","%0A")
$retorno = wget "https://api.telegram.org/bot$ApiToken/sendMessage?chat_id=$ChatID&text=$Message" | % {$_.Content}
exit 0
