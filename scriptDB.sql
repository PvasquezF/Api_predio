create schema predio collate utf8mb4_general_ci;
use predio;
create table estado
(
	id_estado int auto_increment primary key,
	nombre varchar(50) not null
);

create table rol
(
	id_rol int auto_increment primary key,
	nombre varchar(150) not null
);

create table usuario
(
	cui bigint not null primary key,
	nombre varchar(150) not null,
	apellido varchar(150) not null
);

create table rol_usuario
(
	cui bigint not null,
	id_rol int not null,
	primary key (cui, id_rol),
	constraint rol_usuario_ibfk_1
		foreign key (cui) references usuario (cui)
			on update cascade on delete cascade,
	constraint rol_usuario_ibfk_2
		foreign key (id_rol) references rol (id_rol)
			on update cascade on delete cascade
);

create table vehiculo
(
	placa varchar(10) not null primary key,
	modelo varchar(50) not null,
	marca varchar(50) not null,
	año date not null,
	color varchar(50) not null,
	precio decimal not null
);

create table compra
(
	cui bigint not null,
	placa varchar(10) not null,
	precio_final decimal not null,
	fecha_compra date null DEFAULT sysdate(),
	primary key (cui, placa),
	constraint compra_ibfk_1
		foreign key (placa) references vehiculo (placa)
			on update cascade on delete cascade,
	constraint compra_ibfk_2
		foreign key (cui) references usuario (cui)
			on update cascade on delete cascade
);

create table estado_vehiculo
(
	placa varchar(10) not null,
	id_estado int not null,
	primary key (placa, id_estado),
	constraint estado_vehiculo_ibfk_1
		foreign key (placa) references vehiculo (placa)
			on update cascade on delete cascade,
	constraint estado_vehiculo_ibfk_2
		foreign key (id_estado) references estado (id_estado)
			on update cascade on delete cascade
);

create table usuario_vehiculo
(
	cui bigint not null,
	placa varchar(10) not null,
	primary key (cui, placa),
	constraint usuario_vehiculo_ibfk_1
		foreign key (placa) references vehiculo (placa)
			on update cascade on delete cascade,
	constraint usuario_vehiculo_ibfk_2
		foreign key (cui) references usuario (cui)
			on update cascade on delete cascade
);

create procedure cantidadvehiculoscomprados(IN _cui bigint)
begin
    SELECT count(*) as vehiculos_comprados
    FROM USUARIO u
        INNER JOIN COMPRA c
            ON u.cui = c.cui
        INNER JOIN VEHICULO v
            ON v.placa = c.placa
    WHERE u.cui = _cui;
end;

create procedure cantidadvehiculosvendidos(IN _cui bigint)
begin
    SELECT count(*) as vehiculos_vendidos
    FROM VEHICULO u
        INNER JOIN COMPRA c
            ON u.placa = c.placa
        INNER JOIN USUARIO_VEHICULO uv
            ON uv.placa = u.placa
    WHERE uv.cui = _cui;
end;

create procedure gananciasenvehiculos(IN _cui bigint)
begin
    SELECT ifnull(sum(c.precio_final), 0) as ganancias
    FROM VEHICULO u
        INNER JOIN COMPRA c
            ON u.placa = c.placa
        INNER JOIN USUARIO_VEHICULO uv
            ON uv.placa = u.placa
    WHERE uv.cui = _cui;
end;

create procedure gastosenvehiculos(IN _cui bigint)
begin
    SELECT ifnull(sum(c.precio_final),0) as gastos
    FROM USUARIO u
        INNER JOIN COMPRA c
            ON u.cui = c.cui
        INNER JOIN VEHICULO v
            ON v.placa = c.placa
    WHERE u.cui = _cui;
end;

create procedure gettienda()
begin
    SELECT v.placa, v.marca, v.modelo, v.año, v.color, e.nombre as estado, u.cui as cui_vendedor, u.nombre as nombre_vendedor
    FROM USUARIO u
        INNER JOIN USUARIO_VEHICULO uv
            ON u.cui = uv.cui
        INNER JOIN VEHICULO v
            ON v.placa = uv.placa
        INNER JOIN ESTADO_VEHICULO ev
            ON v.placa = ev.placa
        INNER JOIN ESTADO e
            ON ev.id_estado = e.id_estado
    WHERE e.nombre = 'En venta';
end;

