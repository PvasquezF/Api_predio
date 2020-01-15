const mysql = require('mysql');

let conn = mysql.createConnection({
    user: 'root',
    password: '12345',
    server: 'localhost',
    database: 'predio'
});

exports.doQuery = (query, callback) => {
    conn.query(query, function(err, result) {
        if (err) {
            callback({
                'Descripcion': "Ha ocurrido un error al obtener la informacion",
                'codResultado': -1
            });
        } else {
            callback(result);
        }
    });
};

exports.getAll = (tableName, callback) => {
    conn.query("Select * from " + tableName + ";", function(err, result) {
        if (err) {
            callback({
                'Descripcion': "Ha ocurrido un error al obtener la informacion",
                'codResultado': -1
            });
        } else {
            callback(result);
        }
    });
};