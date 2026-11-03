# Mimi — Local Development

Guía rápida para levantar el backend y la aplicación Flutter de Mimi en desarrollo local.

## 1. Backend

Abrir una terminal desde la raíz del proyecto:

```bash
cd backend
source .venv/bin/activate
```

Verificar que PostgreSQL esté disponible:

```bash
pg_isready -h localhost -p 5432
```

Debería responder:

```text
localhost:5432 - accepting connections
```

### Variables de entorno

El archivo:

```text
backend/.env
```

debe contener la configuración local requerida por Mimi.

Entre las variables necesarias está:

```text
MIMI_DEMO_CUSTOMER_ID=0e275bc8-90cc-5472-a99f-ad4a4bdb416f
```

También deben estar configuradas las variables existentes para:

- PostgreSQL
- modelo LLM
- API key del proveedor LLM
- timezone

No commitear `.env`.

### Migraciones

Normalmente no es necesario ejecutar esto cada vez que se inicia el backend.

Para verificar el estado:

```bash
alembic current
```

Para actualizar la base si existen nuevas migraciones:

```bash
alembic upgrade head
```

### Seed

La base necesita el dataset demo de Mimi.

Solo ejecutar cuando sea necesario crear o restaurar los datos:

```bash
python -m mimi.infrastructure.database.seed
```

Para reconstruir completamente el dataset demo:

```bash
python -m mimi.infrastructure.database.seed --reset
```

No usar `--reset` como parte del inicio normal porque reemplaza los datos demo existentes.

### Levantar FastAPI

```bash
uvicorn mimi.main:app --reload
```

Backend local:

```text
http://localhost:8000
```

Health check:

```bash
curl -s http://localhost:8000/health
```

Respuesta esperada:

```json
{"status":"ok"}
```

Mantener esta terminal abierta mientras se utiliza la aplicación.

---

## 2. Flutter

Abrir una segunda terminal desde la raíz del proyecto:

```bash
cd mobile
```

Levantar Flutter usando la configuración de development:

```bash
flutter run --dart-define-from-file=config/development.json
```

La configuración de development utiliza:

```text
API_BASE_URL=http://localhost:8000
```

En iOS Simulator, Mimi puede comunicarse con el FastAPI ejecutándose localmente en la Mac mediante esta dirección.

---

## 3. Flujo normal de desarrollo

Terminal 1:

```bash
cd backend
source .venv/bin/activate
uvicorn mimi.main:app --reload
```

Terminal 2:

```bash
cd mobile
flutter run --dart-define-from-file=config/development.json
```

Luego:

```text
Flutter
   ↓
http://localhost:8000
   ↓
FastAPI
   ↓
Mimi Chat
   ↓
PostgreSQL / Banking capabilities
```

---

## 4. Verificación rápida de Mimi

Con backend y Flutter ejecutándose:

1. Abrir la aplicación.
2. Tocar `✦ Mimi`.
3. La conversación debe iniciar sin mostrar un error de conexión.
4. Probar:

```text
¿Cuál es mi saldo?
```

5. Probar contexto conversacional:

```text
¿Cuánto gasté este mes?
```

seguido por:

```text
¿Y el mes anterior?
```

Mimi debe mantener el contexto de la conversación y consultar los datos del backend.

---

## 5. Tests del Mobile

Desde `mobile`:

```bash
flutter analyze
flutter test
```

Ambos deben finalizar correctamente antes de cerrar un ticket que afecte al Mobile.

---

## Troubleshooting

### “No pudimos iniciar la conversación”

Primero comprobar que FastAPI esté ejecutándose:

```bash
curl -s http://localhost:8000/health
```

Si no responde, revisar la terminal del backend.

También verificar que `backend/.env` tenga:

```text
MIMI_DEMO_CUSTOMER_ID=0e275bc8-90cc-5472-a99f-ad4a4bdb416f
```

### Flutter abre pero no llega al backend

Confirmar que Flutter fue iniciado con:

```bash
flutter run --dart-define-from-file=config/development.json
```

y que FastAPI está escuchando en:

```text
localhost:8000
```

### Mimi abre pero falla al interpretar mensajes

Si `/conversations` funciona pero `/chat` falla, revisar la terminal de FastAPI.

Las consultas en lenguaje natural utilizan el proveedor LLM, por lo que deben estar correctamente configurados el modelo y la API key en `backend/.env`.

### Restaurar los datos demo

Solo si es necesario volver al estado inicial:

```bash
cd backend
source .venv/bin/activate
python -m mimi.infrastructure.database.seed --reset
```

Después reiniciar FastAPI.