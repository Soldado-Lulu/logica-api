import { Sequelize } from 'sequelize';
import { env } from './env.js';

// Una instancia compartida y un pool de conexiones administrado por Sequelize.
export const sequelize = new Sequelize(env.dbName, env.dbUser, env.dbPassword, {
  host: env.dbHost,
  port: env.dbPort,
  dialect: 'postgres',
  logging: false, // Cambia a console.log para ver el SQL generado.
  pool: { max: 10, min: 0, acquire: 5000, idle: 10000 },
});

export async function verificarConexion() {
  await sequelize.authenticate();
  console.log('PostgreSQL conectado mediante Sequelize');
}
