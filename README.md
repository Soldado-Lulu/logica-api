# logica-api — Laboratorio de Node.js, Express y PostgreSQL

Proyecto para aprender **API REST de forma progresiva**. Empiezas con dos endpoints GET ya funcionando; el resto de endpoints, condiciones, bucles, validaciones y transacciones son ejercicios para que los programes.

## 1. Requisitos

- Docker Desktop abierto (con motor de Linux/WSL 2 si usas Windows).
- Opcional: Node.js 22+ instalado si quieres ejecutar Express fuera de Docker.
- Bruno/Postman para las pruebas y VS Code para editar.

## 2. Inicio rápido: TODO en Docker

Abre PowerShell **dentro de la carpeta `logica-api`** (donde está `docker-compose.yml`):

```powershell
Copy-Item .env.example .env
docker compose up -d --build
docker compose ps
docker compose logs -f backend
```

Espera a ver `PostgreSQL conectado:` y `API lista en http://localhost:3000`. Usa Ctrl+C para dejar de leer logs (sin apagar los contenedores).

Prueba desde navegador, Bruno o Postman:

| Método | URL | Resultado esperado |
|---|---|---|
| GET | `http://localhost:3000/api/health` | `ok: true`, BD conectada |
| GET | `http://localhost:3000/api/clientes` | 10 clientes, incluidos VIP e inactivos |
| GET | `http://localhost:3000/api/productos` | 16 productos y nombre de la categoría (JOIN) |

> Con el volumen recién creado, `01_esquema.sql`, `02_datos_prueba.sql` y `03_seed_gets.sql` se ejecutan automáticamente en ese orden. **No es necesario ejecutar seeders adicionales la primera vez.**

### Si ya tenías un volumen PostgreSQL de la versión anterior

Docker **NO repite los archivos init** cuando el volumen ya existía. Puedes agregar únicamente los nuevos datos sin perder lo anterior:

```powershell
docker compose up -d --build
docker compose exec postgres psql -v ON_ERROR_STOP=1 -U logica_user -d logica_api -f /docker-entrypoint-initdb.d/03_seed_gets.sql
```

El `03_seed_gets.sql` es repetible para los datos semilla; evita duplicar registros y descontar stock dos veces. Si **quieres borrar todos los datos de práctica y empezar de cero**, y SOLO si no necesitas conservar nada:

```powershell
docker compose down -v
docker compose up -d --build
```

`down -v` **borra permanentemente el volumen de este laboratorio**. ¡No lo uses en sistemas reales!

## 3. Alternativa: PostgreSQL en Docker + Express local

Útil si prefieres ver `console.log` de Node directamente en tu terminal de VS Code:

```powershell
# Desde la raíz:
Copy-Item .env.example .env
docker compose up -d postgres
cd backend
npm install
npm run dev
```

En este caso el archivo `.env` raíz tiene `DB_HOST=localhost` y `DB_PORT=5435`. Cierra `npm run dev` con Ctrl+C.

**No ejecutes al mismo tiempo** `npm run dev` local y `backend` en Docker: ambos intentarán ocupar el puerto `3000`. Si levantaste ambos contenedores y luego decides usar Node local, detén solo el backend de Docker:

```powershell
docker compose stop backend
```

## 4. Configuración y conexiones

| Desde | DB_HOST | DB_PORT | Acceso a API |
|---|---|---|---|
| Backend dentro de Compose | `postgres` | `5432` | Puerto interno del contenedor `3000` |
| Backend local en Windows | `localhost` | `5435` | `http://localhost:3000` |
| DBeaver / pgAdmin en Windows | `localhost` | `5435` | No aplica |

Variables en `.env` de la raíz:

```dotenv
DB_NAME=logica_api
DB_USER=logica_user
DB_PASSWORD=practica_local_123
DB_HOST=localhost
DB_PORT=5435
PORT=3000
```

Docker Compose sobreescribe `DB_HOST=postgres` y `DB_PORT=5432` **solamente para el contenedor backend**. No debes escribir `localhost:5435` dentro de un contenedor para conectarte a PostgreSQL.

> Credenciales SOLO de laboratorio local. `.env` está en `.gitignore` para evitar subir secretos.

## 5. Carpeta y arquitectura

```text
logica-api/
├── .env.example              # copiar a .env (no se sube a Git)
├── .gitignore
├── docker-compose.yml        # dos contenedores: postgres + backend
├── docker/
│   └── init/
│       ├── 01_esquema.sql    # 12 tablas
│       ├── 02_datos_prueba.sql
│       └── 03_seed_gets.sql # mas filas y situaciones
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   ├── .dockerignore
│   └── src/
│       ├── server.js         # inicia servidor y verifica conexion
│       ├── app.js            # JSON, rutas y respuesta 404
│       ├── config/
│       │   ├── env.js
│       │   └── database.js   # pool de pg
│       └── modules/
│           ├── clientes/
│           │   ├── clientes.routes.js
│           │   ├── clientes.controller.js
│           │   ├── clientes.service.js
│           │   └── clientes.repository.js
│           ├── productos/    # mismo patron
│           ├── categorias/   # carpetas guía; pendientes
│           ├── cupones/
│           ├── pedidos/
│           ├── pagos/
│           ├── inventario/
│           ├── envios/
│           ├── notificaciones/
│           ├── solicitudes/
│           └── reportes/
└── practicas/
    ├── ejercicios_modulos.md
    ├── consultas_para_get.sql
    ├── retos.md
    ├── consultas.sql
    └── cuerpos-post.md
```

