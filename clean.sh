install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update -y
apt install -y debfoster tmux htop ca-certificates curl vim
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

apt autoremove -y --purge 
apt clean -y


apt-mark manual \
    openssh-server \
    openssh-client \
    iproute2 \
    iputils-ping \
    netplan.io \
    systemd \
    systemd-sysv \
    systemd-resolved \
    systemd-timesyncd \
    dbus \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    docker-ce-rootless-extras \
    python3 \
    cron \
    rsyslog


    
while true; do
    REMOVED=0

    snap list | awk 'NR>1 {print $1}' | while read -r SNAP; do
        snap remove --purge "$SNAP" && REMOVED=1
    done

    # Stop if no snaps remain
    [ -z "$(snap list | awk 'NR>1')" ] && break

    sleep 1
done


apt purge -y snapd
rm -rf /snap
rm -rf /var/snap
rm -rf ~/snap
rm -rf /var/lib/snapd

install -Dm644 debfoster.conf /etc/debfoster.conf
install -Dm644 keepers /var/lib/debfoster/keepers

debfoster --force

apt-get autoremove --purge -y
apt-get clean

reboot