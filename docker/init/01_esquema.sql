-- ============================================================
-- LABORATORIO: LOGICA API | PostgreSQL 16
-- Archivo 1 de 2: estructura de la base de datos.
--
-- IMPORTANTE: estas tablas solo guardan y protegen datos basicos.
-- Las reglas de negocio (if/else, for, validaciones, transacciones)
-- se implementaran despues en tus services de Express.
-- ============================================================

BEGIN;

-- 1. CLIENTES: registro, busqueda, filtros y condiciones VIP.
CREATE TABLE clientes (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombres          VARCHAR(100) NOT NULL,
    apellidos        VARCHAR(100) NOT NULL,
    correo           VARCHAR(180) NOT NULL UNIQUE,
    celular          VARCHAR(25),
    tipo_cliente     VARCHAR(10) NOT NULL DEFAULT 'REGULAR'
                     CHECK (tipo_cliente IN ('REGULAR', 'VIP')),
    activo           BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. CATEGORIAS: practica de relaciones uno-a-muchos.
CREATE TABLE categorias (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL UNIQUE,
    descripcion      TEXT,
    activa           BOOLEAN NOT NULL DEFAULT TRUE
);

-- 3. PRODUCTOS: filtros, ordenamiento, stock y precio.
CREATE TABLE productos (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    categoria_id     BIGINT NOT NULL REFERENCES categorias(id) ON DELETE RESTRICT,
    sku              VARCHAR(40) NOT NULL UNIQUE,
    nombre           VARCHAR(150) NOT NULL,
    precio           NUMERIC(12, 2) NOT NULL CHECK (precio >= 0),
    stock            INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    stock_minimo     INTEGER NOT NULL DEFAULT 5 CHECK (stock_minimo >= 0),
    activo           BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. CUPONES: fechas, usos y descuentos PORCENTAJE o MONTO.
CREATE TABLE cupones (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo           VARCHAR(40) NOT NULL UNIQUE,
    tipo_descuento   VARCHAR(12) NOT NULL
                     CHECK (tipo_descuento IN ('PORCENTAJE', 'MONTO')),
    valor            NUMERIC(12, 2) NOT NULL CHECK (valor > 0),
    compra_minima    NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (compra_minima >= 0),
    usos_maximos     INTEGER NOT NULL CHECK (usos_maximos > 0),
    usos_actuales    INTEGER NOT NULL DEFAULT 0 CHECK (usos_actuales >= 0),
    fecha_inicio     DATE NOT NULL,
    fecha_fin        DATE NOT NULL,
    activo           BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (fecha_fin >= fecha_inicio),
    CHECK (usos_actuales <= usos_maximos),
    CHECK (tipo_descuento <> 'PORCENTAJE' OR valor <= 100)
);

-- 5. PEDIDOS: una cabecera con importes calculados por el backend.
-- Regla del laboratorio: al crear el pedido se descuenta stock.
-- Cancelar repone stock; pagar NO vuelve a descontar.
CREATE TABLE pedidos (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    referencia       VARCHAR(40) NOT NULL UNIQUE,
    cliente_id       BIGINT NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
    cupon_id         BIGINT REFERENCES cupones(id) ON DELETE RESTRICT,
    canal            VARCHAR(15) NOT NULL DEFAULT 'WEB'
                     CHECK (canal IN ('WEB', 'TIENDA', 'WHATSAPP')),
    estado           VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE'
                     CHECK (estado IN ('PENDIENTE', 'PAGADO', 'CANCELADO', 'ENVIADO', 'ENTREGADO')),
    subtotal         NUMERIC(12, 2) NOT NULL CHECK (subtotal >= 0),
    descuento        NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (descuento >= 0),
    costo_envio      NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (costo_envio >= 0),
    total            NUMERIC(12, 2) NOT NULL CHECK (total >= 0),
    creado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (descuento <= subtotal),
    CHECK (total = subtotal - descuento + costo_envio)
);

-- 6. PEDIDO_DETALLES: lista de productos (for...of).
-- Se guarda el precio historico de cada producto en el pedido.
CREATE TABLE pedido_detalles (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id        BIGINT NOT NULL REFERENCES pedidos(id) ON DELETE RESTRICT,
    producto_id      BIGINT NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    cantidad         INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario  NUMERIC(12, 2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal         NUMERIC(12, 2) NOT NULL,
    UNIQUE (pedido_id, producto_id),
    CHECK (subtotal = cantidad * precio_unitario)
);

-- 7. PAGOS: aprobados, rechazados y pendientes.
-- El service decide si cambia el estado de un pedido a PAGADO.
CREATE TABLE pagos (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id        BIGINT NOT NULL REFERENCES pedidos(id) ON DELETE RESTRICT,
    metodo           VARCHAR(15) NOT NULL
                     CHECK (metodo IN ('EFECTIVO', 'QR', 'TRANSFERENCIA', 'TARJETA')),
    estado           VARCHAR(12) NOT NULL DEFAULT 'PENDIENTE'
                     CHECK (estado IN ('PENDIENTE', 'APROBADO', 'RECHAZADO')),
    monto            NUMERIC(12, 2) NOT NULL CHECK (monto > 0),
    referencia_pago  VARCHAR(80) UNIQUE,
    creado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. MOVIMIENTOS_INVENTARIO: historial de entradas y salidas.
-- El stock actual esta en productos.stock (no hay triggers).
CREATE TABLE movimientos_inventario (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    producto_id      BIGINT NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    pedido_id        BIGINT REFERENCES pedidos(id) ON DELETE RESTRICT,
    tipo             VARCHAR(18) NOT NULL
                     CHECK (tipo IN ('ENTRADA', 'SALIDA', 'AJUSTE_POSITIVO', 'AJUSTE_NEGATIVO')),
    cantidad         INTEGER NOT NULL CHECK (cantidad > 0),
    motivo           VARCHAR(200) NOT NULL,
    creado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. ENVIOS: un pedido puede tener como maximo un envio.
CREATE TABLE envios (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id        BIGINT NOT NULL UNIQUE REFERENCES pedidos(id) ON DELETE RESTRICT,
    direccion        VARCHAR(250) NOT NULL,
    estado           VARCHAR(15) NOT NULL DEFAULT 'PREPARANDO'
                     CHECK (estado IN ('PREPARANDO', 'EN_CAMINO', 'ENTREGADO')),
    codigo_seguimiento VARCHAR(60) UNIQUE,
    creado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 10. NOTIFICACIONES: mensajes creados al ejecutar reglas de negocio.
CREATE TABLE notificaciones (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id       BIGINT NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
    canal            VARCHAR(10) NOT NULL DEFAULT 'SISTEMA'
                     CHECK (canal IN ('SISTEMA', 'EMAIL', 'SMS')),
    mensaje          TEXT NOT NULL,
    leida            BOOLEAN NOT NULL DEFAULT FALSE,
    creado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 11. RECLAMOS: un destino posible de POST /solicitudes.
CREATE TABLE reclamos (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id       BIGINT NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
    pedido_id        BIGINT REFERENCES pedidos(id) ON DELETE RESTRICT,
    asunto           VARCHAR(160) NOT NULL,
    descripcion      TEXT NOT NULL,
    prioridad        VARCHAR(10) NOT NULL DEFAULT 'MEDIA'
                     CHECK (prioridad IN ('BAJA', 'MEDIA', 'ALTA')),
    estado           VARCHAR(12) NOT NULL DEFAULT 'ABIERTO'
                     CHECK (estado IN ('ABIERTO', 'EN_PROCESO', 'CERRADO')),
    creado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 12. DEVOLUCIONES: el otro destino posible de POST /solicitudes.
CREATE TABLE devoluciones (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id       BIGINT NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
    pedido_detalle_id BIGINT NOT NULL REFERENCES pedido_detalles(id) ON DELETE RESTRICT,
    cantidad         INTEGER NOT NULL CHECK (cantidad > 0),
    motivo           TEXT NOT NULL,
    estado           VARCHAR(12) NOT NULL DEFAULT 'SOLICITADA'
                     CHECK (estado IN ('SOLICITADA', 'APROBADA', 'RECHAZADA')),
    creado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indices para tus practicas de filtros y joins.
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_nombre ON productos(nombre);
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_estado ON pedidos(estado);
CREATE INDEX idx_pedido_detalles_pedido ON pedido_detalles(pedido_id);
CREATE INDEX idx_pagos_pedido ON pagos(pedido_id);
CREATE INDEX idx_movimientos_producto ON movimientos_inventario(producto_id);
CREATE INDEX idx_notificaciones_cliente ON notificaciones(cliente_id);
CREATE INDEX idx_reclamos_cliente ON reclamos(cliente_id);
CREATE INDEX idx_devoluciones_cliente ON devoluciones(cliente_id);

-- Restricciones no triviales (pago completo, cupon valido, stock al
-- vender, titular de devolucion) siguen siendo responsabilidad
-- de la capa de servicios: es exactamente lo que practicaras.

COMMIT;
