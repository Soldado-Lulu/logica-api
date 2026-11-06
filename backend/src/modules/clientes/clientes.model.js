import { DataTypes } from 'sequelize';
import { sequelize } from '../../config/database.js';

// Mapeo de la tabla YA existente en docker/init/01_esquema.sql.
export const Cliente = sequelize.define('Cliente', {
  id: { type: DataTypes.BIGINT, primaryKey: true, autoIncrement: true },
  nombres: { type: DataTypes.STRING(100), allowNull: false },
  apellidos: { type: DataTypes.STRING(100), allowNull: false },
  correo: { type: DataTypes.STRING(180), allowNull: false, unique: true, validate: { isEmail: true } },
  celular: { type: DataTypes.STRING(25), allowNull: true },
  tipo_cliente: { type: DataTypes.STRING(10), allowNull: false, defaultValue: 'REGULAR', validate: { isIn: [['REGULAR', 'VIP']] } },
  activo: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
  creado_en: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
}, {
  tableName: 'clientes',
  timestamps: false,
});
