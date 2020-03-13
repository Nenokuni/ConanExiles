FROM debian:buster-slim

ENV INSTALL_DIR /conan
ENV STEAM_CMD_DIR $INSTALL_DIR/steamcmd

RUN mkdir /conan
RUN chmod 775 /conan
RUN chown root:root /conan

RUN set -x \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        psmisc \
        sqlite3 \
        task-japanese \
        locales \
        locales-all \
        procps \
        vim \
        xvfb \
        xauth \
        screen \
        gnupg \
        gnupg2 \
        software-properties-common \
        lib32stdc++6=8.3.0-6 \
        lib32gcc1=1:8.3.0-6 \
        wget=1.20.1-1.1 \
        ca-certificates=20190110 \
    && echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen ja_JP.UTF-8 \
    && dpkg-reconfigure locales \
    && /usr/sbin/update-locale LANG=ja_JP.UTF-8 \
    && wget -O- -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key | apt-key add - \
    && echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" | tee /etc/apt/sources.list.d/wine-obs.list \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-stable \
    && mkdir -p $STEAM_CMD_DIR \
    && cd $STEAM_CMD_DIR \
    && wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxf - \
    && apt-get clean autoclean \
    && apt-get autoremove -y

ENV LC_ALL ja_JP.UTF-8
WORKDIR $INSTALL_DIR
RUN mkdir server
RUN chmod 775 server
RUN chown root:root server
RUN $STEAM_CMD_DIR/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir $INSTALL_DIR/server +login anonymous +app_update 443030 validate +exit

COPY Saved/Config/WindowsServer/Engine.ini /tmp/Engine.ini
COPY Saved/Config/WindowsServer/Game.ini /tmp/Game.ini
COPY Saved/Config/WindowsServer/ServerSettings.ini /tmp/ServerSettings.ini

COPY Saved/Config $INSTALL_DIR/server/ConanSandbox/Saved/Config
COPY Saved/blacklist.txt $INSTALL_DIR/server/ConanSandbox/Saved/blacklist.txt

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
RUN chown root:root /entrypoint.sh

COPY start.sh /start.sh
RUN chmod 755 /start.sh
RUN chown root:root /start.sh

COPY update.sh /update.sh
RUN chmod 755 /update.sh
RUN chown root:root /update.sh

COPY kill.sh /kill.sh
RUN chmod 755 /kill.sh
RUN chown root:root /kill.sh

EXPOSE 7777/udp 27015/udp 25575/tcp
