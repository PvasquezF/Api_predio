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
            callback(err);
        } else {
            callback(result);
        }
    });
};

exports.getAll = (tableName, callback) => {
    conn.query("Select * from " + tableName + ";", function(err, result) {
        if (err) {
            callback(err);
        } else {
            callback(result);
        }
    });
};

exports.getByField = (tableName, field, value, callback) => {
    query = `Select * from ${tableName} where ${field} = ${value};`;
    conn.query(query, function(err, result) {
        if (err) {
            callback(err);
        } else {
            callback(result);
        }
    });
};

exports.insert = (tableName, fields, data, callback) => {
    query = "INSERT INTO " + tableName + " (" + fields + ") VALUES(" + data + ");";
    conn.query(query, function(err, result) {
        if (err) {
            callback(err);
        } else {
            res = result.affectedRows == 1 ? { resultado: "Se ha insertado un nuevo registro.", codResultado: 0 } : { resultado: "No se ha podido insertar.", codResultado: -1 };
            callback(res);
        }
    });
};