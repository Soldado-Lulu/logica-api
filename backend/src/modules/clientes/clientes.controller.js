
import {
  listarClientesService,
  obtenerClienteService,
  crearClienteService,
  actualizarClienteService,
  eliminarClienteService,
} from './clientes.service.js';

// GET /api/clientes
export async function listarClientes(req, res) {
  const clientes = await listarClientesService();

  return res.status(200).json({
    ok: true,
    total: clientes.length,
    data: clientes,
  });
}

// GET /api/clientes/:id
export async function obtenerCliente(req, res) {
  const { id } = req.params;

  const cliente = await obtenerClienteService(id);

  if (!cliente) {
    return res.status(404).json({
      ok: false,
      mensaje: 'Cliente no encontrado',
    });
  }

  return res.status(200).json({
    ok: true,
    data: cliente,
  });
}

// POST /api/clientes
export async function crearCliente(req, res) {
  const cliente = await crearClienteService(req.body);

  return res.status(201).json({
    ok: true,
    mensaje: 'Cliente creado correctamente',
    data: cliente,
  });
}

// PATCH /api/clientes/:id
export async function actualizarCliente(req, res) {
  const { id } = req.params;
  const datos = req.body;

  const cliente = await actualizarClienteService(id, datos);

  if (!cliente) {
    return res.status(404).json({
      ok: false,
      mensaje: 'Cliente no encontrado',
    });
  }

  return res.status(200).json({
    ok: true,
    mensaje: 'Cliente actualizado correctamente',
    data: cliente,
  });
}

// DELETE /api/clientes/:id
export async function borrarCliente(req, res) {
  const { id } = req.params;

  const afectados = await eliminarClienteService(id);

  if (afectados === 0) {
    return res.status(404).json({
      ok: false,
      mensaje: 'Cliente no encontrado',
    });
  }

  return res.status(200).json({
    ok: true,
    mensaje: 'Cliente eliminado correctamente',
  });
}
