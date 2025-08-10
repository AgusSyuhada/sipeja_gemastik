# Gunakan image Node.js
FROM node:18

# Set workdir
WORKDIR /app

# Copy file package.json dan install depedency
COPY package*.json ./
RUN npm install

# Copy semua file
COPY . .

# Jalankan Prisma generate (jika pakai Prisma)
RUN npx prisma generate

# Expose port (ubah sesuai port app-mu)
EXPOSE 3000

# Jalankan aplikasi
CMD ["node", "src/server.js"]
