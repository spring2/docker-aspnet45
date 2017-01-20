FROM microsoft/windowsservercore

RUN powershell -Command Add-WindowsFeature Web-Server

ADD ServiceMonitor.exe /ServiceMonitor.exe

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]

RUN powershell -Command Add-WindowsFeature NET-Framework-45-ASPNET; \
    powershell -Command Add-WindowsFeature Web-Asp-Net45; \
    powershell -Command Remove-Item -Recurse C:\inetpub\wwwroot\*

##
# TODO:
# - way too many layers
# - splunk should be broken out
# - splunk install should be in single layer and installer deleted
# - splunk forwarder needs to be configurable
##

# common tools:
# nano - text based editor
# upack - proget universal package installer
RUN powershell -Command \
	Invoke-WebRequest http://www.nano-editor.org/dist/v2.2/NT/nano-2.2.6.zip -UseBasicParsing -OutFile "$env:TEMP\nano-2.2.6.zip"; \
	Expand-Archive -Path "$env:TEMP\nano-2.2.6.zip" -DestinationPath c:\bin -Force; \
	Remove-Item "$env:TEMP\nano-2.2.6.zip"; \
	Invoke-WebRequest http://cdn.inedo.com/downloads/proget/upack.zip -UseBasicParsing -OutFile "$env:TEMP\upack.zip"; \
	Expand-Archive -Path "$env:TEMP\upack.zip" -DestinationPath c:\bin -Force; \
	Remove-Item "$env:TEMP\upack.zip";	
RUN setx /M PATH "%PATH%;c:\bin;C:\Windows\System32\inetsrv"

# base .NET and ASP.NET
RUN powershell -Command \
	Add-WindowsFeature NET-Framework-45-ASPNET; \
	Add-WindowsFeature Web-Asp-Net45

# Install Chocolatey
ENV chocolateyUseWindowsCompression false
RUN @powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

RUN c:\windows\system32\inetsrv\appcmd.exe unlock config -section:system.webServer/handlers

RUN powershell -Command \
	Invoke-WebRequest https://download.microsoft.com/download/5/B/C/5BC5DBB3-652D-4DCE-B14A-475AB85EEF6E/vcredist_x86.exe -UseBasicParsing -OutFile "$env:TEMP\vcredist_x86.exe"; \
	Start-Process -FilePath $env:TEMP\vcredist_x86.exe -ArgumentList '/q', '/norestart' -PassThru -Wait; \
	Remove-Item "$env:TEMP\vcredist_x86.exe"; \
	Invoke-WebRequest https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe -UseBasicParsing -OutFile "$env:TEMP\vcredist_x86.exe"; \
	Start-Process -FilePath $env:TEMP\vcredist_x86.exe -ArgumentList '/q', '/norestart' -PassThru -Wait; \
	Remove-Item "$env:TEMP\vcredist_x86.exe"

#install the needed Windows IIS features for WCF
RUN dism /Online /Enable-Feature /all /FeatureName:WAS-WindowsActivationService \
	/FeatureName:WAS-ProcessModel \
	/FeatureName:WAS-ConfigurationAPI \
	/FeatureName:WCF-HTTP-Activation45

#RUN dism /Online /Enable-Feature /all /FeatureName:WCF-HTTP-Activation
#RUN dism /Online /Enable-Feature /all /FeatureName:WAS-NetFxEnvironment

RUN setx /M PATH "%PATH%;C:\Windows\System32\inetsrv"

# setup splunk
RUN mkdir C:\inetpub\logs\LogFiles\W3SVC2
RUN mkdir c:\Logs

RUN powershell -Command \
	Invoke-WebRequest https://download.microsoft.com/download/5/B/C/5BC5DBB3-652D-4DCE-B14A-475AB85EEF6E/vcredist_x86.exe -UseBasicParsing -OutFile "$env:TEMP\vcredist_x86.exe"; \
	Start-Process -FilePath $env:TEMP\vcredist_x86.exe -ArgumentList '/q', '/norestart' -PassThru -Wait; \
	Remove-Item "$env:TEMP\vcredist_x86.exe"; \
	Invoke-WebRequest https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe -UseBasicParsing -OutFile "$env:TEMP\vcredist_x86.exe"; \
	Start-Process -FilePath $env:TEMP\vcredist_x86.exe -ArgumentList '/q', '/norestart' -PassThru -Wait; \
	Remove-Item "$env:TEMP\vcredist_x86.exe"

# https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=windows&version=6.5.0&product=universalforwarder&filename=splunkforwarder-6.5.0-59c8927def0f-x64-release.msi&wget=true' -UseBasicParsing -OutFile "c:\splunkforwarder.msi";
RUN powershell -Command \
	Invoke-WebRequest https://goo.gl/FozRx6 -UseBasicParsing -OutFile "c:\splunkforwarder.msi";
	
RUN ["msiexec", \
    "/i", "C:\\splunkforwarder.msi", \
    "/qn", \
    "/l*v log.txt", \
    "AGREETOLICENSE=Yes", \
    "RECEIVING_INDEXER=vdc-qasapptst03.stormwind.local:9997", \
    "WINEVENTLOG_APP_ENABLE=0", \
    "WINEVENTLOG_SEC_ENABLE=0", \
    "WINEVENTLOG_SYS_ENABLE=0", \
    "WINEVENTLOG_FWD_ENABLE=0", \
    "WINEVENTLOG_SET_ENABLE=0", \
    "MONITOR_PATH=C:\\inetpub\\logs\\LogFiles\\W3SVC2"]

RUN ["C:\\Program Files\\SplunkUniversalForwarder\\bin\\splunk.exe", "add", "monitor", "-auth", "admin:changeme", "c:\\Logs"]	

## setup base www site
RUN mkdir C:\www
# Creating app pool...
RUN appcmd.exe add apppool /name:www /managedRuntimeVersion:v4.0 /managedPipelineMode:Integrated
# setting 32bit on app pool
RUN appcmd set apppool /apppool.name:www /enable32BitAppOnWin64:true
RUN appcmd set AppPool /apppool.name:www /processModel.identityType:LocalSystem
# Creating website...
RUN appcmd.exe add site /name:www /physicalPath:C:\www /bindings:http/*:1025:
# setting app pool on site
RUN appcmd.exe set app "www/" /applicationPool:"www"

COPY index.html c:/www
COPY deploy-service.cmd c:/
COPY download-latest-package.ps1 c:/
COPY FixDNSEntries.ps1 /

EXPOSE 1025

