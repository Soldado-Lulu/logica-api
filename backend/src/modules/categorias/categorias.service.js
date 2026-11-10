import {
    consultarCategorias,
    consultarCategoriaPorId,
    consultarCategoriaPorNombre,
    insertarCategoria,
    modificarCategoria,
    eliminarCategoria} from 'categorias.repository.js'; 

import { AppError } from '../../utils/AppError.js';

const CAMPOS_EDITABLES = new Set([
    'nombre',
    'descripcion',
    'activo'
]);

function seleccionarCamposPermitidos(datos) {
  const campos = Object.entries(datos ?? {});

  const camposFiltrados = campos.filter(([clave]) =>
    CAMPOS_EDITABLES.has(clave)
  );

  return Object.fromEntries(camposFiltrados);
}


export function listarCategoriasService() {
  return consultarCategorias();
}

export function obtenerCategoriaService(id) {
  return consultarCategoriaPorId(id);
}

  export function crearCategoriaService(datos) {
    const datosPermitidos = seleccionarCamposPermitidos(datos);
  
    if (Object.keys(datosPermitidos).length === 0) {
      throw new AppError('Debe enviar datos válidos de la categoría', 400);
    }
    
    const {nombre} = datosPermitidos;
    const categoriaExistente = consultarCategoriaPorNombre(nombre);
    
    if (categoriaExistente) {
      throw new AppError('Ya existe una categoría con ese nombre', 400);
    }
    return insertarCategoria(datosPermitidos);
  }

  export function actualizarCategoriaService(id, datos) {
    const datosPermitidos = seleccionarCamposPermitidos(datos);
  
    if (Object.keys(datosPermitidos).length === 0) {
      throw new AppError('No se enviaron campos para actualizar', 400);
    }
  
    return modificarCategoria(id, datosPermitidos);
  }
  
  // Eliminar una categoría
  export function eliminarCategoriaService(id) {
    return eliminarCategoria(id);
  }
  
  export function buscarCategoriaPorNombreService(nombre) {
    const categoria = buscarCategoriaPorNombre(nombre);
  
    return buscarCategoriaPorNombre(nombre);
  }