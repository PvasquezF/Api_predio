const db = require('../conexion');

exports.routesConfig = function(app) {
    app.get('/', (req, res) => {
        res.send(`Lista de endpoints disponibles\n/roles\n/usuarios`);
    });
};