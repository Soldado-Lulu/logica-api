# Retos de backend para el laboratorio `logica-api`

**No se incluyen soluciones**: el proposito es que programes los servicios. Implementalos gradualmente, primero con SQL parametrizado y `if`, `for...of`, funciones y `try/catch`. Despues agregaremos middlewares, schemas, autenticacion y tests.

## Nivel 1 — Consultas y primeros endpoints

| Nº | Endpoint | Que debes resolver |
|---|---|---|
| 1 | `GET /api/clientes` | Todos los clientes; filtro `?activo=true`, `?tipo=VIP`. |
| 2 | `GET /api/clientes/:id` | Buscar uno; `404` si no existe. |
| 3 | `POST /api/clientes` | Campos requeridos; `409` si el correo ya existe. |
| 4 | `PATCH /api/clientes/:id` | Actualizar solo campos enviados. |
| 5 | `GET /api/productos` | Filtrar por `categoriaId`, `minPrecio`, `maxPrecio`, `soloDisponibles`. |
| 6 | `GET /api/productos/:id` | Mostrar producto y su categoria usando `JOIN`. |
| 7 | `GET /api/productos/stock-bajo` | Retornar donde `stock <= stock_minimo`. Ojo al orden de rutas de Express (`/stock-bajo` antes de `/:id`). |
| 8 | `GET /api/clientes/:id/pedidos` | Pedidos de un cliente y su total. |

## Nivel 2 — Condiciones de negocio

| Nº | Endpoint | Reglas |
|---|---|---|
| 9 | `POST /api/productos` | Precio >= 0; stock >= 0; categoria existe; SKU unico. |
| 10 | `PATCH /api/productos/:id/stock` | Si `tipo=ENTRADA`, sumar; si `SALIDA`, restar solo si hay stock. Registrar `movimientos_inventario` y actualizar `productos` en transaccion. |
| 11 | `POST /api/cupones/validar` | Comprobar activo, vigencia, usos disponibles, monto minimo y tipo VIP. Retornar `valido`, `descuento`, `motivo`. No aumentar usos aqui. |
| 12 | `PATCH /api/clientes/:id/desactivar` | No borrar fisicamente; marcar `activo=false`. Si ya lo esta, responder de forma coherente. |

## Nivel 3 — For, arrays, calculos y multiples INSERT

**Reto principal: `POST /api/pedidos`.**

Body de ejemplo:

```json
{
  "clienteId": 2,
  "canal": "WEB",
  "cupon": "VIP15",
  "costoEnvio": 15,
  "items": [
    { "productoId": 1, "cantidad": 2 },
    { "productoId": 6, "cantidad": 3 }
  ]
}
```

Pasos orientativos para tu service:

1. Comprobar que `items` es un array no vacio, que cantidades son enteros positivos y que no haya productos repetidos.
2. Comprobar que el cliente existe y esta activo.
3. Iniciar una transaccion y leer/bloquear los productos que se usaran.
4. Recorrer cada `item` con `for...of`, comprobar existencia, activo y stock; tomar el precio REAL de la base y acumular `subtotal`.
5. Si hay cupon, evaluar todas sus reglas y calcular el descuento; limitar el descuento a `subtotal`.
6. Calcular `total`, crear `pedidos` y obtener su `id` (`INSERT ... RETURNING id`).
7. Recorrer cada item para insertar `pedido_detalles`, restar stock y registrar `movimientos_inventario`.
8. Si se uso cupon, incrementar sus usos una sola vez.
9. Crear notificacion para el cliente.
10. Ejecutar `COMMIT`. Ante cualquier error, ejecutar `ROLLBACK` para evitar datos a medias.

**Resultado esperado para el ejemplo:** mouse 2 × 80 = 160; USB 3 × 60 = 180; `subtotal = 340`, descuento VIP15 = 51, envio = 15, **total = 304 Bs**. El cliente 2 es VIP y ambos productos tienen stock al inicio.

**Casos negativos que debes probar:**

- Cliente `4` inactivo -> rechazar.
- Producto `4` sin stock -> rechazar.
- Producto `8` inactivo -> rechazar.
- Cantidad `999` -> rechazar.
- `items: []` -> rechazar.
- `items` con el mismo `productoId` repetido -> rechazar.
- `VIP15` con cliente `1` regular -> rechazar.
- Cupon `VENCIDO20`, `AGOTADO5` o `INACTIVO30` -> rechazar.
- `costoEnvio: -10` -> rechazar.

