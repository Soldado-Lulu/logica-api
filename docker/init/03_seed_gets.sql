-- ==============================================================
-- Datos EXTRA para practicar GET, filtros, joins y estados.
-- Se ejecuta automaticamente al CREAR un volumen nuevo.
-- Si ya tienes volumen: docker compose exec postgres psql -U
-- logica_user -d logica_api -f /docker-entrypoint-initdb.d/03_seed_gets.sql
-- Repetible: evita duplicar datos y evita restar stock dos veces.
-- ==============================================================
BEGIN;

INSERT INTO clientes (nombres, apellidos, correo, celular, tipo_cliente, activo) VALUES
('Sofia', 'Mercado', 'sofia@example.com', '70000005', 'VIP', TRUE),
('Carlos', 'Lopez', 'carlos@example.com', '70000006', 'REGULAR', TRUE),
('Elena', 'Choque', 'elena@example.com', '70000007', 'VIP', TRUE),
('Raul', 'Salinas', 'raul@example.com', '70000008', 'REGULAR', TRUE),
('Camila', 'Paredes', 'camila@example.com', '70000009', 'REGULAR', FALSE),
('Jorge', 'Tola', 'jorge@example.com', '70000010', 'VIP', TRUE)
ON CONFLICT (correo) DO NOTHING;

INSERT INTO categorias (nombre, descripcion) VALUES
('Redes', 'Routers, switches y accesorios de red'),
('Oficina', 'Articulos para escritorio y trabajo')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO productos (categoria_id, sku, nombre, precio, stock, stock_minimo, activo)
SELECT c.id, p.sku, p.nombre, p.precio, p.stock, p.stock_minimo, p.activo
FROM (VALUES
  ('Almacenamiento', 'SSD-001', 'SSD 1 TB', 390.00::numeric, 13, 3, TRUE),
  ('Perifericos', 'MOU-002', 'Mouse gamer RGB', 135.00::numeric, 15, 5, TRUE),
  ('Redes', 'SWI-001', 'Switch 8 puertos', 250.00::numeric, 2, 3, TRUE),
  ('Redes', 'ROU-001', 'Router Wi-Fi', 310.00::numeric, 0, 2, TRUE),
  ('Oficina', 'ESC-001', 'Escritorio compacto', 680.00::numeric, 5, 2, TRUE),
  ('Oficina', 'LAP-001', 'Soporte para laptop', 90.00::numeric, 7, 4, TRUE),
  ('Pantallas', 'MON-002', 'Monitor 27 pulgadas', 1750.00::numeric, 1, 2, TRUE),
  ('Perifericos', 'HUB-001', 'Hub USB descontinuado', 110.00::numeric, 0, 3, FALSE)
) AS p(categoria, sku, nombre, precio, stock, stock_minimo, activo)
JOIN categorias c ON c.nombre = p.categoria
ON CONFLICT (sku) DO NOTHING;

-- Los stock de productos reflejan estas ventas ya realizadas.
-- La clausula RETURNING evita volver a descontar al re-ejecutar este archivo.
WITH pedido_nuevo AS (
  INSERT INTO pedidos (referencia, cliente_id, canal, estado, subtotal, descuento, costo_envio, total)
  SELECT 'DEMO-003', id, 'WEB', 'PAGADO', 510.00, 0.00, 15.00, 525.00
  FROM clientes WHERE correo = 'sofia@example.com'
  ON CONFLICT (referencia) DO NOTHING
  RETURNING id
)
UPDATE productos p SET stock = p.stock - v.cantidad
FROM (VALUES ('SSD-001', 1), ('USB-001', 2)) AS v(sku, cantidad)
WHERE p.sku = v.sku AND EXISTS (SELECT 1 FROM pedido_nuevo);

WITH pedido_nuevo AS (
  INSERT INTO pedidos (referencia, cliente_id, canal, estado, subtotal, descuento, costo_envio, total)
  SELECT 'DEMO-004', id, 'TIENDA', 'ENVIADO', 475.00, 0.00, 20.00, 495.00
  FROM clientes WHERE correo = 'elena@example.com'
  ON CONFLICT (referencia) DO NOTHING
  RETURNING id
)
UPDATE productos p SET stock = p.stock - v.cantidad
FROM (VALUES ('SIL-001', 1), ('CAB-001', 1)) AS v(sku, cantidad)
WHERE p.sku = v.sku AND EXISTS (SELECT 1 FROM pedido_nuevo);

