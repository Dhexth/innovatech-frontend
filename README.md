# Innovatech Chile - Frontend (React + Vite)

Este repositorio contiene la interfaz de usuario para el ecosistema de **Innovatech Chile**, una aplicación de tipo Single Page Application (SPA) desarrollada con React y Vite, diseñada para interactuar de manera eficiente con microservicios en la nube.

## 📋 Características del Proyecto
* **Tecnología Principal:** React (v18+) empaquetado de manera ultra-rápida con Vite.
* **Servidor de Producción:** Servido a través de una imagen ligera de **Nginx** optimizada.
* **Arquitectura Cloud:** Desplegado de forma serverless sobre **Amazon ECS con AWS Fargate** detrás de un Application Load Balancer (ALB).

---

## 🛠️ Requisitos Previos

Para levantar el entorno de desarrollo local o realizar modificaciones, necesitas:
* **Node.js 18+** junto con su gestor de paquetes **npm**.
* **Docker** (Opcional, solo si deseas probar el contenedor de producción localmente).

---

## 🚀 Configuración y Uso Local

### 1. Variables de Entorno (`.env`)
El frontend requiere conocer el punto de enlace de los microservicios del Backend. Crea un archivo llamado `.env` en la raíz de la carpeta del frontend y define la URL del balanceador de carga o de tu API local:

```env
VITE_API_URL=[http://innovatech-alb-ep3-1385272106.us-east-1.elb.amazonaws.com:8081](http://innovatech-alb-ep3-1385272106.us-east-1.elb.amazonaws.com:8081)

💡 Nota: Para desarrollo local estricto puedes cambiar este valor temporalmente por http://localhost:8081. Sin embargo, para el despliegue final en la infraestructura de AWS, debe apuntar obligatoriamente a la URL del Balanceador de Carga (ALB).

2. Comandos del Ciclo de Desarrollo
Ejecuta la secuencia de comandos estándar en tu terminal para iniciar el proyecto:
# 1. Instalar todas las dependencias declaradas en el package.json
npm install

# 2. Levantar el servidor local de desarrollo con soporte de Hot Reload
npm run dev

# 3. Compilar y optimizar los recursos estáticos listos para producción
npm run build

🐳 Dockerización (Entorno de Producción)
La aplicación utiliza una estrategia de Multi-stage Build (construcción en múltiples etapas) para garantizar que la imagen final distribuida sea extremadamente ligera y segura.
# Construir la imagen Docker pasando la URL del balanceador como argumento de compilación
docker build --build-arg VITE_API_URL=http://<ALB-URL>:8081 -t innovatech-frontend:latest .

# Ejecutar el contenedor localmente en el puerto de escucha configurado
docker run -d -p 8080:8080 innovatech-frontend:latest
🛠️ Solución de Problemas Frecuentes
Error de conexión Cliente-API (Localhost/IPs fijas): Se eliminaron todas las referencias a direcciones IP privadas fijas. La aplicación inyecta la URL del balanceador dinámicamente mediante la variable VITE_API_URL. Asegúrate de reconstruir el contenedor si cambias este parámetro.

Fallo de permisos al iniciar Nginx (Puerto 80/8080): Con el fin de no ejecutar el servidor web con privilegios de superusuario (root) dentro del clúster ECS, se integró el uso del comando setcap en el archivo Dockerfile para dar permisos específicos de red al binario de Nginx.

Desarrollado en un entorno DevOps por Ariel Ortiz y Cristofer Lobos (2026).