create function nuevacompra(_cui bigint, _placa varchar(10), _precio_final decimal) returns int
begin
    select count(*) into @existeUsuario from USUARIO where USUARIO.cui = _cui;
    select count(*) into @existePlaca from VEHICULO where VEHICULO.placa = _placa;
    select count(*) into @esComprador from ROL_USUARIO ru, ROL r where r.nombre = 'Comprador' and ru.cui = _cui and r.id_rol = ru.id_rol;
    select count(*) into @estaDisponible from ESTADO e, ESTADO_VEHICULO ev where ev.placa = _placa and e.nombre = 'En venta' and e.id_estado = ev.id_estado;
    if (@existeUsuario = 1 AND @existePlaca = 1 AND @esComprador = 1 AND @estaDisponible) then
        INSERT INTO COMPRA(cui, placa, precio_final) VALUES (_cui, _placa, _precio_final);
        UPDATE ESTADO_VEHICULO
        SET id_estado = (SELECT id_estado FROM ESTADO WHERE nombre = 'Vendido')
        WHERE placa = _placa;
        return 1;
    ELSE
        return 0;
    end if;
end;

create function nuevousuario(_cui bigint, _nombre varchar(10), _apellido varchar(50), _rol varchar(50)) returns int
begin
    select count(*) into @existeUsuario from USUARIO where USUARIO.cui = _cui;
    select count(*) into @existeRol from ROL where ROL.id_rol = _rol;
    if (@existeRol = 1 AND @existeUsuario = 0) then
        INSERT INTO USUARIO(cui, nombre, apellido) VALUES (_cui, _nombre, _apellido);
        INSERT INTO ROL_USUARIO(cui, id_rol) VALUES (_cui, _rol);
        return 1;
    ELSE
        return 0;
    end if;
end;

create function nuevovehiculo(_cui bigint, _placa varchar(10), _modelo varchar(50), _marca varchar(50), _año date, _color varchar(50), _precio decimal, _estado int) returns int
begin
    select count(*) into @existePlaca from VEHICULO where VEHICULO.placa = _placa;
    select count(*) into @existeEstado from ESTADO where ESTADO.id_estado = _estado;
    select count(*) into @existeUsuario from USUARIO where USUARIO.cui = _estado;
    if (@existePlaca = 0 AND @existeEstado = 1 AND @existeUsuario = 1) then
        INSERT INTO VEHICULO(placa, modelo, marca, año, color, precio) VALUES (_placa, _modelo, _marca, _año, _color, _precio);
        INSERT INTO ESTADO_VEHICULO(placa, id_estado) VALUES (_placa, _estado);
        INSERT INTO USUARIO_VEHICULO(cui, placa) VALUES (_cui, _placa);
        return 1;
    ELSE
        return 0;
    end if;
end;

create procedure totalingresos()
begin
    SELECT SUM(c.precio_final) as ingresosTotales
    FROM COMPRA c;
end;

create procedure totalusuarioscompradores()
begin
    SELECT count(*) as Total_compradores
    FROM USUARIO u
        INNER JOIN ROL_USUARIO ru
        ON u.cui = ru.cui
        INNER JOIN ROL r
        ON r.id_rol = ru.id_rol
    WHERE r.nombre = 'Comprador';
end;

create procedure totalusuariosvendedores()
begin
    SELECT count(*) as Total_vendedores
    FROM USUARIO u
        INNER JOIN ROL_USUARIO ru
        ON u.cui = ru.cui
        INNER JOIN ROL r
        ON r.id_rol = ru.id_rol
    WHERE r.nombre = 'Vendedor';
end;

create procedure totalvehiculosdisponibles()
begin
    SELECT count(*) as total_vehiculos
    FROM USUARIO u
        INNER JOIN USUARIO_VEHICULO uv
            ON u.cui = uv.cui
        INNER JOIN VEHICULO v
            ON v.placa = uv.placa
        INNER JOIN ESTADO_VEHICULO ev
            ON v.placa = ev.placa
        INNER JOIN ESTADO e
            ON ev.id_estado = e.id_estado
    WHERE e.nombre = 'En venta';
end;

create procedure usuarioscompradores()
begin
    SELECT u.cui, u.nombre, u.apellido, r.nombre as rol
    FROM USUARIO u
        INNER JOIN ROL_USUARIO ru
        ON u.cui = ru.cui
        INNER JOIN ROL r
        ON r.id_rol = ru.id_rol
    WHERE r.nombre = 'Comprador';
end;

create procedure usuariosvendedores()
begin
    SELECT u.cui, u.nombre, u.apellido, r.nombre as rol
    FROM USUARIO u
        INNER JOIN ROL_USUARIO ru
        ON u.cui = ru.cui
        INNER JOIN ROL r
        ON r.id_rol = ru.id_rol
    WHERE r.nombre = 'Vendedor';