**Reto extra:** usa el identificador de referencia de pedido generado por el servidor, no recibido del cliente. Si implementas pagos simultaneos o peticiones de stock concurrentes, protege tambien esos estados con bloqueos/transacciones.

## Nivel 4 — Pagos, cancelaciones y transacciones

**Reto 13: `POST /api/pagos`**

- `estado=RECHAZADO`: guardar intento rechazado y no cambiar `pedidos.estado`.
- `estado=PENDIENTE`: guardar intento pendiente y no sumar al abonado.
- `estado=APROBADO`: sumar a pagos aprobados previos; si coincide con el total, `PAGADO` + notificacion.
- Si supera el saldo pendiente: `409`, no aceptar cobro.
- No permitir pagar pedidos `CANCELADO`, `ENVIADO` o `ENTREGADO`.
- Verificar el estado del pedido y saldo dentro de transaccion antes de aprobar pagos (evita doble pago concurrente).

**Reto 14: `PATCH /api/pedidos/:id/cancelar`**

- Solo pedidos `PENDIENTE` en esta primera version.
- `for...of` por detalles: devolver stock, insertar movimiento `ENTRADA`.
- Dejar `pedidos.estado=CANCELADO`; reintegrar el uso del cupon si lo tenia.
- Todo en una transaccion. Segundo intento de cancelar -> `409`, sin duplicar entradas.

**Reto 15: `POST /api/pedidos/:id/enviar`**

- Solo si `PAGADO`. Guardar direccion y codigo de seguimiento.
- Crear `envios` y actualizar el estado a `ENVIADO` en la misma transaccion.
- Un pedido no puede tener dos envios.

**Reto 16: `PATCH /api/envios/:id/entregar`**

- Si el envio esta `EN_CAMINO`, marcar `ENTREGADO` y el pedido `ENTREGADO`.
- Extra: endpoint previo para pasar un envio `PREPARANDO` a `EN_CAMINO`.

## Nivel 5 — Una ruta que decide en que tabla guardar

**Reto 17: `POST /api/solicitudes`**

```js
// Pseudocodigo conceptual; aun NO es una implementacion.
if (body.tipo === 'RECLAMO') {
  // registrar reclamos
} else if (body.tipo === 'DEVOLUCION') {
  // validar detalle, cliente, cantidad y registrar devoluciones
} else {
  // responder 400: tipo no permitido
}
```

**Reto 18: `PATCH /api/devoluciones/:id/resolver`**

- `APROBADA`: comprobar que no se haya resuelto antes, devolver stock con un movimiento `ENTRADA`, y notificar.
- `RECHAZADA`: no devolver stock.
- Una devolucion no puede resolverse dos veces. Respetar maximo acumulado por producto/detalle.
- Reto adicional: ¿que sucede si el cliente envia dos devoluciones simultaneas del mismo detalle?

## Nivel 6 — Consultas y algoritmos

| Nº | Endpoint | Logica |
|---|---|---|
| 19 | `GET /api/reportes/top-productos` | Ranking por unidades vendidas (considera solo pedidos no cancelados). |
| 20 | `GET /api/reportes/ventas?desde=...&hasta=...` | Sumar ventas de pedidos pagados/enviados/entregados, fechas inclusivas. |
| 21 | `GET /api/reportes/clientes-vip` | Clientes VIP y total gastado historico. |
| 22 | `GET /api/reportes/stock-bajo` | Productos con `stock <= stock_minimo`. |
| 23 | `POST /api/pedidos/cotizar` | Mismas reglas para precio/cupon, pero **sin modificar** ninguna tabla. |
| 24 | `GET /api/pedidos/:id/resumen` | Cabecera + cliente + detalles + pagos + envio si existe. |

## Para autoevaluarte

- ¿Sabes cuando devolver `200`, `201`, `400`, `404`, `409` y `500`?
- ¿Puedes explicar por que un precio debe consultarse de la BD en lugar de confiar en Postman?
- ¿Puedes garantizar que si falla el segundo `INSERT` no quede creado medio pedido?
- ¿Puedes verificar que cancelar dos veces no suma stock dos veces?
- ¿Puedes mostrar en SQL los movimientos de un producto?
- ¿Sabes diferenciar `req.params`, `req.query` y `req.body`?

> Sugerencia: empieza haciendo **solo los retos 1, 2, 3 y 5**. Cuando funcionen, continua con stock, luego pedidos y despues pagos. Cada nuevo nivel reutiliza el anterior.
