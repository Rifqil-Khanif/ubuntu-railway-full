# Gunakan Ubuntu sebagai base image
FROM ubuntu:latest

# Update sistem dan install dependensi dasar
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    wget \
    git \
    sudo \
    curl \
    gnupg \
    build-essential \
    ffmpeg \
    net-tools \
    iproute2 \
    iputils-ping \
    dnsutils

# Tambahkan repository Node.js dan install Node.js v18 + npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
    apt-get install -y nodejs

# Install versi npm terbaru
RUN npm install -g npm@latest

# Install ttyd (fungsi dari Dockerfile sebelumnya)
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Debugging output untuk memeriksa semua komponen
RUN node -v && npm -v && ffmpeg -version && git --version && /bin/ttyd --version

# Debugging tambahan: echo untuk variabel environment
RUN echo $CREDENTIAL > /tmp/debug

# Pastikan service dapat diakses melalui IP publik
EXPOSE $PORT
EXPOSE 80
EXPOSE 443

# Jalankan ttyd dengan autentikasi
CMD ["/bin/bash", "-c", "/bin/ttyd -p $PORT -c $USERNAME:$PASSWORD /bin/bash"]
