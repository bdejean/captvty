FROM ubuntu
MAINTAINER Benoît Dejean <bdejean@gmail.com>

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

# Again as root since COPY doesn't honor USER
COPY dotnet_setup.sh /tmp/
RUN chmod a+rx /tmp/dotnet_setup.sh

#
# Create a user to run Captvty
#
RUN useradd --home-dir /home/luser --create-home -K UID_MIN=42000 luser
USER luser
RUN echo "quiet=on" > ~/.wgetrc

WORKDIR /tmp

#
# Install DotNet 4 and some stuff.
# Uses xvfb as a DISPLAY is required.
# Calling each action within a separate xvfb-run makes this fail
# that's why a script is added and then run
#
RUN xvfb-run ./dotnet_setup.sh


#
# Install Captvty
#
RUN mkdir /home/luser/captvty
RUN wget http://captvty.fr/?captvty-2.3.5.zip -O ./captvty.zip && sha1sum captvty.zip | awk '$1 != "ea86d13633b2834b5134de220995333f95e7557f" { print "Bad checksum"; exit 1; }'
RUN unzip ./captvty.zip -d /home/luser/captvty
# Set the download directory
RUN mkdir /home/luser/downloads

#
# Install a default configuration
#
# RUN cat /home/luser/captvty/captvty.ini | uconv -f UTF-16LE | sed 's/DownloadDir=.*/DownloadDir=Z:\\home\\luser\\downloads\r/' | uconv -t UTF-16LE > /home/luser/captvty/captvty.ini.new && mv -f /home/luser/captvty/captvty.ini.new /home/luser/captvty/captvty.ini
USER root
COPY captvty.ini /home/luser/captvty/
RUN chown luser:luser /home/luser/captvty/captvty.ini

#
# Cleanup
#
USER root
RUN find /tmp -mindepth 1 -exec rm -rf {} +
RUN rm -rf /home/luser/.cache
RUN apt-mark auto 				\
	gawk					\
	unzip					\
	wget					\
	xvfb

RUN apt-get -y -q autoremove
RUN apt-get -y -q clean

# COPY entrypoint-captvty.sh /home/luser/
# RUN chmod +rx /home/luser/entrypoint-captvty.sh
# RUN chown luser:luser /home/luser/entrypoint-captvty.sh
# ENTRYPOINT /home/luser/entrypoint-captvty.sh

USER luser
WORKDIR /home/luser
CMD wine ./captvty/Captvty.exe >/dev/null 2>&1; rm -rf /tmp/.wine-*

# ENTRYPOINT wine /home/captvty/Captvty.exe
