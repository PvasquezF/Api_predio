const db = require('../conexion');

exports.routesConfig = function(app) {
    app.get('/', (req, res) => {
        res.send(`Para ver los endpoint consultar readme`);
    });
};