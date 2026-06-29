FROM node:18-alpine AS builder

# Directorio de trabajo
WORKDIR /app

# Copiar package files
COPY package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar proyecto
COPY . .

# Build producción (Vite genera dist)
RUN npm run build

# Imagen final con nginx
FROM nginx:alpine

# Crear usuario no root
RUN addgroup -g 1001 -S nginx-user && \
    adduser -S nginx-user -u 1001 -G nginx-user

# Crear directorios necesarios y permisos
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx-user:nginx-user \
    /var/cache/nginx \
    /var/run \
    /var/log/nginx \
    /usr/share/nginx/html \
    /var/run/nginx.pid

# Eliminar configuración default
RUN rm -f /etc/nginx/conf.d/default.conf

# Copiar frontend compilado - ¡CAMBIO IMPORTANTE!
COPY --from=builder --chown=nginx-user:nginx-user /app/dist /usr/share/nginx/html

# Crear configuración nginx
RUN echo 'server { \
    listen 8080; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html index.htm; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Exponer puerto no privilegiado
EXPOSE 8080

# Ejecutar como usuario no root
USER nginx-user

# Iniciar nginx
CMD ["nginx", "-g", "daemon off;"]