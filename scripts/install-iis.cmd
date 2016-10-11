@echo off

echo Installing IIS, it will take a while...
CMD /C START /w PKGMGR.EXE /l:log.etw /iu:IIS-WebServerRole
c:\windows\system32\inetsrv\appcmd.exe unlock config -section:system.webServer/handlers
c:\vagrant\resources\vcredist_x86.exe /q /norestart
echo Done!