# http://stackoverflow.com/a/9949105
$ErrorActionPreference = "Stop"

echo "Setting up access to folder"
icacls "C:\www" /grant 'Everyone:(OI)(CI)F'