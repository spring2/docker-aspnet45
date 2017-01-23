# handle issue with DNS inside container
# https://github.com/docker/docker/issues/30260
& c:/FixDNSEntries.ps1

ipconfig /all
appcmd list sites

# start and monitor the iis service
C:\ServiceMonitor.exe w3svc