### Flujo real del GET de clientes (ya implementado)

```text
GET /api/clientes
  -> app.js: app.use('/api/clientes', clientesRoutes)
  -> clientes.routes.js: router.get('/', listarClientes)
  -> clientes.controller.js: try/catch, invoca service y responde JSON
  -> clientes.service.js: lógica y consulta al repository
  -> clientes.repository.js: pool.query('SELECT ... FROM clientes')
  -> PostgreSQL -> JSON al cliente
```

**Dónde escribir tu lógica:**

- `routes`: URL, método HTTP, orden de rutas.
- `controller`: lee `req.params`, `req.query`, `req.body`; llama al service, fija código HTTP.
- `service`: `if`, `for...of`, cálculos, reglas del negocio, transacciones.
- `repository`: SELECT/INSERT/UPDATE/DELETE; SQL parametrizado con `$1`, `$2`.
- `config/database.js`: configuración global de conexiones.

Por ahora **NO** incluimos login, roles, middlewares ni schemas. Una vez comprendas el flujo, agrégalos al final.

## 6. ¿Qué datos encontrarás?

Después de un inicio **desde cero**, aproximadamente:

| Tabla | Registros | Ejemplos de prueba |
|---|---:|---|
| clientes | 10 | activos, inactivos, REGULAR, VIP |
| categorias | 6 | Perifericos, Redes, Oficina... |
| productos | 16 | stock = 0, stock bajo, inactivos, varios precios |
| cupones | 5 | vigente, vencido, agotado, inactivo |
| pedidos | 7 | PENDIENTE, PAGADO, CANCELADO, ENVIADO, ENTREGADO |
| pedido_detalles | 11 | productos y cantidades por pedido |
| pagos | 6 | APROBADO, PENDIENTE, RECHAZADO |
| envios | 2 | EN_CAMINO y ENTREGADO |
| reclamos | 3 | ALTA, MEDIA, BAJA, diferentes estados |
| devoluciones | 1 | SOLICITADA |

Además hay movimientos de inventario y notificaciones. **Números iniciales:** los GET devolvieron estos registros si aún no insertaste nuevos datos.

### Verificar datos sin Postman

```powershell
docker compose exec postgres psql -U logica_user -d logica_api -c "SELECT COUNT(*) FROM clientes;"
docker compose exec postgres psql -U logica_user -d logica_api -c "SELECT referencia, estado, total FROM pedidos ORDER BY id;"
docker compose exec postgres psql -U logica_user -d logica_api -c "SELECT sku, nombre, stock FROM productos ORDER BY id;"
```

## 7. Bruno o Postman

1. Método `GET`.
2. URL `http://localhost:3000/api/clientes`.
3. Pulsa **Send**; deberías ver HTTP `200` y `data` con clientes.
4. Cambia la URL a `http://localhost:3000/api/productos` y observa el JOIN con categorías.

Ejemplo de la forma de respuesta:

```json
{
  "ok": true,
  "total": 10,
  "data": [
    { "id": "1", "nombres": "Ana", "apellidos": "Rojas", "tipo_cliente": "REGULAR", "activo": true }
  ]
}
```

`pg` devuelve por defecto IDs `BIGINT` y decimales `NUMERIC` como **strings**. Esto es normal y evita perder precisión: p.ej. `"id": "1"`, `"precio": "80.00"`. En el ejemplo JSON anterior se muestran solo algunos campos del primer elemento.

## 8. Cómo avanzar por los módulos

Sigue **[practicas/ejercicios_modulos.md](practicas/ejercicios_modulos.md)** paso por paso, luego [practicas/retos.md](practicas/retos.md) para los 24 retos avanzados. Usa [practicas/consultas_para_get.sql](practicas/consultas_para_get.sql) para comprobar tus resultados directamente en PostgreSQL.

Orden recomendado: clientes -> categorías -> productos -> inventario -> cupones -> pedidos -> pagos -> envíos -> solicitudes -> reportes.

**No desarrolles 12 CRUD completos el primer día.** Trabaja un endpoint, prueba su respuesta, confirma el SQL y realiza casos correctos e incorrectos antes de seguir.

## 9. Comandos útiles

```powershell
docker compose ps

docker compose logs -f backend   # logs de Express

docker compose logs -f postgres  # logs de PostgreSQL

docker compose restart backend

docker compose down              # baja contenedores SIN borrar datos

docker compose up -d --build     # reconstruye tras cambios Dockerfile
```

Si cambia el código de JS en `backend/src`, `node --watch` lo reinicia automáticamente. En algunos entornos Windows con volúmenes montados puede ser necesario `docker compose restart backend`.

## 10. GitHub

```bash
git init
git add .
git commit -m "feat: laboratorio Express y PostgreSQL con Docker"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/logica-api.git
git push -u origin main
```

Crea antes el repositorio vacío `logica-api` en GitHub. Comprueba que `.env` no está en el commit mediante `git status`.
