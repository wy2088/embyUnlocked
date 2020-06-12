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
 apt update -y

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
 echo "c2VydmVyIHsKCiAgICBsaXN0ZW4gNDQzIHNzbDsKICAgIHNlcnZlcl9uYW1lIG1iM2FkbWluLmNvbTsKCiAgICBzc2xfY2VydGlmaWNhdGUgL2NyYWNrcy9zc2wvcm9vdC5jcnQ7CiAgICBzc2xfY2VydGlmaWNhdGVfa2V5IC9jcmFja3Mvc3NsL3Jvb3Qua2V5OwoKICAgIHNzbF9zZXNzaW9uX3RpbWVvdXQgNW07CiAgICBzc2xfcHJvdG9jb2xzIFRMU3YxIFRMU3YxLjEgVExTdjEuMjsKICAgIHNzbF9jaXBoZXJzIEVDREhFLVJTQS1BRVMxMjgtR0NNLVNIQTI1NjpISUdIOiFhTlVMTDohTUQ1OiFSQzQ6IURIRTsKICAgIHNzbF9wcmVmZXJfc2VydmVyX2NpcGhlcnMgb247CiAgICAKICAgIGFkZF9oZWFkZXIgQWNjZXNzLUNvbnRyb2wtQWxsb3ctT3JpZ2luICo7CiAgICBhZGRfaGVhZGVyIEFjY2Vzcy1Db250cm9sLUFsbG93LUhlYWRlcnMgKjsKICAgIGFkZF9oZWFkZXIgQWNjZXNzLUNvbnRyb2wtQWxsb3ctTWV0aG9kICo7CiAgICBhZGRfaGVhZGVyIEFjY2Vzcy1Db250cm9sLUFsbG93LUNyZWRlbnRpYWxzIHRydWU7CgogICAgbG9jYXRpb24gL2FkbWluL3NlcnZpY2UvcmVnaXN0cmF0aW9uL3ZhbGlkYXRlRGV2aWNlIHsKICAgICAgICBkZWZhdWx0X3R5cGUgYXBwbGljYXRpb24vanNvbjsKICAgICAgICByZXR1cm4gMjAwICd7ImNhY2hlRXhwaXJhdGlvbkRheXMiOiAzNjUsIm1lc3NhZ2UiOiAiRGV2aWNlIFZhbGlkIiwicmVzdWx0Q29kZSI6ICJHT09EIn0nOwogICAgfQoKICAgIGxvY2F0aW9uIC9hZG1pbi9zZXJ2aWNlL3JlZ2lzdHJhdGlvbi92YWxpZGF0ZSB7CiAgICAgICAgZGVmYXVsdF90eXBlIGFwcGxpY2F0aW9uL2pzb247CiAgICAgICAgcmV0dXJuIDIwMCAneyJmZWF0SWQiOiIiLCJyZWdpc3RlcmVkIjp0cnVlLCJleHBEYXRlIjoiMjA5OS0wMS0wMSIsImtleSI6IiJ9JzsKICAgIH0KICAgIGxvY2F0aW9uIC9hZG1pbi9zZXJ2aWNlL3JlZ2lzdHJhdGlvbi9nZXRTdGF0dXMgewogICAgICAgIGRlZmF1bHRfdHlwZSBhcHBsaWNhdGlvbi9qc29uOwogICAgICAgIHJldHVybiAyMDAgJ3siZGV2aWNlU3RhdHVzIjoiMCIsInBsYW5UeXBlIjoiTGlmZXRpbWUiLCJzdWJzY3JpcHRpb25zIjp7fX0nOwogICAgfQoKfQo=" \
  | base64 --decode | tee -a /etc/nginx/conf.d/pathcer.conf && \
# restart to check config
 service nginx restart

