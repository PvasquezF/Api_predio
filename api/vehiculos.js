const db = require('../conexion');

exports.routesConfig = function(app) {
    app.get('/vehiculos', (req, res) => {
        db.getAll('vehiculo', (data) => {
            res.send({ "vehiculos": data });
        });
    });
};