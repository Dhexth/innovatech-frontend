FROM node:18-alpine AS builder

# Recibir el argumento de la URL de la API
ARG REACT_APP_API_URL

# Establecer la variable de entorno para el build
ENV REACT_APP_API_URL=$REACT_APP_API_URL

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

# Crear directorios necesarios y otorgar permisos al usuario no root
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx-user:nginx-user \
    /var/cache/nginx \
    /var/run \
    /var/log/nginx \
    /usr/share/nginx/html \
    /var/run/nginx.pid

# Eliminar configuración por defecto de nginx
RUN rm -f /etc/nginx/conf.d/default.conf

# Copiar frontend compilado desde la etapa anterior con los permisos adecuados
COPY --from=builder --chown=nginx-user:nginx-user /app/dist /usr/share/nginx/html

# Crear configuración de Nginx para escuchar en el puerto seguro 8080
RUN echo 'server { \
    listen 8080; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html index.htm; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Exponer el puerto 8080
EXPOSE 8080

# Cambiar al usuario no root antes de ejecutar la aplicación
USER nginx-user

# Iniciar Nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]