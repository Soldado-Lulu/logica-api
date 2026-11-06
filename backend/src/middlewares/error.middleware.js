export function manejarErrores(error, req, res, next) {
  console.error('Error:', error);

  if (error.statusCode) {
    return res.status(error.statusCode).json({
      ok: false,
      mensaje: error.message
    });
  }

  if (error.name === 'SequelizeUniqueConstraintError') {
    return res.status(409).json({
      ok: false,
      mensaje: 'El registro ya existe'
    });
  }

  if (error.name === 'SequelizeValidationError') {
    return res.status(400).json({
      ok: false,
      mensaje: 'Datos inválidos'
    });
  }

  if (error.name === 'SequelizeForeignKeyConstraintError') {
    return res.status(409).json({
      ok: false,
      mensaje: 'El registro tiene relaciones que impiden la operación'
    });
  }

  return res.status(500).json({
    ok: false,
    mensaje: 'Error interno del servidor'
  });
}