const db = require('../conexion');

exports.routesConfig = function(app) {
    app.get('/compras', (req, res) => {
        db.getAll('compra', (data) => {
            res.send({ "compras": data });
        });
    });
};