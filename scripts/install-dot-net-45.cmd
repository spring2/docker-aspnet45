@echo off
echo Installing .NET Framework 4.5
C:\vagrant\resources\NDP452-KB2901907-x86-x64-AllOS-ENU.exe /q
echo Installing ASP.NET 4.5
dism /online /enable-feature /all /featurename:IIS-ASPNET45
echo Installing Visual C++ 2010 redist
C:\vagrant\resources\vcredist_x86.exe /q /norestart
echo Done!