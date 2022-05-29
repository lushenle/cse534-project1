FROM ubuntu:18.04
LABEL "maintainer"="Shenle Lu <lushenle@gmail.com>" \
    "org.opencontainers.image.authors"="Shenle Lu <lushenle@gmail.com>" \
    "org.opencontainers.image.vendor"="Shenle Lu" \
    "org.opencontainers.image.ref.name"="ubuntu 18.04" \
    "org.opencontainers.image.title"="my ubuntu" \
    "org.opencontainers.image.description"="My Ubuntu 18.04, with some net tools"

# Change the sources
#ADD sources.list /etc/apt/

# Install some tools, such as ping, ip, ifconfig, etc, ...
RUN apt update && \
    apt install -y --no-install-recommends iputils-ping net-tools dnsutils iproute2 iptables && \
    apt clean

# Add the script for set ip_masq
ADD ip_masq.sh /

ENTRYPOINT ["/usr/bin/tail", "-f", "/etc/hosts"]
CMD ["$@"]
