-- Consultas para pegar dentro de psql, DBeaver o pgAdmin.
-- Estan pensadas para estudiar relaciones y comprobar tu futura API.

-- 1. Clientes y tipo
SELECT id, nombres, apellidos, correo, tipo_cliente, activo
FROM clientes ORDER BY id;

-- 2. Productos con categoria
SELECT p.id, p.sku, p.nombre, c.nombre AS categoria, p.precio, p.stock, p.activo
FROM productos p
JOIN categorias c ON c.id = p.categoria_id
ORDER BY p.id;

-- 3. Productos en alerta
SELECT sku, nombre, stock, stock_minimo
FROM productos
WHERE stock <= stock_minimo AND activo = TRUE
ORDER BY stock;

-- 4. Cabecera de pedidos con nombre del cliente
SELECT pe.id, pe.referencia, c.nombres, c.apellidos, pe.estado,
       pe.subtotal, pe.descuento, pe.costo_envio, pe.total
FROM pedidos pe
JOIN clientes c ON c.id = pe.cliente_id
ORDER BY pe.id;

-- 5. Detalle de todos los pedidos
SELECT pe.referencia, pr.nombre AS producto, d.cantidad,
       d.precio_unitario, d.subtotal
FROM pedido_detalles d
JOIN pedidos pe ON pe.id = d.pedido_id
JOIN productos pr ON pr.id = d.producto_id
ORDER BY pe.id, d.id;

-- 6. Pagos acumulados por pedido; rechazados NO suman
SELECT pe.referencia, pe.total,
       COALESCE(SUM(pa.monto) FILTER (WHERE pa.estado = 'APROBADO'), 0) AS aprobado,
       pe.total - COALESCE(SUM(pa.monto) FILTER (WHERE pa.estado = 'APROBADO'), 0) AS saldo
FROM pedidos pe
LEFT JOIN pagos pa ON pa.pedido_id = pe.id
GROUP BY pe.id, pe.referencia, pe.total
ORDER BY pe.id;

-- 7. Historia de stock
SELECT pr.sku, m.tipo, m.cantidad, m.motivo, m.creado_en
FROM movimientos_inventario m
JOIN productos pr ON pr.id = m.producto_id
ORDER BY m.id DESC;

-- 8. Cantidad de pedidos por cliente
SELECT c.id, c.nombres, COUNT(pe.id) AS numero_pedidos
FROM clientes c
LEFT JOIN pedidos pe ON pe.cliente_id = c.id
GROUP BY c.id, c.nombres
ORDER BY numero_pedidos DESC;

-- 9. Cupones y validez de calendario (no comprueba tipo VIP)
SELECT codigo, activo, usos_actuales, usos_maximos,
       CURRENT_DATE BETWEEN fecha_inicio AND fecha_fin AS vigente_hoy
FROM cupones ORDER BY id;

-- 10. Comprueba las dos posibles tablas de solicitudes
SELECT 'RECLAMO' AS tipo, COUNT(*) AS cantidad FROM reclamos
UNION ALL
SELECT 'DEVOLUCION' AS tipo, COUNT(*) AS cantidad FROM devoluciones;

-- 11. Comprobar todas las tablas del laboratorio
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;
