# builder of pulseaudio
FROM ubuntu:22.04 AS pulseaudiolib

RUN apt update && apt install -y build-essential dpkg-dev libpulse-dev git autoconf libtool sudo lsb-release && \
    git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git && \
    cd pulseaudio-module-xrdp && \
    scripts/install_pulseaudio_sources_apt.sh && \
    ./bootstrap && ./configure PULSE_DIR=$HOME/pulseaudio.src && \
    make

# xrdp image
FROM ubuntu:22.04
ARG ADDITIONAL_PACKAGES=""
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt install -y software-properties-common apt-utils && \
    add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner" && \
    apt update && apt -y full-upgrade && apt install -y \
    ca-certificates \
    lsb-release \
    crudini \
    less \
    locales \
    openssh-server \
    pulseaudio \
    sudo \
    supervisor \
    uuid-runtime \
    vim \
    wget \
    curl \
    xauth \
    xautolock \
    xfce4 \
    xfce4-clipman-plugin \
    xfce4-cpugraph-plugin \
    xfce4-netload-plugin \
    xfce4-screenshooter \
    xfce4-taskmanager \
    xfce4-terminal \
    xfce4-xkb-plugin \
    xorgxrdp \
    xprintidle \
    xrdp && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    wget -qO- https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb https://mirrors.ustc.edu.cn/postgresql/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt update && apt install -y \
    telnet \
    iputils-ping \
    traceroute \
    zip \
    unzip \
    dialog \
    dnsutils \
    fuse \
    libfuse2 \
    iproute2 \
    zsh \
    zsh-syntax-highlighting \
    git \
    tmux \
    tree \
    lrzsz \
    jq \
    language-pack-zh-hans \
    *wqy* \
    fcitx-googlepinyin \
    fcitx-sunpinyin \
    firefox \
    google-chrome-stable \
    vlc \
    ansible \
    openjdk-11-jre \
    python3-venv \
    python3-pip \
    kafkacat \
    postgresql-client-13 \
    redis-tools \
    mongodb-clients \
    libaio1 \
    libtinfo5 \
    $ADDITIONAL_PACKAGES && \
    apt remove -y light-locker xscreensaver && \
    apt autoremove -y && \
    rm -rf /var/cache/apt /var/lib/apt/lists && \
    mkdir -p /var/lib/xrdp-pulseaudio-installer

COPY --from=pulseaudiolib /pulseaudio-module-xrdp/src/.libs/*.so /var/lib/xrdp-pulseaudio-installer/
#ADD rootfs /
ADD bin /usr/bin
ADD etc /etc
ADD autostart /etc/xdg/autostart
#
## Configure
#RUN mkdir /var/run/dbus && \
#    cp /etc/X11/xrdp/xorg.conf /etc/X11 && \
#    sed -i "s/console/anybody/g" /etc/X11/Xwrapper.config && \
#    sed -i "s/xrdp\/xorg/xorg/g" /etc/xrdp/sesman.ini && \
#    locale-gen en_US.UTF-8 && \
#    echo "pulseaudio -D --enable-memfd=True" > /etc/skel/.Xsession && \
#    echo "xfce4-session" >> /etc/skel/.Xsession && \
#    rm -rf /etc/ssh/ssh_host_* && \
#    rm -rf /etc/xrdp/rsakeys.ini /etc/xrdp/*.pem
#
## Docker config
#VOLUME ["/etc/ssh","/home"]
#EXPOSE 3389 22
#ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
#CMD ["supervisord"]
