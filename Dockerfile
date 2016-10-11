FROM microsoft/aspnet

# base .NET and ASP.NET
# RUN powershell -Command Add-WindowsFeature Web-Asp-Net
RUN powershell -Command Add-WindowsFeature NET-Framework-45-ASPNET
RUN powershell -Command Add-WindowsFeature Web-Asp-Net45

# Install Chocolatey
ENV chocolateyUseWindowsCompression false
RUN @powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

RUN mkdir c:\resources
RUN mkdir c:\scripts

EXPOSE 1025

ADD resources/ /resources
ADD scripts/ /scripts

RUN c:\windows\system32\inetsrv\appcmd.exe unlock config -section:system.webServer/handlers
RUN c:\resources\vcredist_x86.exe /q /norestart

RUN c:\scripts\enable-wcf.cmd

RUN rd c:\scripts /s /q
RUN rd c:\resources /s /q
