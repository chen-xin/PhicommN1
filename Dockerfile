
# docker build . -t chen_x/clash
FROM alpine

ARG CN=0

RUN mkdir -p /clash

ADD ./data/clash/clash-linux /clash
ADD ./data/clash/entrypoint.sh /clash/entrypoint.sh

RUN if [ $CN = 1 ] ; then OS_VER=$(grep main /etc/apk/repositories | sed 's#/#\n#g' | grep "v[0-9]\.[0-9]") \
    && echo "using mirrors for $OS_VER" \
    && echo https://mirrors.ustc.edu.cn/alpine/$OS_VER/main/ > /etc/apk/repositories; fi


RUN apk add --no-cache curl openssl iptables 

# ENTRYPOINT ['/clash/entrypoint.sh']


