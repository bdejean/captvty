#!/bin/sh

export WINEARCH=win32

winetricks -q dotnet40
wget http://captvty.fr/getgdiplus -O kb975337.exe
wine kb975337.exe /x:kb975337 /q
cp kb975337/asms/10/msft/windows/gdiplus/gdiplus.dll ~/.wine/drive_c/windows/system32
wine reg add HKCU\\Software\\Wine\\DllOverrides /v gdiplus /d native,builtin /f
winetricks -q comctl32
winetricks -q ie8 
# wget http://captvty.fr/getflash -O fplayer.exe
wget http://fpdownload.macromedia.com/get/flashplayer/pdc/16.0.0.235/install_flash_player_ax.exe -O fplayer.exe
wine fplayer.exe -install -au 2
# ENTRYPOINT wine /home/captvty/Captvty.exe
