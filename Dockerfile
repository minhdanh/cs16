FROM debian:jessie

ARG steam_user=anonymous
ARG steam_password=
ARG metamod_version=1.20
ARG amxmod_version=1.8.2
ARG yapb_version=4.2.610

RUN apt update && \
  apt install -y lib32gcc1 curl apt-utils xz-utils

RUN mkdir -p /opt/hlds

RUN mkdir -p /opt/steam && cd /opt/steam && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit; exit 0
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 70 validate +quit || :
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 10 validate +quit || :
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit

RUN mkdir -p ~/.steam && \
  ln -s /opt/hlds ~/.steam/sdk32 && \
  ln -s /opt/steam/ /opt/hlds/steamcmd

ADD files/server.cfg /opt/hlds/cstrike/server.cfg
ADD files/steam_appid.txt /opt/hlds/steam_appid.txt
ADD hlds_run.sh /bin/hlds_run.sh
RUN chmod +x /bin/hlds_run.sh

# Install maps
ADD maps/cs_mansion/* /opt/hlds/cstrike/maps/
ADD maps/afk_6killer/* /opt/hlds/cstrike/maps/
ADD maps/css_vietnam/maps/* /opt/hlds/cstrike/maps/
ADD maps/css_vietnam/models/ /opt/hlds/cstrike/models/
ADD maps/css_vietnam_sky/maps/* /opt/hlds/cstrike/maps/
ADD maps/css_vietnam_sky/models/ /opt/hlds/cstrike/models/
ADD maps/css_vietnam_sky/gfx/env/* /opt/hlds/cstrike/gfx/env/

RUN touch /opt/hlds/cstrike/listip.cfg && \
  touch /opt/hlds/cstrike/banned.cfg

# Install metamod
RUN mkdir -p /opt/hlds/cstrike/addons/metamod/dlls
RUN curl -sqL "http://prdownloads.sourceforge.net/metamod/metamod-$metamod_version-linux.tar.gz?download" | tar -C /opt/hlds/cstrike/addons/metamod/dlls -zxvf -
ADD files/liblist.gam /opt/hlds/cstrike/liblist.gam
# Remove this line if you aren't going to install/use amxmodx and dproto
ADD files/plugins.ini /opt/hlds/cstrike/addons/metamod/plugins.ini

# Install dproto
RUN mkdir -p /opt/hlds/cstrike/addons/dproto
ADD files/dproto_i386.so /opt/hlds/cstrike/addons/dproto/dproto_i386.so
ADD files/dproto.cfg /opt/hlds/cstrike/dproto.cfg

# Install AMX mod X
RUN curl -sqL "http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -
RUN curl -sqL "http://www.amxmodx.org/release/amxmodx-$amxmod_version-cstrike-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -
ADD files/amxmodx/maps.ini /opt/hlds/cstrike/addons/amxmodx/configs/maps.ini
ADD files/amxmodx/plugins.ini /opt/hlds/cstrike/addons/amxmodx/configs/plugins.ini
# ADD files/amxmodx/ultimate_sounds.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/ultimate_sounds.amxx
# ADD files/amxmodx/ultimate_sounds.sma /opt/hlds/cstrike/addons/amxmodx/scripting/ultimate_sounds.sma

# Install Yapb
RUN curl -sqL "https://github.com/yapb/yapb/releases/download/$yapb_version/yapb-$yapb_version-linux.tar.xz" | tar -C /opt/hlds/cstrike/ -Jxvf -
ADD files/addons/yapb/conf/yapb.cfg /opt/hlds/cstrike/addons/yapb/conf/yapb.cfg

RUN apt-get remove -y curl && \
  apt-get autoremove -y

WORKDIR /opt/hlds

ENTRYPOINT ["/bin/hlds_run.sh"]
