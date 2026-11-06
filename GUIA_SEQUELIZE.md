# Práctica: Express + Sequelize + PostgreSQL

Tu proyecto fue adaptado manteniendo `routes → controller → service → repository → model`.

## Iniciar

Desde la raíz del ZIP:

```bash
docker compose up -d --build
docker compose logs -f backend
```

Se conserva `docker/init/*.sql` y los seeders. Si ya usabas el volumen `postgres_data`, los datos existentes no se borran.

## Endpoints disponibles

- `GET http://localhost:3000/api/health`
- `GET http://localhost:3000/api/clientes`
- `GET http://localhost:3000/api/clientes/1`
- `POST http://localhost:3000/api/clientes`
- `PATCH http://localhost:3000/api/clientes/1`
- `DELETE http://localhost:3000/api/clientes/1`
- `GET http://localhost:3000/api/productos`

POST JSON:

```json
{"nombres":"Ana","apellidos":"Flores","correo":"ana.prueba@example.com","celular":"70000000","tipo_cliente":"VIP"}
```

PATCH JSON:

```json
{"celular":"71111111","activo":false}
```

### Notas

- `findAll` → SELECT; `findByPk` → buscar PK; `create` → INSERT; `update` → UPDATE; `destroy` → DELETE.
- La relación Producto → Categoria reemplaza el JOIN anterior con `include`.
- DELETE puede devolver HTTP 409 si hay pedidos u otras filas referenciando al cliente.
- No uses `sequelize.sync({force:true})`: las tablas ya se crean en `docker/init/01_esquema.sql`.
- Sequelize valida algunos campos y la base de datos mantiene sus constraints. Como siguiente ejercicio agrega Zod para validar todos los cuerpos antes del controller.
- Para estudiar el SQL generado cambia `logging: false` a `logging: console.log` en `backend/src/config/database.js`.
- Los nombres de tabla y columnas están alineados con `docker/init/01_esquema.sql`.
