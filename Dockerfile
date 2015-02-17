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
RUN wget http://captvty.fr/?captvty-2.3.4.1.zip -O ./captvty.zip
RUN sha1sum captvty.zip | awk '$1 != "b1f8c36352581d05ff421b73e173cfa98a10f08a" { print "Bad checksum"; exit 1; }'
RUN unzip ./captvty.zip -d /home/luser/captvty


#
# Cleanup
#
USER root
RUN find /tmp -mindepth 1 -exec rm -rf {} +
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
RUN mkdir /home/luser/downloads

CMD wine ./captvty/Captvty.exe >/dev/null 2>&1; rm -rf /tmp/.wine-*

# ENTRYPOINT wine /home/captvty/Captvty.exe
