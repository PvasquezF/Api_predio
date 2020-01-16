const db = require('../conexion');

exports.routesConfig = function(app) {
    app.get('/compras', (req, res) => {
        db.getAll('compra', (data) => {
            res.send({ "compras": data });
        });
    });

    app.post('/comprar', (req, res) => {
        if (req.body['cui'] == undefined || req.body['placa'] == undefined || req.body['precio_final'] == undefined) {
            res.send({ error: "No existen los campos necesarios para hacer la insercion." });
        } else {
            fields = 'cui, placa, precio_final';
            datos = `${req.body['cui']}, '${req.body['placa']}', ${req.body['precio_final']}`;
            query = `select nuevacompra(${datos}) as resultado;`
            db.doQuery(query, (data) => {
                if (data[0].resultado == 1) {
                    res.send({ "respuesta": "Se ha registrado una nueva compra." })
                } else {
                    res.send({ "respuesta": "No se ha podido realizar la compra." })
                }
            });
        }
    });
};