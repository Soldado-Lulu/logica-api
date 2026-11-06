import { Cliente } from './clientes.model.js';

const camposPublicos = ['id', 'nombres', 'apellidos', 'correo', 'celular', 'tipo_cliente', 'activo', 'creado_en'];

export async function consultarClientes() {
  return Cliente.findAll({ attributes: camposPublicos, order: [['id', 'ASC']], raw: true });
}

export async function consultarClientePorId(id) {
  return Cliente.findByPk(id, { attributes: camposPublicos, raw: true });
}

export async function insertarCliente(datos) {
  const cliente = await Cliente.create(datos);
  return cliente.get({ plain: true });
}

export async function modificarCliente(id, datos) {
  const cliente = await Cliente.findByPk(id);
  if (!cliente) return null;
  await cliente.update(datos);
  return cliente.get({ plain: true });
}

export async function eliminarCliente(id) {
  // Devuelve 0 cuando no existe. Restricciones FK de PostgreSQL siguen vigentes.
  return Cliente.destroy({ where: { id } });
}
