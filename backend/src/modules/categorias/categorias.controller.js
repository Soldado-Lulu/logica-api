
import {
  listarCategoriasService,
  obtenerCategoriaService,
  crearCategoriaService,
  actualizarCategoriaService,
  eliminarCategoriaService,
  buscarCategoriaPorNombreService
} from './categorias.service.js';

// GET /api/categorias
export async function listarCategorias(req, res) {
  const categorias = await listarCategoriasService();

  return res.status(200).json({
    ok: true,
    total: categorias.length,
    data: categorias,
  });
}

// GET /api/categorias/:id
export async function obtenerCategoria(req, res) {
  const { id } = req.params;

  const categoria = await obtenerCategoriaService(id);

  if (!categoria) {
    return res.status(404).json({
      ok: false,
      mensaje: 'Categoría no encontrada',
    });
  }

  return res.status(200).json({
    ok: true,
    data: categoria,
  });
}

// POST /api/categorias
export async function crearCategoria(req, res) {
  const categoria = await crearCategoriaService(req.body);

  return res.status(201).json({
    ok: true,
    mensaje: 'Categoría creada correctamente',
    data: categoria,
  });
}

// PATCH /api/categorias/:id
export async function actualizarCategoria(req, res) {
  const { id } = req.params;
  const datos = req.body;

  const categoria = await actualizarCategoriaService(id, datos);

  if (!categoria) {
    return res.status(404).json({
      ok: false,
      mensaje: 'Categoría no encontrada',
    });
  }

  return res.status(200).json({
    ok: true,
    mensaje: 'Categoría actualizada correctamente',
    data: categoria,
  });
}

// DELETE /api/categorias/:id
export async function borrarCategoria(req, res) {
  const { id } = req.params;

  const afectados = await eliminarCategoriaService(id);

  if (afectados === 0) {
    return res.status(404).json({
      ok: false,
      mensaje: 'Categoría no encontrada',
    });
  }

  return res.status(200).json({
    ok: true,
    mensaje: 'Categoría eliminada correctamente',
  });
}
