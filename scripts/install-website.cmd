@echo off

set package=%1
echo install WWW site - %package%

echo Installing package..."
set "path=c:\www\%package%"
if not exist %path% mkdir %path%
@REM TODO: remove user and password from here -- should be able to see packages without auth
c:\vagrant\resources\upack.exe install %package% --source=http://proget.stormwind.local/upack/BuildAssets --target=%path% --overwrite --user=upack:foobar12

@REM C:\Windows\System32\inetsrv\AppCmd.exe list vdir "www/%package%/"
@REM IF %errorlevel%==1 GOTO DONE

echo Creating app pool...
C:\Windows\System32\inetsrv\appcmd.exe add apppool /name:%package% /managedRuntimeVersion:v4.0 /managedPipelineMode:Integrated
C:\Windows\System32\inetsrv\appcmd set apppool /apppool.name:%package% /enable32BitAppOnWin64:true

echo Creating app...
C:\Windows\System32\inetsrv\AppCmd.exe ADD app /site.name:"www" /path:/%package% /physicalPath:%path%
C:\Windows\System32\inetsrv\appcmd.exe set app "www/%package%" /applicationPool:"%package%"

echo Injecting config
echo TODO -- need to get config from progressive-configs
copy c:\vagrant\config\%package%\*.* %path%

@REM echo Creating website...
@REM C:\Windows\System32\inetsrv\appcmd.exe add site /name:%package% /physicalPath:%path% /bindings:http/*:%port%:
@REM C:\Windows\System32\inetsrv\appcmd.exe set app "%package%/" /applicationPool:"%package%"

:DONE
echo Website is created. You can acces it by url http://127.0.0.1/%package%/

:END