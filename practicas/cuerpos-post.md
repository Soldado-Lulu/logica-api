# Bodies para Bruno o Postman

Base sugerida de tu futura API: `http://localhost:3000/api`.

**Atencion:** los endpoints todavia no existen. Estos JSON son pruebas para cuando tu los programes. Crea una peticion POST/PATCH, selecciona Body -> JSON (raw) y pega el bloque correspondiente.

## 1. POST `/clientes` — cliente nuevo

```json
{
  "nombres": "Carla",
  "apellidos": "Mendoza",
  "correo": "carla@example.com",
  "celular": "70000005",
  "tipoCliente": "REGULAR"
}
```

Resultado esperado: `201 Created`, con ID generado.

## 2. POST `/productos` — nuevo producto

```json
{
  "categoriaId": 1,
  "sku": "PAD-001",
  "nombre": "Mouse pad",
  "precio": 35.50,
  "stock": 10,
  "stockMinimo": 3
}
```

Resultado esperado: `201`; si repites SKU, `409`.

## 3. PATCH `/productos/1/stock` — entrada de inventario

```json
{
  "tipo": "ENTRADA",
  "cantidad": 5,
  "motivo": "Compra al proveedor"
}
```

Resultado esperado: el stock del producto aumenta en 5 y se crea un movimiento.

## 4. PATCH `/productos/1/stock` — salida de inventario

```json
{
  "tipo": "SALIDA",
  "cantidad": 2,
  "motivo": "Ajuste manual"
}
```

Resultado esperado: baja el stock en 2. Si no alcanza, `409`.

## 5. POST `/cupones/validar` — evaluacion sin modificar datos

```json
{
  "clienteId": 2,
  "codigo": "VIP15",
  "subtotal": 340
}
```

Ejemplo de respuesta posible:

```json
{
  "valido": true,
  "descuento": 51,
  "motivo": "Cupon aplicable"
}
```

Prueba tambien cambiando a `clienteId: 1`, `codigo: "VENCIDO20"`, `"AGOTADO5"` y `"INACTIVO30"`.

## 6. POST `/pedidos` — array con dos items

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

Resultado esperado con datos iniciales: `201`, subtotal 340, descuento 51, total 304; 2 detalles, 2 movimientos y 1 notificacion. **No confies en un `total` enviado por el usuario; calculalo en el service.**

## 7. POST `/pedidos` — caso con error de stock

```json
{
  "clienteId": 1,
  "canal": "WEB",
  "costoEnvio": 0,
  "items": [
    { "productoId": 4, "cantidad": 1 }
  ]
}
```

Resultado esperado: `409`, inventario sin cambios y ningun pedido parcial.

## 8. POST `/pagos` — pago aprobado

```json
{
  "pedidoId": 2,
  "metodo": "QR",
  "estado": "APROBADO",
  "monto": 50,
  "referenciaPago": "QR-PRACTICA-001"
}
```

Con la base recien creada, el pedido 2 es `DEMO-002`, total 50, estado `PENDIENTE`; al aprobar el pago cambiaria a `PAGADO`. Si ya ejecutaste otros retos, consulta el pedido antes.

## 9. POST `/pagos` — intento rechazado

```json
{
  "pedidoId": 2,
  "metodo": "TARJETA",
  "estado": "RECHAZADO",
  "monto": 50,
  "referenciaPago": "RECHAZO-001"
}
```

Resultado esperado: registrar el intento, sin sumar al total abonado.

## 10. PATCH `/pedidos/2/cancelar` — sin body

Solo puede cancelarse si sigue `PENDIENTE`. Debera devolver 2 unidades de `CAB-001` y cambiar el estado del pedido. Para probar esto desde cero, **no apruebes antes el pago del ejemplo 8**.

## 11. POST `/solicitudes` — ruta RECLAMO

```json
{
  "tipo": "RECLAMO",
  "clienteId": 1,
  "pedidoId": 1,
  "asunto": "Producto en mal estado",
  "descripcion": "La caja llego golpeada",
  "prioridad": "ALTA"
}
```

Resultado esperado: INSERT en `reclamos`, **no** en `devoluciones`.

## 12. POST `/solicitudes` — ruta DEVOLUCION

```json
{
  "tipo": "DEVOLUCION",
  "clienteId": 1,
  "pedidoDetalleId": 1,
  "cantidad": 1,
  "motivo": "Producto defectuoso"
}
```

Resultado esperado con datos iniciales: INSERT en `devoluciones`, no en `reclamos`, siempre que el detalle 1 pertenezca a Ana. Confirma el detalle con SQL antes de probar.

## 13. POST `/solicitudes` — tipo desconocido

```json
{
  "tipo": "OTRO",
  "clienteId": 1
}
```

Resultado esperado: `400 Bad Request` y cero inserts.

## 14. POST `/pedidos/1/enviar`

```json
{
  "direccion": "Av. America 123, Cochabamba",
  "codigoSeguimiento": "ENV-DEMO-001"
}
```

`DEMO-001` ya esta `PAGADO` en la base recien creada. Crea el envio y cambia el pedido a `ENVIADO` de manera atomica.
