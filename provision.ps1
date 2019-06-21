$RABBITMQ_USERNAME="admin"
$RABBITMQ_PASSWORD="changeme"
$RABBITMQ_ERLANG_COOKIE="bugsbunny"
$RABBITVERSION="rabbitmq_server-3.7.15"


Write-Host "Updating host files"
Copy-Item "C:\vagrant\hosts" -Destination "C:\Windows\System32\drivers\etc\hosts"

$HOSTNAME=hostname

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

switch -Wildcard ($HOSTNAME)
{       
	rabbitmq* {choco install -y rabbitmq
                   refreshenv
		   Set-ItemProperty -Path "C:\Users\vagrant\.erlang.cookie" -Name IsReadOnly -Value $false
		   Copy-Item "C:\vagrant\.erlang.cookie" -Destination "C:\Users\vagrant\.erlang.cookie"
		   Set-ItemProperty -Path "C:\Windows\System32\config\systemprofile\.erlang.cookie" -Name IsReadOnly -Value $false
		   Copy-Item "C:\vagrant\.erlang.cookie" -Destination "C:\Windows\System32\config\systemprofile\.erlang.cookie"
		   Copy-Item "C:\vagrant\rabbitmq.conf" -Destination "$env:APPDATA\RabbitMQ\rabbitmq.conf"
		   net stop RabbitMQ
		   net start RabbitMQ
		   cd "C:\Program Files\RabbitMQ Server\$RABBITVERSION\sbin\"
		   ./rabbitmqctl.bat stop_app
		   ./rabbitmqctl.bat start_app
		   ./rabbitmqctl.bat add_user $RABBITMQ_USERNAME "$RABBITMQ_PASSWORD"
		   ./rabbitmqctl.bat set_permissions -p "/" $RABBITMQ_USERNAME ".*" ".*" ".*"
		   ./rabbitmqctl.bat set_user_tags $RABBITMQ_USERNAME "administrator"
		   ./rabbitmqctl.bat status
		   }
}

switch -Wildcard ($HOSTNAME)
{
	rabbitmq2{
                            Write-Host "Clustering Node"
                            ./rabbitmqctl.bat stop_app
                            ./rabbitmqctl.bat join_cluster rabbit@rabbitmq1
                            ./rabbitmqctl.bat start_app

                            ./rabbitmqctl.bat cluster_status
                        }
	rabbitmq3{
			    Write-Host "Clustering Node"
			    ./rabbitmqctl.bat stop_app
			    ./rabbitmqctl.bat join_cluster rabbit@rabbitmq1
			    ./rabbitmqctl.bat start_app

			    ./rabbitmqctl.bat cluster_status
			} 

}

