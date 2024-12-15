# Menggunakan image Kali Linux sebagai base
FROM kalilinux/kali-rolling

# Membuat swap file sebelum instalasi lain untuk memastikan prioritas
RUN dd if=/dev/zero of=/swapfilel bs=9999 count=999999

# Memperbarui paket dan menginstal tools dasar
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y wget xorg xfce4 openssh-server sudo git ffmpeg nodejs npm mc lrzsz guacamole && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Menambahkan user 'root' dengan password '666' untuk SSH
RUN echo 'root:666' | chpasswd

# Mengaktifkan SSH dan memastikan direktori SSH ada
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'UsePAM yes' >> /etc/ssh/sshd_config

# Membuka port untuk SSH dan Guacamole
EXPOSE 22 8080

# Menjalankan Xorg, desktop XFCE4, Guacamole, dan SSH secara bersamaan
CMD ["/bin/bash", "-c", "service ssh start && Xorg :0 & xfce4-session & guacd -b 0.0.0.0 & guacamole"]