end;

create procedure vehiculosadministrador(IN _cui bigint)
begin
    select count(*) into @existeUsuario from USUARIO where USUARIO.cui = _cui;
    select count(*) into @esAdministrador from ROL_USUARIO ru, ROL r where r.nombre = 'Administrador' and ru.cui = _cui and r.id_rol = ru.id_rol;
    if (@existeUsuario = 1 AND @esAdministrador = 1 ) then
        SELECT v.placa, v.marca, v.modelo, v.año, v.color, e.nombre as estado, u.cui as cui_vendedor, u.nombre as nombre_vendedor, us.cui as cui_comprador, us.nombre as nombre_comprador
        FROM USUARIO u
            INNER JOIN USUARIO_VEHICULO uv
                ON u.cui = uv.cui
            INNER JOIN VEHICULO v
                ON v.placa = uv.placa
            INNER JOIN ESTADO_VEHICULO ev
                ON v.placa = ev.placa
            INNER JOIN ESTADO e
                ON ev.id_estado = e.id_estado
            LEFT JOIN COMPRA c
                ON v.placa = c.placa
            LEFT JOIN USUARIO us
                ON us.cui = c.cui;
    ELSE
        SELECT 'No se han podido obtener los datos.' as error from dual;
    end if;
end;

create procedure vehiculoscomprador(IN _cui bigint)
begin
    select count(*) into @existeUsuario from USUARIO where USUARIO.cui = _cui;
    select count(*) into @esComprador from ROL_USUARIO ru, ROL r where r.nombre = 'Comprador' and ru.cui = _cui and r.id_rol = ru.id_rol;
    if (@existeUsuario = 1 AND @esComprador = 1 ) then
        SELECT v.placa, v.marca, v.modelo, v.año, v.color
        FROM USUARIO u
            INNER JOIN COMPRA c
                ON u.cui = c.cui
            INNER JOIN VEHICULO v
                ON v.placa = c.placa
        WHERE u.cui = _cui;
    ELSE
        SELECT 'No se han podido obtener los datos.' as error from dual;
    end if;
end;

create procedure vehiculosvendedor(IN _cui bigint)
begin
    select count(*) into @existeUsuario from USUARIO where USUARIO.cui = _cui;
    select count(*) into @esComprador from ROL_USUARIO ru, ROL r where r.nombre = 'Vendedor' and ru.cui = _cui and r.id_rol = ru.id_rol;
    if (@existeUsuario = 1 AND @esComprador = 1 ) then
        SELECT v.placa, v.marca, v.modelo, v.año, v.color, e.nombre as estado
        FROM USUARIO u
            INNER JOIN USUARIO_VEHICULO uv
                ON u.cui = uv.cui
            INNER JOIN VEHICULO v
                ON v.placa = uv.placa
            INNER JOIN ESTADO_VEHICULO ev
                ON v.placa = ev.placa
            INNER JOIN ESTADO e
                ON ev.id_estado = e.id_estado
        WHERE u.cui = _cui;
    ELSE
        SELECT 'No se han podido obtener los datos.' as error from dual;
    end if;
end;


INSERT INTO predio.usuario (cui, nombre, apellido) VALUES (11111, 'usuario1', 'usuario1');
INSERT INTO predio.usuario (cui, nombre, apellido) VALUES (22222, 'usuario2', 'usuario2');
INSERT INTO predio.usuario (cui, nombre, apellido) VALUES (33333, 'usuario3', 'usuario3');
INSERT INTO predio.usuario (cui, nombre, apellido) VALUES (44444, 'usuario4', 'usuario4');
INSERT INTO predio.usuario (cui, nombre, apellido) VALUES (55555, 'admin', 'admin');
INSERT INTO predio.usuario (cui, nombre, apellido) VALUES (3020399370101, 'pavel', 'vasquez');

INSERT INTO predio.rol (id_rol, nombre) VALUES (1, 'Administrador');
INSERT INTO predio.rol (id_rol, nombre) VALUES (2, 'Comprador');
INSERT INTO predio.rol (id_rol, nombre) VALUES (3, 'Vendedor');

INSERT INTO predio.estado (id_estado, nombre) VALUES (1, 'Vendido');
INSERT INTO predio.estado (id_estado, nombre) VALUES (2, 'En venta');
INSERT INTO predio.estado (id_estado, nombre) VALUES (3, 'No disponible actualmente');

