const db = require('../conexion');

exports.routesConfig = function(app) {
    app.get('/roles', (req, res) => {
        db.getAll('rol', (data) => {
            res.send({ "roles": data });
        });
    });
};