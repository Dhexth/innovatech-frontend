FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
COPY package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine

# Crear usuario no root
RUN addgroup -g 1001 -S nginx-user && \
    adduser -S nginx-user -u 1001 -G nginx-user

# Crear directorios necesarios con permisos
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx && \
    chown -R nginx-user:nginx-user /var/cache/nginx /var/run /var/log/nginx

# Copiar archivos construidos
COPY --from=builder --chown=nginx-user:nginx-user /app/dist /usr/share/nginx/html

# Configuración de nginx
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Exponer puerto
EXPOSE 80

# Cambiar a usuario no root
USER nginx-user

# Iniciar nginx (con PID en directorio con permisos)
CMD ["nginx", "-g", "daemon off;", "-p", "/var/run"]