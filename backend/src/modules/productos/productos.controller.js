import { listarProductosService } from './productos.service.js';

export async function listarProductos(req, res) {
  try {
    const productos = await listarProductosService();
    return res.status(200).json({ ok: true, total: productos.length, data: productos });
  } catch (error) {
    console.error('Error al listar productos:', error);
    return res.status(500).json({ ok: false, mensaje: 'Error al listar productos' });
  }
}
