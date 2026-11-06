import {
  consultarClientes, consultarClientePorId, insertarCliente,
  modificarCliente, eliminarCliente,
} from './clientes.repository.js';

const camposEditables = ['nombres', 'apellidos', 'correo', 'celular', 'tipo_cliente', 'activo'];

function seleccionarCampos(datos) {
  return Object.fromEntries(Object.entries(datos ?? {}).filter(([clave]) => camposEditables.includes(clave)));
}

export async function listarClientesService() {
  return consultarClientes();
}
export async function obtenerClienteService(id) {
  return consultarClientePorId(id);
}
export async function crearClienteService(datos) {
  return insertarCliente(seleccionarCampos(datos));
}
export async function actualizarClienteService(id, datos) {
  return modificarCliente(id, seleccionarCampos(datos));
}
export async function eliminarClienteService(id) {
  return eliminarCliente(id);
}
