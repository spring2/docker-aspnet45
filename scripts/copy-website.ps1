echo "Copy website folder"
Copy-Item C:\vagrant\website C:\ -Recurse -Force
& iisreset.exe
echo "Done!"
 		 