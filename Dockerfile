FROM phusion/baseimage:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends sudo

RUN useradd -m yayamao
RUN adduser yayamao sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER yayamao

WORKDIR /home/yayamao
COPY --chown=yayamao:yayamao ./ .dotfiles/
RUN INSTALL_FONTS=true INSTALL_VIM_PLUGINS=false .dotfiles/setup.sh && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV DEBIAN_FRONTEND teletype
