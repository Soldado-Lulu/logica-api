import { consultarClientes } from './clientes.repository.js';

export async function listarClientesService() {
  // En un GET sencillo no se requiere mucha logica.
  // Luego practicaras filtros: req.query.activo, req.query.tipo, etc.
  const clientes = await consultarClientes();
  return clientes;
}