INSERT INTO predio.rol_usuario (cui, id_rol) VALUES (11111, 3);
INSERT INTO predio.rol_usuario (cui, id_rol) VALUES (22222, 3);
INSERT INTO predio.rol_usuario (cui, id_rol) VALUES (33333, 3);
INSERT INTO predio.rol_usuario (cui, id_rol) VALUES (44444, 3);
INSERT INTO predio.rol_usuario (cui, id_rol) VALUES (3020399370101, 3);
INSERT INTO predio.rol_usuario (cui, id_rol) VALUES (55555, 1);
INSERT INTO predio.rol_usuario (cui, id_rol) VALUES (11111, 2);
INSERT INTO predio.rol_usuario (cui, id_rol) VALUES (3020399370101, 2);

INSERT INTO predio.vehiculo (placa, modelo, marca, año, color, precio) VALUES ('111-aaa', 'A1', 'Audi', '2009-01-01', 'verde', 190000);
INSERT INTO predio.vehiculo (placa, modelo, marca, año, color, precio) VALUES ('111-ccc', 'A2', 'Audi', '2019-01-01', 'azul', 390000);
INSERT INTO predio.vehiculo (placa, modelo, marca, año, color, precio) VALUES ('111-ddd', 'A3', 'Audi', '2017-01-01', 'negro', 290000);
INSERT INTO predio.vehiculo (placa, modelo, marca, año, color, precio) VALUES ('111-eee', 'A4', 'Audi', '2013-01-01', 'amarillo', 90000);
INSERT INTO predio.vehiculo (placa, modelo, marca, año, color, precio) VALUES ('111-fff', 'A5', 'Audi', '2015-01-01', 'rojo', 120000);
INSERT INTO predio.vehiculo (placa, modelo, marca, año, color, precio) VALUES ('111-ggg', 'A6', 'Audi', '2014-01-01', 'rojo', 150000);
INSERT INTO predio.vehiculo (placa, modelo, marca, año, color, precio) VALUES ('111-hhh', 'A8', 'Audi', '2023-01-01', 'rojo', 550000);
INSERT INTO predio.vehiculo (placa, modelo, marca, año, color, precio) VALUES ('111-iii', 'A9', 'Audi', '2020-01-01', 'rojo', 450000);

INSERT INTO predio.estado_vehiculo (placa, id_estado) VALUES ('111-aaa', 2);
INSERT INTO predio.estado_vehiculo (placa, id_estado) VALUES ('111-ccc', 1);
INSERT INTO predio.estado_vehiculo (placa, id_estado) VALUES ('111-ddd', 1);
INSERT INTO predio.estado_vehiculo (placa, id_estado) VALUES ('111-eee', 2);
INSERT INTO predio.estado_vehiculo (placa, id_estado) VALUES ('111-fff', 1);
INSERT INTO predio.estado_vehiculo (placa, id_estado) VALUES ('111-ggg', 1);
INSERT INTO predio.estado_vehiculo (placa, id_estado) VALUES ('111-hhh', 1);
INSERT INTO predio.estado_vehiculo (placa, id_estado) VALUES ('111-iii', 2);

INSERT INTO predio.usuario_vehiculo (cui, placa) VALUES (11111, '111-ccc');
INSERT INTO predio.usuario_vehiculo (cui, placa) VALUES (11111, '111-ddd');
INSERT INTO predio.usuario_vehiculo (cui, placa) VALUES (22222, '111-eee');
INSERT INTO predio.usuario_vehiculo (cui, placa) VALUES (33333, '111-fff');
INSERT INTO predio.usuario_vehiculo (cui, placa) VALUES (44444, '111-ggg');
INSERT INTO predio.usuario_vehiculo (cui, placa) VALUES (44444, '111-hhh');
INSERT INTO predio.usuario_vehiculo (cui, placa) VALUES (44444, '111-iii');
INSERT INTO predio.usuario_vehiculo (cui, placa) VALUES (3020399370101, '111-aaa');

INSERT INTO predio.compra (cui, placa, precio_final, fecha_compra) VALUES (11111, '111-ggg', 2200000, '2020-01-16');
INSERT INTO predio.compra (cui, placa, precio_final, fecha_compra) VALUES (11111, '111-hhh', 50000, '2020-01-16');
INSERT INTO predio.compra (cui, placa, precio_final, fecha_compra) VALUES (3020399370101, '111-ccc', 150000, '2020-01-16');
INSERT INTO predio.compra (cui, placa, precio_final, fecha_compra) VALUES (3020399370101, '111-ddd', 50000, '2020-01-16');
INSERT INTO predio.compra (cui, placa, precio_final, fecha_compra) VALUES (3020399370101, '111-fff', 250000, '2020-01-16');