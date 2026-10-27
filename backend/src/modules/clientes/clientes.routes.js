import { Router } from 'express';
import { listarClientes } from './clientes.controller.js';

const router = Router();

router.get('/', listarClientes);
// RETOS PARA TI:
// router.get('/:id', obtenerClientePorId);
// router.post('/', crearCliente);
// router.patch('/:id', actualizarCliente);

export default router;
