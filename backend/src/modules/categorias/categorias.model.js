import { DataTypes } from 'sequelize';
import { sequelize } from '../../config/database.js';

export const Categoria = sequelize.define('Categoria', {
  id: { type: DataTypes.BIGINT, primaryKey: true, autoIncrement: true },
  nombre: { type: DataTypes.STRING(100), allowNull: false, unique: true },
  descripcion: { type: DataTypes.TEXT },
  activa: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
}, { tableName: 'categorias', timestamps: false });
