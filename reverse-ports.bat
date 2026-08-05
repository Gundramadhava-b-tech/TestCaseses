@echo off
echo =======================================================
echo     AeroDiag Mobile Port Forwarding Bridge
echo =======================================================
echo.
echo Establishing USB connection bridge for ports 3000 and 5000...
"C:\Users\gundr\AppData\Local\Android\Sdk\platform-tools\adb.exe" reverse tcp:3000 tcp:3000
"C:\Users\gundr\AppData\Local\Android\Sdk\platform-tools\adb.exe" reverse tcp:5000 tcp:5000
echo.
echo [SUCCESS] Ports 3000 & 5000 are now forwarded from your mobile phone to your PC!
echo You can keep this window open or close it.
echo.
pause
