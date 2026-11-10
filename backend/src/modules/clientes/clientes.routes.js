
import { Router } from 'express';

import {
  listarClientes,
  obtenerCliente,
  crearCliente,
  actualizarCliente,
  borrarCliente,
} from './clientes.controller.js';

import asyncHandler from '../../middlewares/asyncHandler.js';

import { validarId } from '../../middlewares/validarId.middleware.js';

const router = Router();

// GET - Listar clientes
router.get('/', asyncHandler(listarClientes));

// GET - Obtener cliente por ID
router.get('/:id', validarId, asyncHandler(obtenerCliente));

// POST - Crear cliente
router.post('/', asyncHandler(crearCliente));

// PATCH - Actualizar cliente
router.patch('/:id', validarId, asyncHandler(actualizarCliente));

// DELETE - Eliminar cliente
router.delete('/:id', validarId, asyncHandler(borrarCliente));

export default router;
