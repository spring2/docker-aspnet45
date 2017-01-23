# call script that can be overridden to do customized steps on container startup
& ./init.ps1

#show what network config looks like
ipconfig /all

#show which sites are configured
appcmd list sites

# start and monitor the iis service
C:\ServiceMonitor.exe w3svc