RUN echo "Cleaning APT System" && \
 apt remove --purge -y cpio jq rpm2cpio && apt autoremove -y && rm -rf /var/lib/apt/lists/*

# RUN echo "Patching NetCore Runtime Settings" && \
#  rm -rf /app/emby/EmbyServer.runtimeconfig.json && \
#  echo "ewogICAgInJ1bnRpbWVPcHRpb25zIjogewogICAgICAgICJjb25maWdQcm9wZXJ0aWVzIjogewogICAgICAgICAgICAiU3lzdGVtLk5ldC5IdHRwLlVzZVNvY2tldHNIdHRwSGFuZGxlciI6IGZhbHNlCiAgICAgICAgfSwKICAgICAgICAidGZtIjogIm5ldGNvcmVhcHAzLjEiLAogICAgICAgICJpbmNsdWRlZEZyYW1ld29ya3MiOiBbCiAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICJuYW1lIjogIk1pY3Jvc29mdC5ORVRDb3JlLkFwcCIsCiAgICAgICAgICAgICAgICAidmVyc2lvbiI6ICIzLjEuMiIKICAgICAgICAgICAgfQogICAgICAgIF0KICAgIH0KfQ==" \
#   | base64 --decode | tee -a /app/emby/EmbyServer.runtimeconfig.json

RUN echo "Sending Boot Commands" && \
 mkdir -p /etc/cont-init.d/ /etc/services.d/emby && \
 echo "IyEvdXNyL2Jpbi93aXRoLWNvbnRlbnYgYmFzaAoKIyBDcmVhdGUgZm9sZGVycwpta2RpciAtcCBcCgkvZGF0YSBcCgkvdHJhbnNjb2RlCgojIHBlcm1pc3Npb25zIChub24tcmVjdXJzaXZlKSBvbiBjb25maWcgcm9vdCBhbmQgZm9sZGVycwpjaG93biBhYmM6YWJjIFwKCS9jb25maWcgXAoJL2RhdGEgXAoJL3RyYW5zY29kZQppZiBbIC1uICIkKGxzIC1BIC9kYXRhIDI+L2Rldi9udWxsKSIgXTsgdGhlbgpjaG93biBhYmM6YWJjIFwKCS9kYXRhLyoKZmk=" \
  | base64 --decode | tee -a /etc/cont-init.d/30-config && \
 echo "IyEvdXNyL2Jpbi93aXRoLWNvbnRlbnYgYmFzaAoKZWNobyAiSGlqYWNraW5nIEhvc3RzIiAmJiBcCiBlY2hvICIqIG9yaWdpbmFsIGhvc3RzIC0+IiAmJiBjYXQgL2V0Yy9ob3N0cyB8fCB0cnVlICYmIFwKIGVjaG8gIjEyNy4wLjAuMSBtYjNhZG1pbi5jb20iID4+IC9ldGMvaG9zdHMgJiYgXAogZWNobyAiOjoxIG1iM2FkbWluLmNvbSIgPj4gL2V0Yy9ob3N0cyAmJiBcCiBlY2hvICIqIG5ldyBob3N0cyBmaWxlIC0+IiAmJiBjYXQgL2V0Yy9ob3N0cyB8fCB0cnVlCgplY2hvICI+Xzwi" \
  | base64 --decode | tee -a /etc/cont-init.d/30-config-hosts && \
echo "IyEvdXNyL2Jpbi93aXRoLWNvbnRlbnYgYmFzaAoKZWNobyAiU2VuZGluZyBDZXJ0aWZpY2F0aW9ucyB0byBTeXN0ZW0iCgpDRVJUPXJvb3QuY3J0CmNwIC9jcmFja3Mvc3NsLyRDRVJUIC91c3Ivc2hhcmUvY2EtY2VydGlmaWNhdGVzLyRDRVJUCmVjaG8gIiskQ0VSVCIgPi9ldGMvY2EtY2VydGlmaWNhdGVzL3VwZGF0ZS5kL2FjdGl2YXRlX215X2NlcnQKCmVjaG8gIiAiID4+IC9hcHAvZW1ieS9ldGMvc3NsL2NlcnRzL2NhLWNlcnRpZmljYXRlcy5jcnQKZWNobyAiU2VsZiBTaWduZWQgUm9vdCBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSIgPj4gL2FwcC9lbWJ5L2V0Yy9zc2wvY2VydHMvY2EtY2VydGlmaWNhdGVzLmNydAplY2hvICI9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09IiA+PiAvYXBwL2VtYnkvZXRjL3NzbC9jZXJ0cy9jYS1jZXJ0aWZpY2F0ZXMuY3J0CmNhdCAvY3JhY2tzL3NzbC9yb290LmNydCB8IHRlZSAtYSAvYXBwL2VtYnkvZXRjL3NzbC9jZXJ0cy9jYS1jZXJ0aWZpY2F0ZXMuY3J0CgpkcGtnLXJlY29uZmlndXJlIGNhLWNlcnRpZmljYXRlcwo=" \
  | base64 --decode | tee -a /etc/cont-init.d/30-update-certificates && \
 echo "IyEvdXNyL2Jpbi93aXRoLWNvbnRlbnYgYmFzaAoKRklMRVM9JChmaW5kIC9kZXYvZHJpIC9kZXYvZHZiIC9kZXYvdmNoaXEgL2Rldi92aWRlbzE/IC10eXBlIGMgLXByaW50IDI+L2Rldi9udWxsKQoKZm9yIGkgaW4gJEZJTEVTCmRvCglWSURFT19HSUQ9JChzdGF0IC1jICclZycgIiRpIikKCWlmICEgaWQgLUcgYWJjIHwgZ3JlcCAtcXcgIiRWSURFT19HSUQiOyB0aGVuCgkJVklERU9fTkFNRT0kKGdldGVudCBncm91cCAiJHtWSURFT19HSUR9IiB8IGF3ayAtRjogJ3twcmludCAkMX0nKQoJCWlmIFsgLXogIiR7VklERU9fTkFNRX0iIF07IHRoZW4KCQkJVklERU9fTkFNRT0idmlkZW8kKGhlYWQgL2Rldi91cmFuZG9tIHwgdHIgLWRjICdhLXpBLVowLTknIHwgaGVhZCAtYzgpIgoJCQlncm91cGFkZCAiJFZJREVPX05BTUUiCgkJCWdyb3VwbW9kIC1nICIkVklERU9fR0lEIiAiJFZJREVPX05BTUUiCgkJZmkKCQl1c2VybW9kIC1hIC1HICIkVklERU9fTkFNRSIgYWJjCglmaQpkb25lCgojIG9wZW5tYXggbGliIGxvYWRpbmcKaWYgWyAtZSAiL29wdC92Yy9saWIiIF0gJiYgWyAhIC1lICIvZXRjL2xkLnNvLmNvbmYuZC8wMC12bWNzLmNvbmYiIF07IHRoZW4KCWVjaG8gIltlbWJ5LWluaXRdIFBpIExpYnMgZGV0ZWN0ZWQgbG9hZGluZyIKCWVjaG8gIi9vcHQvdmMvbGliIiA+ICIvZXRjL2xkLnNvLmNvbmYuZC8wMC12bWNzLmNvbmYiCglsZGNvbmZpZwpmaQ==" \
  | base64 --decode | tee -a /etc/cont-init.d/40-gid-video && \
 echo "IyEvdXNyL2Jpbi93aXRoLWNvbnRlbnYgYmFzaAoKIyBzZXQgdW1hc2sKVU1BU0tfU0VUPSR7VU1BU0tfU0VUOi0wMjJ9CnVtYXNrICIkVU1BU0tfU0VUIgoKIyBlbnYgc2V0dGluZ3MKQVBQX0RJUj0iL2FwcC9lbWJ5IgpleHBvcnQgTERfTElCUkFSWV9QQVRIPSIke0FQUF9ESVJ9IgpleHBvcnQgRk9OVENPTkZJR19QQVRIPSIke0FQUF9ESVJ9Ii9ldGMvZm9udHMKaWYgWyAtZCAiL2xpYi94ODZfNjQtbGludXgtZ251IiBdOyB0aGVuCglleHBvcnQgTElCVkFfRFJJVkVSU19QQVRIPSIke0FQUF9ESVJ9Ii9kcmkKZmkKZXhwb3J0IFNTTF9DRVJUX0ZJTEU9IiR7QVBQX0RJUn0iL2V0Yy9zc2wvY2VydHMvY2EtY2VydGlmaWNhdGVzLmNydAoKZXhlYyBcCglzNi1zZXR1aWRnaWQgYWJjIC9hcHAvZW1ieS9FbWJ5U2VydmVyIFwKCS1wcm9ncmFtZGF0YSAvY29uZmlnIFwKCS1mZmRldGVjdCAvYXBwL2VtYnkvZmZkZXRlY3QgXAoJLWZmbXBlZyAvYXBwL2VtYnkvZmZtcGVnIFwKCS1mZnByb2JlIC9hcHAvZW1ieS9mZnByb2JlIFwKCS1yZXN0YXJ0ZXhpdGNvZGUgMw==" \
  | base64 --decode | tee -a /etc/services.d/emby/run && \
 echo "IyEvdXNyL2Jpbi93aXRoLWNvbnRlbnYgYmFzaAoKbmdpbng=" \
  | base64 --decode | tee -a /etc/cont-init.d/50-nginx-start

EXPOSE 8096 8920
VOLUME /config

# ENV DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=0

# #!/usr/bin/with-contenv bash

# echo "Sending Certifications to System"

# CERT=root.crt
# cp /cracks/ssl/$CERT /usr/share/ca-certificates/$CERT
# echo "+$CERT" >/etc/ca-certificates/update.d/activate_my_cert

# echo " " >> /app/emby/etc/ssl/certs/ca-certificates.crt
# echo "Self Signed Root Certification Authority" >> /app/emby/etc/ssl/certs/ca-certificates.crt
# echo "===========================================" >> /app/emby/etc/ssl/certs/ca-certificates.crt
# cat /cracks/ssl/root.crt | tee -a /app/emby/etc/ssl/certs/ca-certificates.crt

# dpkg-reconfigure ca-certificates
