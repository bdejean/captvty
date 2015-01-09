FROM ubuntu
MAINTAINER Luc

ENV DEBIAN_FRONTEND noninteractive

#
# Install wine1.7 and a few tools
#
RUN dpkg --add-architecture i386

RUN apt-get update && apt-get install -y -q software-properties-common
RUN add-apt-repository ppa:ubuntu-wine/ppa -y

RUN apt-get update && apt-get install -y -q	\
	gawk					\
	unzip					\
	wine1.7					\
	wget					\
	xvfb

RUN apt-get -y -q clean
RUN apt-get -y -q autoremove


#
# Create a user to run Captvty
#
RUN useradd --home-dir /home/luser --create-home -K UID_MIN=42000 luser
USER luser
RUN echo "quiet=on" > ~/.wgetrc

# Again as root since COPY doesn't honor USER
USER root

#
# Install Captvty
#
RUN mkdir /home/luser/captvty
WORKDIR /home/luser/captvty
# RUN wget http://captvty.fr/?captvty-2.3.4.zip -O captvty.zip
# RUN sha1sum captvty.zip | awk '$1 != "c76393686877eaa9d159f2815a3ae47adb8a3a13" { print "Bad checksum"; exit 1; }'
COPY captvty.zip /home/luser/captvty/captvty.zip
RUN unzip captvty.zip
RUN rm captvty.zip



#
# Copy the script needed to setup Wine
# it needs X so it can't be built
#
ADD dotnet_setup.sh /home/luser/

#
# Give everything to luser
#
RUN chown -R luser:luser /home/luser

#
# Install DotNet 4 and some stuff.
# Uses xvfb as a DISPLAY is required.
#
USER luser
ENV WINEARCH win32
RUN xvfb-run winetricks -q dotnet40
RUN wget http://captvty.fr/getgdiplus -O kb975337.exe
RUN xvfb-run wine kb975337.exe /x:kb975337 /q
RUN cp kb975337/asms/10/msft/windows/gdiplus/gdiplus.dll ~/.wine/drive_c/windows/system32
RUN wine reg add HKCU\\Software\\Wine\\DllOverrides /v gdiplus /d native,builtin /f
RUN xvfb-run winetricks -q comctl32
RUN xvfb-run winetricks -q ie8 
RUN wget http://captvty.fr/getflash -O fplayer.exe
RUN xvfb-run wine fplayer.exe -install -au 2

# 
# RUN ls -lah /home/luser/wine /home/luser/captvty
# 
# 


USER luser
WORKDIR /home/luser
# ENTRYPOINT wine /home/captvty/Captvty.exe

