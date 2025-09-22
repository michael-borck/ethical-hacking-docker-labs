FROM kalilinux/kali-rolling

# Install common security tools for all labs
RUN apt-get update && \
    apt-get install -y \
        nmap \
        hydra \
        medusa \
        john \
        hashcat \
        wireshark \
        netcat-traditional \
        telnet \
        openssh-client \
        curl \
        wget \
        git \
        python3 \
        python3-pip \
        gobuster \
        nikto \
        sqlmap \
        dirb \
        wordlists \
        && rm -rf /var/lib/apt/lists/* \
        && gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true

# Create hacker user
RUN useradd -m -s /bin/bash hacker && \
    echo 'hacker:hacker' | chpasswd && \
    usermod -aG sudo hacker

USER hacker
WORKDIR /home/hacker
CMD ["/bin/bash"]