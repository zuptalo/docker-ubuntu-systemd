FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install systemd and other essential packages that match a minimal Ubuntu Server
RUN apt-get update && \
    apt-get install -y \
    # Core system
    systemd \
    systemd-sysv \
    systemd-cron \
    dbus \
    # SSH and networking
    openssh-server \
    net-tools \
    iproute2 \
    iputils-ping \
    netcat-openbsd \
    # Security and permissions
    sudo \
    acl \
    # Logging
    rsyslog \
    logrotate \
    # Locales and time
    locales \
    language-pack-en \
    tzdata \
    # Package management
    apt-utils \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release \
    # Python for Ansible
    python3 \
    python3-pip \
    python3-apt \
    # Common utilities
    curl \
    wget \
    git \
    vim \
    nano \
    less \
    file \
    tar \
    gzip \
    bzip2 \
    xz-utils \
    unzip \
    # Documentation
    man-db \
    manpages \
    # Process management
    psmisc \
    procps \
    # Disk utilities
    fdisk \
    parted \
    # Text processing
    grep \
    sed \
    gawk \
    # Other utilities commonly expected
    bc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Configure systemd
# Mask systemd services that don't work well in containers
RUN systemctl mask \
    systemd-udevd.service \
    systemd-udevd-kernel.socket \
    systemd-udevd-control.socket \
    systemd-modules-load.service \
    sys-kernel-config.mount \
    sys-kernel-debug.mount \
    sys-kernel-tracing.mount

# Configure SSH
RUN mkdir -p /var/run/sshd && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

# Configure the existing ubuntu user (already present in Ubuntu 24.04)
RUN usermod -aG sudo ubuntu && \
    echo 'ubuntu:ubuntu' | chpasswd && \
    echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Allow root login and password authentication for testing
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'root:root' | chpasswd

# Enable SSH service
RUN systemctl enable ssh

# Enable systemd-cron (timer-based cron replacement)
RUN systemctl enable cron.target

# Enable rsyslog service
RUN systemctl enable rsyslog

# Expose SSH port
EXPOSE 22

# Set stop signal for systemd
STOPSIGNAL SIGRTMIN+3

# Start systemd as PID 1
CMD ["/sbin/init"]
