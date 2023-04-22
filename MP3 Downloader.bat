@echo off
set zip=https://cdn.discordapp.com/attachments/923633338378489856/1098608419251961977/7z.exe
set ytdlp=https://github.com/yt-dlp/yt-dlp/releases/download/2023.03.04/yt-dlp.exe
set ffmpeg=https://cdn.discordapp.com/attachments/923633338378489856/1098625290957226014/ffmpeg-2023-04-19-git-c17e33c058-essentials_build.7z
set pathed=https://cdn.discordapp.com/attachments/923633338378489856/1098373423262085200/pathed.exe
set GSharpTools=https://cdn.discordapp.com/attachments/923633338378489856/1098373423639568384/GSharpTools.dll
set log4net=https://cdn.discordapp.com/attachments/923633338378489856/1098373423983505468/log4net.dll
set installdir=%USERPROFILE%\Documents\PATH_Programs
set tempdir=%temp%\yt-dlp

:yt-dlpCheck
cls
where /q yt-dlp
if %errorlevel% == 0 goto :ffmpegCheck
set program=yt-dlp
goto :screen

:ffmpegCheck
where /q ffmpeg
if %errorlevel% == 0 goto :dl
set program=ffmpeg
goto :screen

:screen
if not exist %tempdir% mkdir %tempdir%
echo *** This screen will never reappear ***
echo.
echo To download MP3s this script needs %program%,
echo which is not installed actually. 
echo.
echo %program% will be installed in %installdir%
echo.
:cf
set /p cf="Change folder? (y/n) > "
if %cf% == y echo. & echo Drag the folder here & set /p installdir="> "

if not exist %installdir% mkdir %installdir%

if %program% == ffmpeg goto :ffmpegDl

:yt-dlpDl
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; Invoke-WebRequest -Uri '%ytdlp%' -OutFile '%installdir%/yt-dlp.exe'"
goto :pathedDl

:ffmpegDl
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; Invoke-WebRequest -Uri '%zip%' -OutFile '%tempdir%/7z.exe'"
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; Invoke-WebRequest -Uri '%ffmpeg%' -OutFile '%tempdir%/ffmpeg.7z'"
%tempdir%/7z.exe x %tempdir%/ffmpeg.7z ffmpeg-2023-04-19-git-c17e33c058-essentials_build/bin/ffmpeg.exe ffmpeg-2023-04-19-git-c17e33c058-essentials_build/bin/ffprobe.exe -o%installdir%
move %installdir%\ffmpeg-2023-04-19-git-c17e33c058-essentials_build\bin\ffmpeg.exe %installdir%
move %installdir%\ffmpeg-2023-04-19-git-c17e33c058-essentials_build\bin\ffprobe.exe %installdir%
rmdir %installdir%\ffmpeg-2023-04-19-git-c17e33c058-essentials_build /s /q

:pathedDl
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; Invoke-WebRequest -Uri '%pathed%' -OutFile '%tempdir%/pathed.exe'"
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; Invoke-WebRequest -Uri '%GSharpTools%' -OutFile '%tempdir%/GSharpTools.dll'"
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; Invoke-WebRequest -Uri '%log4net%' -OutFile '%tempdir%/log4net.dll'"
echo %path% | findstr /c:%installdir% >nul || (%tempdir%/pathed.exe /APPEND %installdir% /USER)
if exist %tempdir% rmdir %tempdir% /s /q
echo.
echo %program% installed successfully,
echo restart the script to continue
echo.
pause
exit

:dl
set /p url="Paste link: "
echo.
yt-dlp -x -f bestaudio --audio-format mp3 %url%
echo.
echo MP3 downloaded successfully
echo.
pause
goto :yt-dlpCheck
