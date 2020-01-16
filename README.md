# Api_predio

### Instalacion
```
npm install
```
Ademas correr el script para la base de datos en mysql.

### Lista Endpoints

#### ROLES

| ENDPOINT | METODO | DESCRIPCION |
| -------- | ------ | ----------- |
| /roles   |   GET  | Muestra todos los roles |
| /nuevoRol| POST   | Agrega un nuevo rol |
```
{
    "nombre":"rol1"
}
```
##### Roles disponibles
| Id | Nombre |
|----| ------ |
| 1 | Administrador
| 2 | Comprador
| 3 | Vendedor

#### USUARIOS
| ENDPOINT | METODO | DESCRIPCION |
| -------- | ------ | ----------- |
| /usuarios   |   GET  | Muestra todos los usuarios |
| /registrar| POST   | Registra un nuevo usuario |
```
{
	"cui":66666,
	"nombre":"admin2",
	"apellido":"admin2",
	"id_rol":1
}
```
| ENDPOINT | METODO | DESCRIPCION |
| -------- | ------ | ----------- |
| /rolUsuario| POST   | Relaciona el usuario y el rol |
```
{
    "cui":55555,
    "id_rol":2
}
```

| ENDPOINT | METODO | DESCRIPCION |
| -------- | ------ | ----------- |
|/estadisticasAdmin | GET | Retorna las estadisticas para los admin
|/estadisticasComprador/cui | GET | Retorna las estadisticas del comprador
|/estadisticasVendedor/cui | GET | Retorna las estadisticas del vendedor


#### ESTADOS
| ENDPOINT | METODO | DESCRIPCION |
| -------- | ------ | ----------- |
|/estados | GET | Muestra todos los estados
|/nuevoEstado | POST | Agrega un nuevo estado
```
{
    "nombre":"Nombre del nuevo estado"
}
```

##### Estados disponibles
| Id | Nombre |
|----| ------ |
|1 | Vendido
|2 | En venta
|3 | No disponible actualmente

#### VEHICULOS
| ENDPOINT | METODO | DESCRIPCION |
| -------- | ------ | ----------- |
|/vehiculos | GET | Muestra todos los vehiculos
|/vehiculosVendedor/:cui | GET | Muestra todos los vehiculos del vendedor
|/vehiculosComprador/:cui | GET | Muestra todos los vehiculos del comprador
|/vehiculosAdministrador/:cui | GET | Muestra todos los vehiculos
|/tienda | GET | Muestra los vehiculos disponibles
|/nuevoVehiculo | POST | Registra un nuevo vehiculo
```
{
	"cui":44444,
	"placa":"111-iii",
	"modelo":"A9",
	"marca":"Audi",
	"año":"2020-01-01",
	"color":"rojo",
	"precio":450000,
	"id_estado":2
}
```

#### COMPRAS
| ENDPOINT | METODO | DESCRIPCION |
| -------- | ------ | ----------- |
|/compras | GET | Muestra todas las compras realizadas
|/comprar | POST | Registra una nueva compra
```
{
	"cui":11111,
	"placa":"111-hhh",
	"precio_final":50000
}
```