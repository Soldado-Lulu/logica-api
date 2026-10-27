import dotenv from 'dotenv';
import { fileURLToPath } from 'node:url';

// Backend local: usa el .env de la raiz del proyecto.
// En Docker Compose: las variables ya vienen inyectadas por env_file/environment.
dotenv.config({ path: fileURLToPath(new URL('../../../.env', import.meta.url)) });

export const env = {
  port: Number(process.env.PORT || 3000),
  dbHost: process.env.DB_HOST || 'localhost',
  dbPort: Number(process.env.DB_PORT || 5435),
  dbName: process.env.DB_NAME || 'logica_api',
  dbUser: process.env.DB_USER || 'logica_user',
  dbPassword: process.env.DB_PASSWORD,
};

if (!env.dbPassword) {
  throw new Error('Falta DB_PASSWORD. Copia .env.example como .env en la raiz.');
}
