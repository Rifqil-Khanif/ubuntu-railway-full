# Menggunakan image Kali Linux
FROM kalilinux/kali-rolling

# Memperbarui paket dan menginstal wget
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install wget xorg xfce4

# Mengunduh dan menginstal ttyd
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Membuka port
EXPOSE $PORT

# Menyimpan kredensial
RUN echo $CREDENTIAL > /tmp/debug

# Menjalankan perintah untuk memulai desktop
CMD ["/bin/bash", "-c", "Xorg :0 & xfce4-session & /bin/ttyd -p $PORT -c $USERNAME:$PASSWORD /bin/bash"]
