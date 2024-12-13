# Menggunakan image Kali Linux
FROM kalilinux/kali-rolling

# Memperbarui paket dan menginstal wget
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install wget xorg xfce4 novnc

# Membuat pengguna baru dengan kredensial yang telah ditentukan
RUN useradd -m -s /bin/bash -p $(echo "666" | openssl passwd -1) 666

# Menginstal package untuk upload dan download file
RUN apt-get -y install lrzsz

# Membuka port
EXPOSE 6080

# Menjalankan perintah untuk memulai desktop
CMD ["/bin/bash", "-c", "Xorg :0 & xfce4-session & /usr/lib/novnc/novnc --listen 6080 --vnc localhost:5900"]
