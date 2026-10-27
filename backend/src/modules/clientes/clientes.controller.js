import { listarClientesService } from './clientes.service.js';

export async function listarClientes(req, res) {
  try {
    const clientes = await listarClientesService();
    return res.status(200).json({ ok: true, total: clientes.length, data: clientes });
  } catch (error) {
    console.error('Error al listar clientes:', error);
    return res.status(500).json({ ok: false, mensaje: 'Error al listar clientes' });
  }
}
