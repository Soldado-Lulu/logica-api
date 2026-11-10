
import { Router } from 'express';

import {
  listarCategorias,
  obtenerCategoria,
  crearCategoria,
  actualizarCategoria,
  borrarCategoria,
} from './categorias.controller.js';

import asyncHandler from '../../middlewares/asyncHandler.js';

import { validarId } from '../../middlewares/validarId.middleware.js';

const router = Router();

// GET - Listar categorias
router.get('/', asyncHandler(listarCategorias));

// GET - Obtener categoria por ID
router.get('/:id', validarId, asyncHandler(obtenerCategoria));

// POST - Crear categoria
router.post('/', asyncHandler(crearCategoria));

// PATCH - Actualizar categoria
router.patch('/:id', validarId, asyncHandler(actualizarCategoria));

// DELETE - Eliminar categoria
router.delete('/:id', validarId, asyncHandler(borrarCategoria));

export default router;
