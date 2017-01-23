FROM microsoft/windowsservercore

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# base IIS, .NET and ASP.NET
RUN Add-WindowsFeature Web-Server; \
	Add-WindowsFeature NET-Framework-45-ASPNET; \
    Add-WindowsFeature Web-Asp-Net45; \
    Remove-Item -Recurse C:\inetpub\wwwroot\*; \
	cmd /c 'setx /M PATH "%PATH%;C:\Windows\System32\inetsrv"';

#install the needed Windows IIS features for WCF
RUN dism /Online /Enable-Feature /all \
	/FeatureName:WAS-WindowsActivationService \
	/FeatureName:WAS-ProcessModel \
	/FeatureName:WAS-ConfigurationAPI \
	/FeatureName:WCF-HTTP-Activation45

#RUN dism /Online /Enable-Feature /all /FeatureName:WCF-HTTP-Activation
#RUN dism /Online /Enable-Feature /all /FeatureName:WAS-NetFxEnvironment

# common tools:
# nano - text based editor
RUN Invoke-WebRequest http://www.nano-editor.org/dist/v2.2/NT/nano-2.2.6.zip -UseBasicParsing -OutFile "$env:TEMP\nano-2.2.6.zip"; \
	Expand-Archive -Path "$env:TEMP\nano-2.2.6.zip" -DestinationPath c:\bin -Force; \
	Remove-Item "$env:TEMP\nano-2.2.6.zip"; \
	cmd /c 'setx /M PATH "%PATH%;c:\bin;"'

# common vc++ redists
RUN Invoke-WebRequest https://download.microsoft.com/download/5/B/C/5BC5DBB3-652D-4DCE-B14A-475AB85EEF6E/vcredist_x86.exe -UseBasicParsing -OutFile "$env:TEMP\vcredist_x86.exe"; \
	Start-Process -FilePath $env:TEMP\vcredist_x86.exe -ArgumentList '/q', '/norestart' -PassThru -Wait; \
	Remove-Item "$env:TEMP\vcredist_x86.exe"; \
	Invoke-WebRequest https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe -UseBasicParsing -OutFile "$env:TEMP\vcredist_x86.exe"; \
	Start-Process -FilePath $env:TEMP\vcredist_x86.exe -ArgumentList '/q', '/norestart' -PassThru -Wait; \
	Remove-Item "$env:TEMP\vcredist_x86.exe"

## setup base www site
RUN mkdir C:\www; \
	appcmd.exe unlock config -section:system.webServer/handlers; \
	appcmd delete site 'Default Web Site'; \
	appcmd.exe add apppool /name:www /managedRuntimeVersion:v4.0 /managedPipelineMode:Integrated; \
	appcmd set apppool /apppool.name:www /enable32BitAppOnWin64:true; \
	appcmd set AppPool /apppool.name:www /processModel.identityType:LocalSystem; \
	appcmd.exe add site /name:www /physicalPath:C:\www /bindings:http/*:80:; \
	appcmd.exe set app "www/" /applicationPool:"www";
COPY index.html c:/www
	
COPY init.ps1 startup.ps1 ServiceMonitor.exe /

EXPOSE 80
CMD c:/startup.ps1
