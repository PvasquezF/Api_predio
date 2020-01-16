const db = require('../conexion');

exports.routesConfig = function(app) {
    app.get('/vehiculos', (req, res) => {
        db.getAll('vehiculo', (data) => {
            res.send({ "vehiculos": data });
        });
    });

    app.get('/vehiculosVendedor/:cui', (req, res) => {
        query = `call vehiculosvendedor(${req.params.cui});`
        db.doQuery(query, (data) => {
            res.send(data[0]);
        });
    });

    app.get('/vehiculosComprador/:cui', (req, res) => {
        query = `call vehiculoscomprador(${req.params.cui});`
        db.doQuery(query, (data) => {
            res.send(data[0]);
        });
    });

    app.get('/vehiculosAdministrador/:cui', (req, res) => {
        query = `call vehiculosadministrador(${req.params.cui});`
        db.doQuery(query, (data) => {
            res.send(data[0]);
        });
    });

    app.get('/tienda', (req, res) => {
        query = `call gettienda();`
        db.doQuery(query, (data) => {
            res.send(data[0]);
        });
    });

    app.post('/nuevoVehiculo', (req, res) => {
        if (req.body['cui'] == undefined ||
            req.body['placa'] == undefined ||
            req.body['modelo'] == undefined ||
            req.body['marca'] == undefined ||
            req.body['año'] == undefined ||
            req.body['color'] == undefined ||
            req.body['precio'] == undefined ||
            req.body['id_estado'] == undefined) {
            res.send({ error: "No existen los campos necesarios para hacer la insercion." });
        } else {
            datos = `${ req.body['cui']}, '${ req.body['placa']}', '${ req.body['modelo']}', '${ req.body['marca']}', '${ req.body['año']}', '${ req.body['color']}', ${ req.body['precio']}, ${ req.body['id_estado']}`;
            query = `select nuevovehiculo(${datos}) as resultado;`
            db.doQuery(query, (data) => {
                if (data[0].resultado == 1) {
                    res.send({ "respuesta": "Se ha registrado un nuevo vehiculo." })
                } else {
                    res.send({ "respuesta": "No se ha podido registrar un nuevo vehiculo." })
                }
            });
        }
    });
};