WITH pedido_nuevo AS (
  INSERT INTO pedidos (referencia, cliente_id, canal, estado, subtotal, descuento, costo_envio, total)
  SELECT 'DEMO-005', id, 'WEB', 'ENTREGADO', 230.00, 0.00, 0.00, 230.00
  FROM clientes WHERE correo = 'maria@example.com'
  ON CONFLICT (referencia) DO NOTHING
  RETURNING id
)
UPDATE productos p SET stock = p.stock - v.cantidad
FROM (VALUES ('MOU-001', 1), ('TEC-001', 1)) AS v(sku, cantidad)
WHERE p.sku = v.sku AND EXISTS (SELECT 1 FROM pedido_nuevo);

-- Cancelado: su stock ya fue reintegrado, NO se descuenta al sembrar.
INSERT INTO pedidos (referencia, cliente_id, canal, estado, subtotal, descuento, costo_envio, total)
SELECT 'DEMO-006', id, 'WHATSAPP', 'CANCELADO', 60.00, 0.00, 0.00, 60.00
FROM clientes WHERE correo = 'carlos@example.com'
ON CONFLICT (referencia) DO NOTHING;

WITH pedido_nuevo AS (
  INSERT INTO pedidos (referencia, cliente_id, canal, estado, subtotal, descuento, costo_envio, total)
  SELECT 'DEMO-007', id, 'WEB', 'PENDIENTE', 135.00, 0.00, 0.00, 135.00
  FROM clientes WHERE correo = 'raul@example.com'
  ON CONFLICT (referencia) DO NOTHING
  RETURNING id
)
UPDATE productos SET stock = stock - 1
WHERE sku = 'MOU-002' AND EXISTS (SELECT 1 FROM pedido_nuevo);

INSERT INTO pedido_detalles (pedido_id, producto_id, cantidad, precio_unitario, subtotal)
SELECT pe.id, pr.id, v.cantidad, pr.precio, pr.precio * v.cantidad
FROM (VALUES
  ('DEMO-003', 'SSD-001', 1), ('DEMO-003', 'USB-001', 2),
  ('DEMO-004', 'SIL-001', 1), ('DEMO-004', 'CAB-001', 1),
  ('DEMO-005', 'MOU-001', 1), ('DEMO-005', 'TEC-001', 1),
  ('DEMO-006', 'USB-001', 1),
  ('DEMO-007', 'MOU-002', 1)
) AS v(referencia, sku, cantidad)
JOIN pedidos pe ON pe.referencia = v.referencia
JOIN productos pr ON pr.sku = v.sku
ON CONFLICT (pedido_id, producto_id) DO NOTHING;

-- Crear la salida historica de cada pedido nuevo sin duplicar movimientos.
INSERT INTO movimientos_inventario (producto_id, pedido_id, tipo, cantidad, motivo)
SELECT pd.producto_id, pd.pedido_id, 'SALIDA', pd.cantidad,
       'Creacion del pedido ' || pe.referencia
FROM pedido_detalles pd JOIN pedidos pe ON pe.id = pd.pedido_id
WHERE pe.referencia BETWEEN 'DEMO-003' AND 'DEMO-007'
AND NOT EXISTS (
  SELECT 1 FROM movimientos_inventario mi
  WHERE mi.pedido_id = pd.pedido_id AND mi.producto_id = pd.producto_id
    AND mi.tipo = 'SALIDA'
);

INSERT INTO movimientos_inventario (producto_id, pedido_id, tipo, cantidad, motivo)
SELECT pd.producto_id, pd.pedido_id, 'ENTRADA', pd.cantidad,
       'Cancelacion del pedido ' || pe.referencia
FROM pedido_detalles pd JOIN pedidos pe ON pe.id = pd.pedido_id
WHERE pe.referencia = 'DEMO-006'
AND NOT EXISTS (
  SELECT 1 FROM movimientos_inventario mi
  WHERE mi.pedido_id = pd.pedido_id AND mi.producto_id = pd.producto_id
    AND mi.tipo = 'ENTRADA'
);

