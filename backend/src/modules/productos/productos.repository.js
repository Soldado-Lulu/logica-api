import { pool } from '../../config/database.js';

export async function consultarProductos() {
  const sql = `
    SELECT p.id, p.sku, p.nombre, p.precio, p.stock, p.stock_minimo,
           p.activo, c.id AS categoria_id, c.nombre AS categoria
    FROM productos p
    JOIN categorias c ON c.id = p.categoria_id
    ORDER BY p.id
  `;
  const resultado = await pool.query(sql);
  return resultado.rows;
}
