import {Categoria} from './categorias.model.js';

const camposPublicos = ['id', 'nombre', 'descripcion', 'activo', 'creado_en'];

export async function consultarCategorias() {
  return Categoria.findAll({ attributes: camposPublicos, order: [['id', 'ASC']], raw: true });
}

export async function consultarCategoriaPorId(id) {
  return Categoria.findByPk(id, { attributes: camposPublicos, raw: true });
}
export async function insertarCategoria(datos) {
  const categoria = await Categoria.create(datos);
  return categoria.get({ plain: true });
}

export async function modificarCategoria(id, datos) {
  const categoria = await Categoria.findByPk(id);
  if (!categoria) return null;
  await categoria.update(datos);
  return categoria.get({ plain: true });
}

export async function eliminarCategoria(id) {
  const categoria = await Categoria.findByPk(id);
  if (!categoria) return null;
  await categoria.destroy();
  return { message: 'Categoría eliminada correctamente' };
}

export async function consultarCategoriaPorNombre(nombre) {
  const categoria = await Categoria.findOne({
    where: {
      nombre: nombre
    },
    raw: true
  });
  return categoria;
}   
