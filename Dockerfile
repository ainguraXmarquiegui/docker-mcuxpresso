FROM debian:bookworm
LABEL maintainer="reibax <reibax@gmail.com>" \
description="Everything needed to run MCUExpresso in a docker container with X11 forwarding."

ARG IDE_VERSION
ARG USERNAME
ARG UID
ARG GID

COPY ./mcuxpressoide-${IDE_VERSION}.x86_64.deb.bin /tmp

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install \
        passwd \
        diffutils \
        git \
        openjdk-17-jre \
        openjdk-17-jdk \
        libcanberra0 \
        libcanberra-gtk0 \
        libcanberra-gtk3-0 \
        libusb-dev \
        libusb-1.0-0-dev \
	libxcb-icccm4 \
	libxcb-image0 \
	libxcb-keysyms1 \
	libxcb-render-util0 \
        ncurses-base \
        libncurses5 \
        packagekit-gtk3-module \
        webkit2gtk-driver \
        wget \
        cmake \
        make \
        unzip \
        patch \
        build-essential \
        dfu-util \
        dfu-programmer && \
    groupadd wheel && \
    usermod -aG wheel ${USERNAME} && \
    mkdir -p /home/${USERNAME} && \
    echo "alias ls='ls --color=auto'" >> /home/${USERNAME}/.bashrc && \
    echo "PS1='\u@\H [\w]$ '" >> /home/${USERNAME}/.bashrc && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

RUN set -e; \
  cd /tmp/; \
  mkdir -p /tmp/mcu/; \
  chmod a+x ./mcuxpressoide-${IDE_VERSION}.x86_64.deb.bin; \
  ./mcuxpressoide-${IDE_VERSION}.x86_64.deb.bin --noexec --target /tmp/mcu; \
  cd /tmp/mcu; \
  dpkg --unpack ./JLink_Linux_x86_64.deb; \
  rm -f /var/lib/dpkg/info/jlink.postinst; \
  dpkg --force-depends --configure jlink; \
  dpkg --unpack mcuxpressoide-${IDE_VERSION}.x86_64.deb; \
  rm -f /var/lib/dpkg/info/mcuxpressoide.postinst; \
  dpkg --force-depends --configure mcuxpressoide; \
  mkdir -p /usr/share/NXPLPCXpresso; \
  chmod a+w /usr/share/NXPLPCXpresso; \
  ln -s /usr/local/mcuxpressoide-${IDE_VERSION} /usr/local/mcuxpressoide; \
  ln -sf /usr/local/mcuxpressoide-${IDE_VERSION}/ide/mcuxpressoide /usr/bin/mcuxpressoide; \
  rm -rf /tmp/mcuxpressoide-${IDE_VERSION}.x86_64.deb.bin; \
  rm -rf /tmp/mcu;

USER ${USERNAME}
CMD ["/usr/bin/mcuxpressoide"]
