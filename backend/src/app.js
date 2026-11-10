
import express from 'express';

import { sequelize } from './config/database.js';

import clientesRoutes from './modules/clientes/clientes.routes.js';
import productosRoutes from './modules/productos/productos.routes.js';

import { manejarErrores } from './middlewares/error.middleware.js';

const app = express();

// Middleware para recibir JSON
app.use(express.json());

// Verificar estado de la API y PostgreSQL
app.get('/api/health', async (req, res) => {
  try {
    await sequelize.authenticate();

    return res.status(200).json({
      ok: true,
      api: 'logica-api',
      database: 'conectada',
    });
  } catch (error) {
    console.error('Healthcheck:', error);

    return res.status(503).json({
      ok: false,
      database: 'no disponible',
    });
  }
});

// Rutas de los módulos
app.use('/api/clientes', clientesRoutes);
app.use('/api/productos', productosRoutes);

app.use((req, res) => {
  return res.status(404).json({
    ok: false,
    mensaje: 'Ruta no encontrada',
  });
});

// Middleware global de errores
app.use(manejarErrores);

export default app;
