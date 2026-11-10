export default function asyncHandler(funcion) {
  return (req, res, next) => {
    Promise.resolve()
      .then(() => funcion(req, res, next))
      .catch(next);
  };
}