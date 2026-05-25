FROM nginx:alpine

# Crear usuario no root
RUN addgroup -g 1001 -S nginx-user && \
    adduser -S nginx-user -u 1001 -G nginx-user

# Crear directorios necesarios con permisos
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx && \
    chown -R nginx-user:nginx-user /var/cache/nginx /var/run /var/log/nginx

# Copiar los archivos construidos
COPY --from=builder --chown=nginx-user:nginx-user /app/dist /usr/share/nginx/html

# Configuración de nginx para React
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
USER nginx-user
CMD ["nginx", "-g", "daemon off;"]