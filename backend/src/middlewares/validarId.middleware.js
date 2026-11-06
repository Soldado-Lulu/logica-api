export function validarId(req, res, next) {
  const { id } = req.params;

  const idNumero = Number(id);

  if (
    !/^[1-9]\d*$/.test(id) ||
    !Number.isSafeInteger(idNumero)
  ) {
    return res.status(400).json({
      ok: false,
      mensaje: 'El ID debe ser un entero positivo válido'
    });
  }

  next();
}