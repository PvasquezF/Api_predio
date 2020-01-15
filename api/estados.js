const db = require('../conexion');

exports.routesConfig = function(app) {
    app.get('/estados', (req, res) => {
        db.getAll('estado', (data) => {
            res.send({ "estados": data });
        });
    });
};