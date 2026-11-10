
import {
  consultarClientes,
  consultarClientePorId,
  insertarCliente,
  modificarCliente,
  eliminarCliente,
  consultarClientePorCorreo,
} from './clientes.repository.js';

import  AppError  from '../../utils/AppError.js';

// Campos que el sistema permite modificar
const CAMPOS_EDITABLES = new Set([
  'nombres',
  'apellidos',
  'correo',
  'celular',
  'tipo_cliente',
  'activo',
]);

// Filtrar los campos recibidos
function seleccionarCamposPermitidos(datos) {
  const campos = Object.entries(datos ?? {});

  const camposFiltrados = campos.filter(([clave]) =>
    CAMPOS_EDITABLES.has(clave)
  );

  return Object.fromEntries(camposFiltrados);
}

// Obtener todos los clientes
export function listarClientesService() {
  return consultarClientes();
}

// Obtener un cliente por ID
export function obtenerClienteService(id) {
  return consultarClientePorId(id);
}

// Crear un nuevo cliente
export function crearClienteService(datos) {
  const datosPermitidos = seleccionarCamposPermitidos(datos);

  if (Object.keys(datosPermitidos).length === 0) {
    throw new AppError('Debe enviar datos válidos del cliente', 400);
  }
  
  const {correo} = datosPermitidos;
  const clienteExistente = consultarClientePorCorreo(correo);
  
  if (clienteExistente) {
    throw new AppError('Ya existe un cliente con ese correo', 400);
  }
  return insertarCliente(datosPermitidos);
}

// Actualizar un cliente
export function actualizarClienteService(id, datos) {
  const datosPermitidos = seleccionarCamposPermitidos(datos);

  if (Object.keys(datosPermitidos).length === 0) {
    throw new AppError('No se enviaron campos para actualizar', 400);
  }

  return modificarCliente(id, datosPermitidos);
}

// Eliminar un cliente
export function eliminarClienteService(id) {
  return eliminarCliente(id);
}

export function buscarClientePorCorreoService(correo) {
  const cliente = buscarClientePorCorreo(correo);

  return buscarClientePorCorreo(correo);
}