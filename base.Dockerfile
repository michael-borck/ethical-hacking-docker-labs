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

# Penetration-testing-workstation feel: a welcome banner + a generic `labhelp`
# command on every INTERACTIVE shell (Kali's own ~/.bashrc already supplies the
# iconic themed prompt, which we keep). Installed for both shell types —
# /etc/profile.d for ssh login shells, /etc/bash.bashrc for the docker-exec
# attacker shell. The snippet is $--guarded so a non-interactive `bash -c` or
# `ssh host cmd` (week 9 tunnels) stays clean, no banner spam.
# exFAT gives copied files mode 0700, so set 644/755 explicitly.
COPY base/motd /etc/motd-eh
COPY base/labhelp /usr/local/bin/labhelp
COPY base/lab-bashrc /etc/profile.d/00-eh-workstation.sh
RUN chmod 644 /etc/motd-eh /etc/profile.d/00-eh-workstation.sh \
    && chmod 755 /usr/local/bin/labhelp \
    && cat /etc/profile.d/00-eh-workstation.sh >> /etc/bash.bashrc

USER hacker
WORKDIR /home/hacker
CMD ["/bin/bash"]