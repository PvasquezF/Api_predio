const db = require('../conexion');

exports.routesConfig = function(app) {
    app.get('/estados', (req, res) => {
        db.getAll('estado', (data) => {
            res.send({ "estados": data });
        });
    });

    app.post('/nuevoEstado', (req, res) => {
        if (req.body['nombre'] == undefined) {
            res.send({ error: "No existen los campos necesarios para hacer la insercion." });
        } else {
            fields = 'nombre';
            datos = `'${req.body['nombre']}'`;
            db.insert('estado', fields, datos, (data) => {
                if (data.codResultado != undefined && data.codResultado == 0) {
                    res.send({ resultado: "Se ha agregado un nuevo estado." });
                } else {
                    res.send({ resultado: "Ha ocurrido un error al tratar de agregar el nuevo estado." });
                }
            });
        }
    });
};