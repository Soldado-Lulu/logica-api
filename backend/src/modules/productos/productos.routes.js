import { Router } from 'express';
import { listarProductos } from './productos.controller.js';

const router = Router();

router.get('/', listarProductos);
// RETOS PARA TI (ordena las rutas fijas ANTES de /:id):
// router.get('/stock-bajo', listarStockBajo);
// router.get('/:id', obtenerProductoPorId);
// router.post('/', crearProducto);

export default router;
