-- ============================================================
-- LABORATORIO: LOGICA API | Datos de ejemplo
-- Archivo 2 de 2: se ejecuta DESPUES del esquema.
-- Estas inserciones se aplican una sola vez al crear el volumen.
-- ============================================================

BEGIN;

INSERT INTO clientes (nombres, apellidos, correo, celular, tipo_cliente, activo) VALUES
('Ana', 'Rojas', 'ana@example.com', '70000001', 'REGULAR', TRUE),
('Luis', 'Flores', 'luis@example.com', '70000002', 'VIP', TRUE),
('Maria', 'Quispe', 'maria@example.com', '70000003', 'REGULAR', TRUE),
('Pedro', 'Vargas', 'pedro@example.com', '70000004', 'REGULAR', FALSE);

INSERT INTO categorias (nombre, descripcion) VALUES
('Perifericos', 'Accesorios para computadoras'),
('Pantallas', 'Monitores y dispositivos de video'),
('Almacenamiento', 'Memorias y unidades portatiles'),
('Muebles', 'Sillas y mobiliario de oficina');

INSERT INTO productos (categoria_id, sku, nombre, precio, stock, stock_minimo, activo) VALUES
((SELECT id FROM categorias WHERE nombre = 'Perifericos'), 'MOU-001', 'Mouse inalambrico', 80.00, 24, 5, TRUE),
((SELECT id FROM categorias WHERE nombre = 'Perifericos'), 'TEC-001', 'Teclado mecanico', 150.00, 11, 3, TRUE),
((SELECT id FROM categorias WHERE nombre = 'Pantallas'), 'MON-001', 'Monitor 24 pulgadas', 1200.00, 4, 5, TRUE),
((SELECT id FROM categorias WHERE nombre = 'Perifericos'), 'AUD-001', 'Auriculares', 200.00, 0, 5, TRUE),
((SELECT id FROM categorias WHERE nombre = 'Perifericos'), 'CAB-001', 'Cable USB-C', 25.00, 48, 10, TRUE),
((SELECT id FROM categorias WHERE nombre = 'Almacenamiento'), 'USB-001', 'Memoria USB 64 GB', 60.00, 30, 8, TRUE),
((SELECT id FROM categorias WHERE nombre = 'Muebles'), 'SIL-001', 'Silla ergonomica', 450.00, 8, 2, TRUE),
((SELECT id FROM categorias WHERE nombre = 'Perifericos'), 'WEB-001', 'Camara web antigua', 300.00, 7, 2, FALSE);

INSERT INTO cupones (
  codigo, tipo_descuento, valor, compra_minima, usos_maximos,
  usos_actuales, fecha_inicio, fecha_fin, activo
) VALUES
('BIENVENIDA10', 'PORCENTAJE', 10.00, 100.00, 100, 0, DATE '2026-01-01', DATE '2099-12-31', TRUE),
('VIP15', 'PORCENTAJE', 15.00, 200.00, 50, 0, DATE '2026-01-01', DATE '2099-12-31', TRUE),
('VENCIDO20', 'PORCENTAJE', 20.00, 100.00, 10, 0, DATE '2024-01-01', DATE '2025-12-31', TRUE),
('AGOTADO5', 'MONTO', 5.00, 50.00, 10, 10, DATE '2026-01-01', DATE '2099-12-31', TRUE),
('INACTIVO30', 'PORCENTAJE', 30.00, 100.00, 30, 0, DATE '2026-01-01', DATE '2099-12-31', FALSE);

-- Pedido 1: ya pagado, dos productos.
INSERT INTO pedidos (referencia, cliente_id, canal, estado, subtotal, descuento, costo_envio, total)
SELECT 'DEMO-001', id, 'WEB', 'PAGADO', 230.00, 0.00, 0.00, 230.00
FROM clientes WHERE correo = 'ana@example.com';

INSERT INTO pedido_detalles (pedido_id, producto_id, cantidad, precio_unitario, subtotal)
SELECT pe.id, pr.id, 1, pr.precio, pr.precio
FROM pedidos pe CROSS JOIN productos pr
WHERE pe.referencia = 'DEMO-001' AND pr.sku IN ('MOU-001', 'TEC-001');

INSERT INTO pagos (pedido_id, metodo, estado, monto, referencia_pago)
SELECT id, 'QR', 'APROBADO', 230.00, 'PAGO-DEMO-001'
FROM pedidos WHERE referencia = 'DEMO-001';

-- Pedido 2: pendiente de pago, dos cables.
INSERT INTO pedidos (referencia, cliente_id, canal, estado, subtotal, descuento, costo_envio, total)
SELECT 'DEMO-002', id, 'WHATSAPP', 'PENDIENTE', 50.00, 0.00, 0.00, 50.00
FROM clientes WHERE correo = 'luis@example.com';

INSERT INTO pedido_detalles (pedido_id, producto_id, cantidad, precio_unitario, subtotal)
SELECT pe.id, pr.id, 2, pr.precio, 2 * pr.precio
FROM pedidos pe CROSS JOIN productos pr
WHERE pe.referencia = 'DEMO-002' AND pr.sku = 'CAB-001';

-- Stock de productos ya refleja la salida de estos pedidos.
-- Guardamos los movimientos historicos sin descontar dos veces.
INSERT INTO movimientos_inventario (producto_id, pedido_id, tipo, cantidad, motivo)
SELECT pr.id, pe.id, 'SALIDA', pd.cantidad, 'Creacion del pedido ' || pe.referencia
FROM pedido_detalles pd
JOIN productos pr ON pr.id = pd.producto_id
JOIN pedidos pe ON pe.id = pd.pedido_id
WHERE pe.referencia IN ('DEMO-001', 'DEMO-002');

INSERT INTO notificaciones (cliente_id, canal, mensaje)
SELECT id, 'SISTEMA', 'Tu pedido DEMO-001 fue pagado correctamente.'
FROM clientes WHERE correo = 'ana@example.com';

INSERT INTO reclamos (cliente_id, pedido_id, asunto, descripcion, prioridad)
SELECT c.id, p.id, 'Consulta sobre factura', 'Necesito una copia de mi factura.', 'BAJA'
FROM clientes c JOIN pedidos p ON p.cliente_id = c.id
WHERE c.correo = 'ana@example.com' AND p.referencia = 'DEMO-001';

COMMIT;
