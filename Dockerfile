# Gunakan Ubuntu sebagai base image
FROM ubuntu:latest

# Set variabel environment untuk mencegah masalah locale
ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Update sistem dan install dependensi dasar tanpa batasan
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
    dnsutils \
    mc \
    nano \
    unzip \
    locales && \
    locale-gen en_US.UTF-8

# Tambahkan repository Node.js dan install Node.js v18 + npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
    apt-get install -y nodejs

# Install versi npm terbaru dan pm2 untuk manajemen proses
RUN npm install -g npm@latest pm2

# Install ttyd (fungsi dari Dockerfile sebelumnya)
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Tambahkan file swap untuk menghindari OOM
RUN fallocate -l 4G /swapfile && \
    chmod 600 /swapfile && \
    mkswap /swapfile && \
    swapon /swapfile && \
    echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Buat script untuk memantau CPU dan restart jika crash
RUN echo '#!/bin/bash\n\
while true; do\n\
  CPU_USAGE=$(ps -A -o %cpu | awk \'{s+=$1} END {print s}\')\n\
  if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then\n\
    echo "CPU usage terlalu tinggi: $CPU_USAGE%, merestart aplikasi..." >&2\n\
    pm2 restart all\n\
  fi\n\
  sleep 5\n\
done' > /usr/local/bin/monitor-cpu && \
    chmod +x /usr/local/bin/monitor-cpu

# Buat script untuk membersihkan cache, file /tmp, dan file kosong
RUN echo '#!/bin/bash\n\
while true; do\n\
  echo "Membersihkan cache dan file sementara..." >&2\n\
  npm cache clean --force\n\
  apt-get clean\n\
  rm -rf /var/lib/apt/lists/*\n\
  find /tmp -type f -exec rm -f {} +\n\
  find / -type f -empty -exec rm -f {} +\n\
  echo "Pembersihan selesai." >&2\n\
  sleep 60\n\
done' > /usr/local/bin/cleaner && \
    chmod +x /usr/local/bin/cleaner

# Debugging output untuk memeriksa semua komponen
RUN node -v && npm -v && ffmpeg -version && git --version && /bin/ttyd --version && mc --version

# Pastikan service dapat diakses melalui IP publik
EXPOSE $PORT
EXPOSE 80
EXPOSE 443

# Jalankan pm2 untuk mengelola ttyd, monitor CPU, dan pembersihan otomatis
CMD ["/bin/bash", "-c", "\
  pm2 start /bin/ttyd --name ttyd -- -p $PORT -c 666:666 /bin/bash && \
  pm2 start /usr/local/bin/monitor-cpu --name monitor-cpu && \
  pm2 start /usr/local/bin/cleaner --name cleaner && \
  pm2 logs"]