INSERT INTO pagos (pedido_id, metodo, estado, monto, referencia_pago)
SELECT pe.id, v.metodo, v.estado, v.monto, v.ref
FROM (VALUES
  ('DEMO-003', 'QR', 'APROBADO', 525.00::numeric, 'PAGO-DEMO-003'),
  ('DEMO-004', 'TRANSFERENCIA', 'APROBADO', 495.00::numeric, 'PAGO-DEMO-004'),
  ('DEMO-005', 'EFECTIVO', 'APROBADO', 230.00::numeric, 'PAGO-DEMO-005'),
  ('DEMO-007', 'QR', 'RECHAZADO', 135.00::numeric, 'PAGO-DEMO-007-R'),
  ('DEMO-007', 'QR', 'PENDIENTE', 135.00::numeric, 'PAGO-DEMO-007-P')
) AS v(referencia, metodo, estado, monto, ref)
JOIN pedidos pe ON pe.referencia = v.referencia
ON CONFLICT (referencia_pago) DO NOTHING;

INSERT INTO envios (pedido_id, direccion, estado, codigo_seguimiento)
SELECT pe.id, v.direccion, v.estado, v.codigo
FROM (VALUES
  ('DEMO-004', 'Av. Libertador #120, Cochabamba', 'EN_CAMINO', 'ENV-DEMO-004'),
  ('DEMO-005', 'Calle Sucre #200, Cochabamba', 'ENTREGADO', 'ENV-DEMO-005')
) AS v(referencia, direccion, estado, codigo)
JOIN pedidos pe ON pe.referencia = v.referencia
ON CONFLICT (pedido_id) DO NOTHING;

INSERT INTO reclamos (cliente_id, pedido_id, asunto, descripcion, prioridad, estado)
SELECT c.id, pe.id, v.asunto, v.descripcion, v.prioridad, v.estado
FROM (VALUES
  ('elena@example.com', 'DEMO-004', 'Demora en el envio', 'Quiero conocer la ubicacion de mi paquete', 'MEDIA', 'EN_PROCESO'),
  ('maria@example.com', 'DEMO-005', 'Caja danada', 'El paquete llego con un golpe exterior', 'ALTA', 'ABIERTO')
) AS v(correo, referencia, asunto, descripcion, prioridad, estado)
JOIN clientes c ON c.correo = v.correo
JOIN pedidos pe ON pe.referencia = v.referencia
WHERE NOT EXISTS (SELECT 1 FROM reclamos r WHERE r.pedido_id = pe.id AND r.asunto = v.asunto);

INSERT INTO devoluciones (cliente_id, pedido_detalle_id, cantidad, motivo, estado)
SELECT c.id, pd.id, 1, 'El mouse presenta problemas', 'SOLICITADA'
FROM clientes c JOIN pedidos pe ON pe.cliente_id = c.id
JOIN pedido_detalles pd ON pd.pedido_id = pe.id
JOIN productos pr ON pr.id = pd.producto_id
WHERE pe.referencia = 'DEMO-005' AND pr.sku = 'MOU-001'
AND NOT EXISTS (SELECT 1 FROM devoluciones d WHERE d.pedido_detalle_id = pd.id AND d.motivo = 'El mouse presenta problemas');

INSERT INTO notificaciones (cliente_id, canal, mensaje, leida)
SELECT c.id, v.canal, v.mensaje, v.leida
FROM (VALUES
  ('sofia@example.com', 'SISTEMA', 'Tu pedido DEMO-003 fue pagado.', TRUE),
  ('elena@example.com', 'EMAIL', 'Tu pedido DEMO-004 esta en camino.', FALSE),
  ('maria@example.com', 'SISTEMA', 'Tu pedido DEMO-005 fue entregado.', FALSE)
) AS v(correo, canal, mensaje, leida)
JOIN clientes c ON c.correo = v.correo
WHERE NOT EXISTS (SELECT 1 FROM notificaciones n WHERE n.cliente_id = c.id AND n.mensaje = v.mensaje);

COMMIT;
