import { pool } from '../../config/database.js';

export async function consultarClientes() {
  const sql = `
    SELECT id, nombres, apellidos, correo, celular, tipo_cliente, activo, creado_en
    FROM clientes
    ORDER BY id ASC
  `;
  const resultado = await pool.query(sql);
  return resultado.rows;
}
