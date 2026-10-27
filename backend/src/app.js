import express from 'express';
import { pool } from './config/database.js';
import clientesRoutes from './modules/clientes/clientes.routes.js';
import productosRoutes from './modules/productos/productos.routes.js';

const app = express();
app.use(express.json());

// Comprueba tambien la base de datos: HTTP 200 solo si responde PostgreSQL.
app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ ok: true, api: 'logica-api', database: 'conectada' });
  } catch (error) {
    console.error('Healthcheck:', error);
    res.status(503).json({ ok: false, database: 'no disponible' });
  }
});

app.use('/api/clientes', clientesRoutes);
app.use('/api/productos', productosRoutes);

app.use((req, res) => {
  res.status(404).json({ ok: false, mensaje: 'Ruta no encontrada' });
});

export default app;
