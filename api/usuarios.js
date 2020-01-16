const db = require('../conexion');

exports.routesConfig = function(app) {
    app.get('/usuarios', (req, res) => {
        db.getAll('usuario', (data) => {
            res.send({ "usuarios": data });
        });
    });

    app.post('/registrar', (req, res) => {
        if (req.body['cui'] == undefined ||
            req.body['nombre'] == undefined ||
            req.body['apellido'] == undefined ||
            req.body['id_rol'] == undefined) {
            res.send({ error: "No existen los campos necesarios para hacer la insercion." });
        } else {
            datos = `${ req.body['cui']}, '${ req.body['nombre']}', '${ req.body['apellido']}', '${ req.body['id_rol']}'`;
            query = `select nuevousuario(${datos}) as resultado;`
            db.doQuery(query, (data) => {
                if (data[0].resultado == 1) {
                    res.send({ "respuesta": "Se ha registrado un nuevo usuario." })
                } else {
                    res.send({ "respuesta": "No se ha podido registrar un nuevo usuario." })
                }
            });
        }
    });

    app.post('/rolUsuario', (req, res) => {
        if (req.body['cui'] == undefined || req.body['id_rol'] == undefined) {
            res.send({ error: "No existen los campos necesarios para hacer la insercion." });
        } else {
            fields = 'cui, id_rol';
            datos = `${req.body['cui']}, ${req.body['id_rol']}`;
            db.insert('rol_usuario', fields, datos, (data) => {
                if (data.codResultado != undefined && data.codResultado == 0) {
                    res.send({ resultado: "Se ha agregado un nuevo rol al usuario." });
                } else {
                    res.send({ resultado: "Ha ocurrido un error al tratar de agregar un nuevo rol." });
                }
            });
        }
    });

    app.get('/estadisticasAdmin', (req, res) => {
        db.doQuery('call totalusuarioscompradores();', (data) => {
            db.doQuery('call totalusuariosvendedores();', (data1) => {
                db.doQuery('call usuarioscompradores();', (data2) => {
                    db.doQuery('call usuariosvendedores();', (data3) => {
                        db.doQuery('call totalvehiculosdisponibles();', (data4) => {
                            db.doQuery('call totalingresos();', (data5) => {
                                res.send({
                                    "TotalCompradores": data[0][0].Total_compradores,
                                    "TotalVendedores": data1[0][0].Total_vendedores,
                                    "TotalVehiculosDisponibles": data4[0][0].total_vehiculos,
                                    "TotalIngresos": data5[0][0].ingresosTotales,
                                    "UsuariosCompradores": data2[0],
                                    "UsuariosVendedores": data3[0],
                                });
                            });
                        });
                    });
                });
            });
        });
    });

    app.get('/estadisticasComprador/:cui', (req, res) => {
        db.doQuery(`call cantidadvehiculoscomprados(${req.params.cui});`, (data) => {
            db.doQuery(`call gastosenvehiculos(${req.params.cui});`, (data1) => {
                res.send({
                    "CantidadVehiculosComprados": data[0][0].vehiculos_comprados,
                    "CantidadGastada": data1[0][0].gastos
                });
            });
        });
    });

    app.get('/estadisticasVendedor/:cui', (req, res) => {
        db.doQuery(`call cantidadvehiculosvendidos(${req.params.cui});`, (data) => {
            db.doQuery(`call gananciasenvehiculos(${req.params.cui});`, (data1) => {
                res.send({
                    "CantidadVehiculosVendidos": data[0][0].vehiculos_vendidos,
                    "CantidadGanada": data1[0][0].ganancias
                });
            });
        });
    });

}