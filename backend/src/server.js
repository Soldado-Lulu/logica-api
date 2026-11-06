import app from './app.js';
import { env } from './config/env.js';
import { sequelize, verificarConexion } from './config/database.js';

async function iniciarServidor() {
  try {
    await verificarConexion();
    // NO usar sequelize.sync({ force: true }): tablas y seeders ya existen en Docker.
    const server = app.listen(env.port, '0.0.0.0', () => {
      console.log(`API lista en http://localhost:${env.port}`);
    });
    for (const signal of ['SIGINT', 'SIGTERM']) {
      process.once(signal, () => {
        server.close(async () => {
          await sequelize.close();
          process.exit(0);
        });
      });
    }
  } catch (error) {
    console.error('No se pudo iniciar la API:', error.message);
    await sequelize.close();
    process.exit(1);
  }
}
iniciarServidor();
