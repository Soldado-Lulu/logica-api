import { DataTypes } from 'sequelize';
import { sequelize } from '../../config/database.js';
import { Categoria } from '../categorias/categorias.model.js';

export const Producto = sequelize.define('Producto', {
  id: { type: DataTypes.BIGINT, primaryKey: true, autoIncrement: true },
  categoria_id: { type: DataTypes.BIGINT, allowNull: false },
  sku: { type: DataTypes.STRING(40), allowNull: false, unique: true },
  nombre: { type: DataTypes.STRING(150), allowNull: false },
  precio: { type: DataTypes.DECIMAL(12, 2), allowNull: false },
  stock: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
  stock_minimo: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 5 },
  activo: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
  creado_en: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
}, { tableName: 'productos', timestamps: false });

Producto.belongsTo(Categoria, { foreignKey: 'categoria_id', as: 'categoriaDetalle' });
Categoria.hasMany(Producto, { foreignKey: 'categoria_id', as: 'productos' });
