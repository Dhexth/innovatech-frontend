# Innovatech Frontend — ISY1101 EP2

## Descripción

Frontend de Innovatech Chile desarrollado en React, contenedorizado con Docker (multi-stage build) y desplegado automáticamente en AWS EC2 mediante un pipeline CI/CD con GitHub Actions.

| Componente | Detalle |
|---|---|
| Framework | React + Vite |
| Servidor | nginx:alpine |
| Puerto | 80 (host) → 8080 (contenedor) |
| IP Pública | 52.205.229.175 |

---

## Estructura del Repositorio

```
innovatech-frontend/
├── Dockerfile              # Multi-stage build (Node builder + nginx)
├── docker-compose.yml      # Stack del frontend
├── .github/
│   └── workflows/
│       └── deploy.yml      # Pipeline CI/CD
├── src/
│   ├── components/
│   │   ├── TableDespacho.jsx
│   │   ├── TableCompras.jsx
│   │   ├── FormDespacho.jsx
│   │   └── FormCierreDespacho.jsx
│   └── ...
├── public/
└── package.json
```

---

## Dockerfile — Multi-Stage Build

El Dockerfile utiliza 2 etapas:

1. **Builder** (`node:18-alpine`) — Instala dependencias y compila la app con `npm run build`
2. **Producción** (`nginx:alpine`) — Sirve los archivos estáticos compilados

Buenas prácticas aplicadas:
- Usuario no root (`nginx-user`, UID 1001)
- Puerto no privilegiado: 8080
- Imagen final sin dependencias de desarrollo
- Configuración nginx personalizada para SPA (React Router)

---

## docker-compose.yml

```yaml
services:
  frontend:
    image: <ECR_REGISTRY>:<IMAGE_TAG>
    container_name: innovatech-frontend
    restart: unless-stopped
    ports:
      - "80:8080"
```

---

## Pipeline CI/CD — GitHub Actions

El pipeline se activa con un `push` a la rama `deploy` y ejecuta:

1. **Checkout** del código
2. **Configure AWS credentials** (usando GitHub Secrets)
3. **Login a Amazon ECR**
4. **Build y Push** de la imagen Docker
5. **Deploy** en la instancia EC2 frontend vía SSH

### GitHub Secrets requeridos

| Secret | Descripción |
|---|---|
| AWS_ACCESS_KEY_ID | Credencial AWS Academy |
| AWS_SECRET_ACCESS_KEY | Credencial AWS Academy |
| AWS_SESSION_TOKEN | Token de sesión AWS Academy |
| AWS_REGION | Región (us-east-1) |
| ECR_REGISTRY | URL del repositorio ECR |
| EC2_HOST | IP elástica de la EC2 frontend |
| EC2_USER | Usuario SSH (ubuntu) |
| EC2_SSH_KEY | Clave privada PEM |

---

## Despliegue Manual en EC2

```bash
# Conectarse a la EC2 frontend
sudo su - ubuntu

# Login a ECR
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <ECR_REGISTRY>

# Detener contenedor anterior
docker stop innovatech-frontend || true
docker rm innovatech-frontend || true

# Levantar nuevo contenedor
docker run -d \
  --name innovatech-frontend \
  --restart unless-stopped \
  -p 80:8080 \
  <ECR_REGISTRY>:<IMAGE_TAG>
```

---

## Configuración Backend

El frontend se comunica con el backend en la subred privada de AWS:

| Microservicio | URL |
|---|---|
| Despachos | http://10.0.2.123:8080/api/v1/despachos |
| Ventas | http://10.0.2.123:8081/api/v1/ventas |

La comunicación respeta las políticas de los Security Groups: el backend solo acepta tráfico proveniente del Security Group del frontend.

---

## Acceso

El frontend es el **único componente accesible desde Internet**:

```
http://52.205.229.175 (La ip publica cambia cada vez que se ingresa al laboratorio)
```

---

## Integrantes

- Ariel Ortiz
- Cristofer Lobos

**Asignatura:** ISY1101-004V — Introducción a Herramientas DevOps  
**Profesor:** Álvaro Mellado  
**Evaluación:** Parcial N°2 — 2025
