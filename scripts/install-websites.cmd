@echo off

if not exist c:\www mkdir c:\www
copy c:\vagrant\www\*.* c:\www

echo Creating app pool...
C:\Windows\System32\inetsrv\appcmd.exe add apppool /name:www /managedRuntimeVersion:v4.0 /managedPipelineMode:Integrated
C:\Windows\System32\inetsrv\appcmd set apppool /apppool.name:www /enable32BitAppOnWin64:true

echo Creating website...
C:\Windows\System32\inetsrv\appcmd.exe add site /name:www /physicalPath:C:\www /bindings:http/*:1025:
C:\Windows\System32\inetsrv\appcmd.exe set app "www/" /applicationPool:"www"

echo Website is created. You can acces it by url http://127.0.0.1:1025/


call c:\vagrant\scripts\install-website.cmd Progressive.DocBlend.API
call c:\vagrant\scripts\install-website.cmd StorePortal
call c:\vagrant\scripts\install-website.cmd CustomerPortal
call c:\vagrant\scripts\install-website.cmd OnlineApplication
call c:\vagrant\scripts\install-website.cmd Progressive.SalesTaxService
call c:\vagrant\scripts\install-website.cmd Progressive.WebServices.Application

@echo Reset IIS for good measure
iisreset
