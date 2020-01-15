const db = require('../conexion');

exports.routesConfig = function(app) {
    app.get('/usuarios', (req, res) => {
        db.getAll('usuario', (data) => {
            res.send({ "usuarios": data });
        });
    });
};