@echo off
set ytdlp=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe
set ffmpeg=https://github.com/ffbinaries/ffbinaries-prebuilt/releases/download/v6.1/ffmpeg-6.1-win-64.zip
set ffprobe=https://github.com/ffbinaries/ffbinaries-prebuilt/releases/download/v6.1/ffprobe-6.1-win-64.zip
set pathed=https://cdn.discordapp.com/attachments/923633338378489856/1195024918329438278/pathed.exe
set GSharpTools=https://cdn.discordapp.com/attachments/923633338378489856/1195024918673362974/GSharpTools.dll
set log4net=https://cdn.discordapp.com/attachments/923633338378489856/1195024919126360196/log4net.dll
set installdir=%USERPROFILE%\Documents\PATH_Programs
set tempdir=%temp%\ytdownloader

:yt-dlpCheck
where /q yt-dlp
if %errorlevel%==0 goto :ffmpegCheck
set program=yt-dlp
goto :screen

:ffmpegCheck
where /q ffmpeg
if %errorlevel%==0 goto :setdefaults
set program=ffmpeg
goto :screen

:screen
cls
echo *** This screen will never reappear ***
echo This YouTube downloader needs %program%,
echo it will be installed in %installdir%
echo.
set /p cf="Change folder? (y/n) > "

if %cf%==Y ( set cf=y
) else if %cf%==N set cf=n
if %cf%==y echo Drag the folder here & set /p installdir="> "
if not exist %installdir% mkdir %installdir%
if not exist %tempdir% mkdir %tempdir%

cls
echo Downloading and installing, please wait
if %program%==ffmpeg goto :ffmpegDl

:yt-dlpDl
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; Invoke-WebRequest -Uri '%ytdlp%' -OutFile '%installdir%\yt-dlp.exe'"
goto :pathedDl

:ffmpegDl
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; Invoke-WebRequest -Uri '%ffmpeg%' -OutFile '%tempdir%\ffmpeg.zip'"
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; Invoke-WebRequest -Uri '%ffprobe%' -OutFile '%tempdir%\ffprobe.zip'"
tar -xf "%tempdir%\ffmpeg.zip" -C "%installdir%"
tar -xf "%tempdir%\ffprobe.zip" -C "%installdir%"

:pathedDl
echo %path% | findstr /c:%installdir% >nul || (
    %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; Invoke-WebRequest -Uri '%pathed%' -OutFile '%tempdir%\pathed.exe'"
    %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; Invoke-WebRequest -Uri '%GSharpTools%' -OutFile '%tempdir%\GSharpTools.dll'"
    %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command "&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; Invoke-WebRequest -Uri '%log4net%' -OutFile '%tempdir%\log4net.dll'"
    %tempdir%\pathed.exe /APPEND %installdir% /USER
)
if exist %tempdir% rmdir %tempdir% /s /q
start "" "%~f0"
exit

:setdefaults
set track=bestaudio+bestvideo
set av=x
set ao=_
set vo=_
set format=mp4
set mp3=_
set ogg=_
set aac=_
set mp4=x
set mkv=_
set noconv=_

:settings
cls
echo Track.....Enter 1 to switch  #  Convert.....Enter 2 to switch
echo [%av%] Audio + video            #  [%mp4%] MP4      [%mp3%] MP3
echo [%ao%] Audio only               #  [%mkv%] MKV      [%ogg%] OGG
echo [%vo%] Video only               #  [%noconv%] No Conv  [%aac%] AAC
echo.
set /p url="Select option / Paste link: "

if %url%==1 ( goto :track
) else if %url%==2 ( goto :format
) else if "%url:~0,4%"=="http" goto :download
goto :settings

:track
if %av%==x (
    set av=_
    set ao=x
    set track=bestaudio
    goto :settings
)
if %ao%==x (
    set ao=_
    set vo=x
    set track=bestvideo
    goto :settings
)
if %vo%==x (
    set vo=_
    set av=x
    set track=bestaudio+bestvideo
    goto :settings
)

:format
if %mp3%==x (
    set mp3=_
    set ogg=x
    set format=ogg
    goto :settings
)
if %ogg%==x (
    set ogg=_
    set aac=x
    set format=aac
    goto :settings
)
if %aac%==x (
    set aac=_
    set mp4=x
    set format=mp4
    goto :settings
)
if %mp4%==x (
    set mp4=_
    set mkv=x
    set format=mkv
    goto :settings
)
if %mkv%==x (
    set mkv=_
    set noconv=x
    set format=0
    goto :settings
)
if %noconv%==x (
    set noconv=_
    set mp3=x
    set format=mp3
    goto :settings
)

:download
cls
yt-dlp --get-title %url% > title.tmp
set /p title=<title.tmp
del title.tmp

set "allowedChars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_"

:filterTitle
if "%title%"=="" goto :filtered
set "char=%title:~0,1%"
echo %allowedChars% | find "%char%" >nul
if %errorlevel%==0 set "filteredTitle=%filteredTitle%%char%"
set "title=%title:~1%"
goto :filterTitle

:filtered
if %format% neq 0 set "ytdlpoutput"="-o ytdlpoutput "
yt-dlp -f %track% %ytdlpoutput% %url%
if %format% neq 0 goto :success
for %%I in (ytdlpoutput) do set "input=%%I"
ffmpeg -i "%input%" "%filteredTitle%.%format%"
del %input%

:success
echo ## Downloaded successfully ########################################################
echo.
pause
goto :settings
