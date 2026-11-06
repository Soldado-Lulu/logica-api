import { Producto } from './productos.model.js';
import { Categoria } from '../categorias/categorias.model.js';

export async function consultarProductos() {
  const productos = await Producto.findAll({
    attributes: ['id', 'sku', 'nombre', 'precio', 'stock', 'stock_minimo', 'activo'],
    include: [{ model: Categoria, as: 'categoriaDetalle', attributes: ['id', 'nombre'], required: true }],
    order: [['id', 'ASC']],
  });
  // Mantenemos el mismo JSON plano que entregaba el JOIN original.
  return productos.map(producto => {
    const p = producto.get({ plain: true });
    return { id: p.id, sku: p.sku, nombre: p.nombre, precio: p.precio,
      stock: p.stock, stock_minimo: p.stock_minimo, activo: p.activo,
      categoria_id: p.categoriaDetalle.id, categoria: p.categoriaDetalle.nombre };
  });
}
