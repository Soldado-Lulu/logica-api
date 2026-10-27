import pg from 'pg';
import { env } from './env.js';

const { Pool } = pg;

// Pool reutiliza conexiones. NO crees una conexion nueva en cada endpoint.
export const pool = new Pool({
  host: env.dbHost,
  port: env.dbPort,
  database: env.dbName,
  user: env.dbUser,
  password: env.dbPassword,
  max: 10,
  connectionTimeoutMillis: 5000,
});

export async function verificarConexion() {
  const resultado = await pool.query('SELECT NOW() AS fecha_servidor');
  console.log('PostgreSQL conectado:', resultado.rows[0].fecha_servidor);
}
