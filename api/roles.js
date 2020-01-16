const db = require('../conexion');

exports.routesConfig = function(app) {
    app.get('/roles', (req, res) => {
        db.getAll('rol', (data) => {
            res.send({ "roles": data });
        });
    });

    app.post('/nuevoRol', (req, res) => {
        if (req.body['nombre'] == undefined) {
            res.send({ error: "No existen los campos necesarios para hacer la insercion." });
        } else {
            fields = 'nombre';
            datos = `'${req.body['nombre']}'`;
            db.insert('rol', fields, datos, (data) => {
                if (data.codResultado != undefined && data.codResultado == 0) {
                    res.send({ resultado: "Se ha agregado un nuevo rol." });
                } else {
                    res.send({ resultado: "Ha ocurrido un error al tratar de agregar el nuevo rol." });
                }
            });
        }
    });
};