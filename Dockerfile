# Parkir App - Node 20, multi-stage build
# Citra node:tag resmi mendukung multi-arsitektur (arm64/ARMv8 untuk Armbian)
# sehingga image yang di-build di x86_64 tetap bisa di-pull/used lintas arsitektur
# via buildx atau build langsung di Armbian.
FROM node:20-alpine AS build

WORKDIR /app

# Install dependensi dulu (manfaatkan layer cache)
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Salin source code
COPY app.js ./
COPY config ./config
COPY views ./views

# Mode produksi, jalankan tanpa root
ENV NODE_ENV=production
USER node

EXPOSE 3000

CMD ["node", "app.js"]
