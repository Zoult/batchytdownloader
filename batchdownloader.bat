@echo off
set ytdlp=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe
set ffmpeg=https://github.com/ffbinaries/ffbinaries-prebuilt/releases/download/v6.1/ffmpeg-6.1-win-64.zip
set ffprobe=https://github.com/ffbinaries/ffbinaries-prebuilt/releases/download/v6.1/ffprobe-6.1-win-64.zip
set pathed=https://github.com/Zoult/pathed/raw/refs/heads/main/pathed.exe
set installdir=%USERPROFILE%\Documents\PATH_Programs
set tempdir=%temp%\batchdownloader

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
echo Batch downloader needs %program%,
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
curl -L -o %installdir%\yt-dlp.exe %ytdlp%
goto :pathedDl

:ffmpegDl
curl -L -o %tempdir%\ffmpeg.zip %ffmpeg%
curl -L -o %tempdir%\ffprobe.zip %ffprobe%
tar -xf "%tempdir%\ffmpeg.zip" -C "%installdir%"
tar -xf "%tempdir%\ffprobe.zip" -C "%installdir%"

:pathedDl
echo %path% | findstr /c:%installdir% >nul || (
    curl -L -o %tempdir%\pathed.exe %pathed%
    %tempdir%\pathed.exe /APPEND %installdir% /USER
)
if exist %tempdir% rmdir %tempdir% /s /q
exit

:setdefaults
set track=bestaudio+bestvideo
set av=x
set ao=_
set vo=_
set it=_
set format=mp4
set mp3=_
set ogg=_
set aac=_
set mp4=x
set mkv=_
set avi=_
set dis=_
set noconv=_

:settings
cls
echo Track.....Enter 1 to switch  #  Format.....Enter 2 to switch
echo [%av%] Audio + video            #  [%mp4%] MP4      [%mp3%] MP3
echo [%ao%] Audio only               #  [%mkv%] MKV      [%ogg%] OGG
echo [%vo%] Video only               #  [%avi%] AVI      [%aac%] AAC
echo                              #  [%dis%] Discord  [%noconv%] No Conv
echo.
set /p "url=Enter option / Paste link: "
set "url=%url: =%"
for /f "tokens=1,* delims=&" %%a in ("%url%") do set "url=%%a"

if "%url%"=="1" ( goto :track
) else if "%url%"=="2" ( goto :format
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
    set it=x
    set track=b
    goto :settings
)

:format
if %mp4%==x (
    set mp4=_
    set mkv=x
    set format=mkv
    goto :settings
)
if %mkv%==x (
    set mkv=_
    set avi=x
    set format=avi
    goto :settings
)
if %avi%==x (
    set avi=_
    set dis=x
    set format=dis
    goto :settings
)
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
    set noconv=x
    set format=0
    goto :settings
)
if %dis%==x (
    set dis=_
    set mp3=x
    set format=mp3
    goto :settings
)
if %noconv%==x (
    set noconv=_
    set mp4=x
    set format=mp4
    goto :settings
)

:download
for /f "delims=" %%a in ('yt-dlp --get-title %url%') do set "title=%%a"

if %format% neq 0 set ytdlpoutput=-o ytdlpoutput
yt-dlp -f %track% %ytdlpoutput% %url%
if %format%==0 goto :success
for %%I in (ytdlpoutput*) do set "input=%%I"

if %format%==dis (
    set format=mp4
    set scale=-vf "scale=min(640\,iw):min(320\,ih),setsar=1"
)
ffmpeg -i "%input%" %scale% "%title%.%format%"
del %input%

:success
echo ## Downloaded successfully ########################################################
echo.
pause
goto :settings
