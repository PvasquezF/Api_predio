const express = require('express');
const app = express();
const index = require('./api/index');
const roles = require('./api/roles');
const usuarios = require('./api/usuarios');
const vehiculos = require('./api/vehiculos');
const estados = require('./api/estados');
const compras = require('./api/compras');
const port = 3000;

index.routesConfig(app);
roles.routesConfig(app);
usuarios.routesConfig(app);
vehiculos.routesConfig(app);
estados.routesConfig(app);
compras.routesConfig(app);

app.listen(port, () => {
    console.log(`Running on http://localhost:${port}`);
});