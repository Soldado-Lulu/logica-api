# Guía progresiva para crear módulos

## Día 1 — Verificar todo y comprender el primer GET

1. Ejecuta `docker compose up -d --build`.
2. Comprueba `GET /api/health` (esperas HTTP 200).
3. Prueba `GET /api/clientes` y `GET /api/productos`.
4. En los 4 archivos de `clientes` coloca `console.log` temporales (route no hace falta) y observa la secuencia en `docker compose logs -f backend`.
5. Ejecuta la consulta `SELECT * FROM clientes` en psql o DBeaver y compara filas con JSON.

**Pregunta**: ¿Por qué `service` no contiene SQL y `controller` no hace consultas a PostgreSQL? ¿Qué devuelve `pool.query`?

## Día 2 — Tu primer endpoint por ID (sin copiar solución)

Objetivo: `GET /api/clientes/1`, `GET /api/clientes/9999`.

- En `clientes.routes.js`, registra `GET /:id`.
- En `clientes.controller.js`, lee `req.params.id` y manda el valor al service.
- En `clientes.service.js`, comprueba que el ID sea un entero positivo y busca en repository.
- En `clientes.repository.js`, usa `WHERE id = $1` con un parámetro (no concatenes strings).
- Devuelve HTTP 200 si existe, 400 si el parámetro no es válido y 404 si no existe.

Pruebas: `/api/clientes/1`, `/api/clientes/9999`, `/api/clientes/abc`, `/api/clientes/-3`.

## Día 3 — Filtrado mediante query params

Objetivo: `GET /api/clientes?activo=true&tipo=VIP`.

- Controller obtiene `req.query.activo` y `req.query.tipo`.
- Service interpreta el texto `"true"`/`"false"`; no uses `Boolean("false")` porque da `true`.
- Repository construye SQL seguro (parámetros `$1`, `$2`) o condiciones estáticas opcionales.
- Prueba filtros aislados y combinados; también un valor inválido como `?activo=hola`.

## Día 4 — Tu primer POST

Objetivo: `POST /api/clientes`.

Body en Bruno/Postman, pestaña JSON:

```json
{
  "nombres": "Daniel",
  "apellidos": "Mamani",
  "correo": "daniel@example.com",
  "celular": "70009999",
  "tipoCliente": "REGULAR"
}
```

Service: comprueba campos y tipo; repository: `INSERT ... RETURNING *` parametrizado. Devuelve 201 al crear, 400 si faltan datos, 409 si el correo se repite. Por ahora haz validaciones sencillas con `if` dentro del service.

## Día 5 — Categorías y productos

- Crea archivos `categorias.routes/controller/service/repository.js` siguiendo los de clientes.
- `GET /api/categorias` devuelve las seis categorías.
- `GET /api/productos/stock-bajo` (registra antes de `/api/productos/:id`): `stock <= stock_minimo`.
- `GET /api/productos?categoriaId=1&soloDisponibles=true`.
- `GET /api/productos/:id` con JOIN, 404 si no existe.
- `POST /api/productos`: comprueba SKU único, categoría existente, precio/stock >= 0.

## Día 6 — Inventario

- `GET /api/inventario/movimientos?productoId=1`.
- `PATCH /api/productos/:id/stock` recibe `{ "tipo": "ENTRADA", "cantidad": 5 }`.
- Si `ENTRADA`, suma. Si `SALIDA`, resta solo con stock suficiente. Guarda un movimiento.
- Ambas consultas (UPDATE e INSERT) deben estar en una transacción para no guardar datos a medias.

## Días 7–8 — Pedidos y bucles

- `GET /api/pedidos` filtra por estado o cliente; `GET /api/pedidos/:id` devuelve cabecera y detalles.
- `POST /api/pedidos` recibe `items: [{ "productoId": 1, "cantidad": 2 }, ...]`.
- Itera con `for...of`; revisa cada producto, stock, precio y calcula `subtotal`.
- Inserta cabecera y detalles, actualiza stock y registra movimientos en una sola transacción.
- Si algo falla, ejecuta ROLLBACK. Usa `const client = await pool.connect()` y `client.query` en todos los pasos de la transacción, no `pool.query` para unas consultas y `client.query` para otras.

## Días 9–10 — Reglas con estados y decisiones

- `POST /api/cupones/validar`: vigencia, máximo de usos, compra mínima, VIP.
- `POST /api/pagos`: pendiente/rechazado/aprobado; nunca marques pagado si el total recibido es insuficiente.
- `POST /api/solicitudes`: según `tipo`, guardar en `reclamos` o `devoluciones`.
- `PATCH /api/pedidos/:id/cancelar`: reponer stock exactamente una vez.

## Después — Arquitectura profesional

Cuando domines GET/POST/PATCH, añade validación con Zod, middlewares, errores comunes, JWT, autenticación, roles/permisos, tests con Vitest, paginación y migraciones. No antes: primero comprende bien el flujo.

## Regla de oro para todos tus endpoints

En cada tarea prueba estos cuatro escenarios: caso correcto (200/201), ID inexistente (404), body/param inválido (400) y conflicto de negocio (409). Los códigos exactos dependen del caso; no todos los GET tienen 409.
