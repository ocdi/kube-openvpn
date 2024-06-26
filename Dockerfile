# Smallest base image
FROM alpine:3.19

RUN cat /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main/" >> /etc/apk/repositories && \
    apk add --update openvpn=2.6.10-r0 bash easy-rsa libintl inotify-tools openvpn-auth-pam=2.6.10-r0 google-authenticator iptables && \
    apk add --virtual temppkg gettext &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    apk del temppkg && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV OVPN_TEMPLATE $OPENVPN/templates/openvpn.tmpl
ENV OVPN_CONFIG $OPENVPN/openvpn.conf

ENV OVPN_PORTMAPPING $OPENVPN/portmapping
ENV OVPN_CRL $OPENVPN/crl/crl.pem
ENV OVPN_CCD $OPENVPN/ccd
ENV OVPN_DEFROUTE 0

ENV OVPN_CIPHER "AES-256-CBC"
ENV OVPN_TLS_CIPHER "TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-RSA-WITH-AES-256-GCM-SHA384"

ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki

# Some PKI scripts.
ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Initialisation scripts and default template
COPY *.sh /sbin/
COPY openvpn.tmpl $OVPN_TEMPLATE

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/

CMD ["/sbin/entrypoint.sh"]
