-- Ejecuta estas consultas en DBeaver / psql para comparar con tus GET.

-- 1. Clientes activos (también prueba cambiar TRUE por FALSE).
SELECT id, nombres, apellidos, tipo_cliente, activo FROM clientes WHERE activo = TRUE ORDER BY id;

-- 2. Clientes VIP activos.
SELECT id, nombres, correo FROM clientes WHERE tipo_cliente = 'VIP' AND activo = TRUE;

-- 3. Productos junto a su categoria.
SELECT p.id, p.sku, p.nombre, p.precio, p.stock, c.nombre AS categoria
FROM productos p JOIN categorias c ON c.id = p.categoria_id ORDER BY p.id;

-- 4. Productos agotados y con stock bajo (no son equivalentes).
SELECT id, sku, nombre, stock, stock_minimo FROM productos WHERE stock = 0;
SELECT id, sku, nombre, stock, stock_minimo FROM productos WHERE stock <= stock_minimo;

-- 5. Pedidos con nombre del cliente.
SELECT pe.referencia, pe.estado, pe.total, c.nombres, c.apellidos
FROM pedidos pe JOIN clientes c ON c.id = pe.cliente_id ORDER BY pe.id;

-- 6. Detalles de un pedido, precios historicos y subtotales.
SELECT pe.referencia, p.nombre, d.cantidad, d.precio_unitario, d.subtotal
FROM pedido_detalles d
JOIN pedidos pe ON pe.id = d.pedido_id
JOIN productos p ON p.id = d.producto_id
WHERE pe.referencia = 'DEMO-003';

-- 7. Pagos y estado del pedido.
SELECT pe.referencia, pe.estado AS estado_pedido, pa.metodo,
       pa.estado AS estado_pago, pa.monto
FROM pagos pa JOIN pedidos pe ON pe.id = pa.pedido_id
ORDER BY pe.id, pa.id;

-- 8. Pedidos enviados y entregados con seguimiento.
SELECT pe.referencia, pe.estado AS estado_pedido,
       e.estado AS estado_envio, e.codigo_seguimiento
FROM envios e JOIN pedidos pe ON pe.id = e.pedido_id ORDER BY pe.id;

-- 9. Reclamos por prioridad.
SELECT r.id, c.nombres, r.asunto, r.prioridad, r.estado
FROM reclamos r JOIN clientes c ON c.id = r.cliente_id
ORDER BY r.id;

-- 10. Conteo inicial esperado (antes de hacer tus propios POSTs).
SELECT 'clientes' AS tabla, COUNT(*) AS cantidad FROM clientes
UNION ALL SELECT 'categorias', COUNT(*) FROM categorias
UNION ALL SELECT 'productos', COUNT(*) FROM productos
UNION ALL SELECT 'cupones', COUNT(*) FROM cupones
UNION ALL SELECT 'pedidos', COUNT(*) FROM pedidos
UNION ALL SELECT 'pedido_detalles', COUNT(*) FROM pedido_detalles
UNION ALL SELECT 'pagos', COUNT(*) FROM pagos
UNION ALL SELECT 'envios', COUNT(*) FROM envios
UNION ALL SELECT 'reclamos', COUNT(*) FROM reclamos
UNION ALL SELECT 'devoluciones', COUNT(*) FROM devoluciones;
