import { consultarProductos } from './productos.repository.js';

export async function listarProductosService() {
  return await consultarProductos();
}
