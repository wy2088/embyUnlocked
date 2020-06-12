FROM lsiobase/ubuntu:bionic

ENV DEBIAN_FRONTEND="noninteractive" 

RUN echo "Bootstrap APT System" && \
 rm -rf /etc/apt/sources.list && \
 echo "deb http://mirrors.aliyun.com/ubuntu focal main restricted" >> /etc/apt/sources.list && \
 echo "deb http://mirrors.aliyun.com/ubuntu focal-updates main restricted" >> /etc/apt/sources.list && \
 echo "deb http://mirrors.aliyun.com/ubuntu focal universe" >> /etc/apt/sources.list && \
 echo "deb http://mirrors.aliyun.com/ubuntu focal-updates universe" >> /etc/apt/sources.list && \
 echo "deb http://mirrors.aliyun.com/ubuntu focal multiverse" >> /etc/apt/sources.list && \
 echo "deb http://mirrors.aliyun.com/ubuntu focal-updates multiverse" >> /etc/apt/sources.list && \
 echo "deb http://mirrors.aliyun.com/ubuntu focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
 echo "deb http://mirrors.aliyun.com/ubuntu focal-security main restricted" >> /etc/apt/sources.list && \
 echo "deb http://mirrors.aliyun.com/ubuntu focal-security universe" >> /etc/apt/sources.list && \
 echo "deb http://mirrors.aliyun.com/ubuntu focal-security multiverse" >> /etc/apt/sources.list && \
 apt update -y && apt dist-upgrade -y && apt upgrade -y && apt autoremove -y

RUN echo "Install APT Packages" && \
 apt install -y cpio jq rpm2cpio curl --no-install-recommends

RUN echo "Install Emby Packages" && \
 mkdir -p \
	/app/emby && \
 if [ -z ${EMBY_RELEASE+x} ]; then \
	EMBY_RELEASE=$(curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest \
	| jq -r '. | .tag_name'); \
 fi && \
 curl -o \
	/tmp/emby.rpm -L \
	"https://github.com/MediaBrowser/Emby.Releases/releases/download/${EMBY_RELEASE}/emby-server-rpm_${EMBY_RELEASE}_x86_64.rpm" && \
 cd /tmp && \
 rpm2cpio emby.rpm \
	| cpio -i --make-directories && \
 mv -t \
	/app/emby/ \
	/tmp/opt/emby-server/system/* \
	/tmp/opt/emby-server/lib/samba/* \
	/tmp/opt/emby-server/lib/* \
	/tmp/opt/emby-server/bin/ff* \
	/tmp/opt/emby-server/etc

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

RUN echo "Signing Certifications" && \
 mkdir -p /cracks/ssl/ && chmod 700 /cracks/ssl && \
 apt install -y openssl --no-install-recommends && \
 openssl req -x509 -nodes -days 365000 \
  -newkey rsa:2048 \
  -keyout /cracks/ssl/root.key -out /cracks/ssl/root.crt \
  -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=mb3admin.com" && \
 echo "Key Identity: " && \
 cat /cracks/ssl/* && \
 echo "Sending Certifications to System" && \
 mkdir -p /usr/share/ca-certificates/extra && cp /cracks/ssl/root.crt /usr/share/ca-certificates/extra/ && \
 echo "extra/root.crt" >> /etc/ca-certificates.conf && update-ca-certificates

# RUN echo "Hijacking Hosts" && \
#  echo "* original hosts ->" && cat /etc/hosts || true && \
#  echo "127.0.0.1 mb3admin.com" >> /etc/hosts && \
#  echo "* new hosts file ->" && cat /etc/hosts || true
# Hosts was overwritten during boot so.....
# We will do it again in init scripts later

RUN echo "Setting Up Crack Server" && \
 apt install -y nginx --no-install-recommends && \
 mkdir -p /etc/nginx/conf.d/

COPY nginx.conf /etc/nginx/conf.d/pathcer.conf

RUN service nginx restart

RUN echo "Cleaning APT System" && \
 apt remove --purge -y cpio jq curl rpm2cpio && apt autoremove -y && rm -rf /var/lib/apt/lists/*

COPY emby/* /etc/services.d/emby/
COPY startup/* /etc/cont-init.d/

EXPOSE 8096 8920
VOLUME /config
