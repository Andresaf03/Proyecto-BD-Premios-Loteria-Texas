DROP SCHEMA IF EXISTS normal CASCADE;
CREATE SCHEMA IF NOT EXISTS normal;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Creando la pais y llendandola
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS normal.pais CASCADE;
CREATE TABLE IF NOT EXISTS normal.pais(
    id BIGSERIAL PRIMARY KEY,
    nombre_pais VARCHAR(100)
);

INSERT INTO normal.pais (nombre_pais)
SELECT DISTINCT(pais_jugador)
FROM limpieza_datos.loteria
ORDER BY pais_jugador;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Creando la tabla ciudad y llendandola
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS normal.ciudad CASCADE;
CREATE TABLE IF NOT EXISTS normal.ciudad(
    id BIGSERIAL PRIMARY KEY,
    nombre_ciudad VARCHAR(100)
);

INSERT INTO normal.ciudad (nombre_ciudad)
SELECT DISTINCT(ciudad_jugador) AS nombre_ciudad
FROM limpieza_datos.loteria
UNION
SELECT DISTINCT(ciudad_comerciante) AS nombre_ciudad
FROM limpieza_datos.loteria
ORDER BY nombre_ciudad;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Creando la tabla estado y llendandola
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS normal.estado CASCADE;
CREATE TABLE IF NOT EXISTS normal.estado(
    id BIGSERIAL PRIMARY KEY,
    nombre_estado VARCHAR(100)
);

INSERT INTO normal.estado (nombre_estado)
SELECT DISTINCT(estado_comerciante) AS nombre_estado
FROM limpieza_datos.loteria
UNION
SELECT DISTINCT(estado_jugador) AS nombre_estado
FROM limpieza_datos.loteria
ORDER BY nombre_estado;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Creando la tabla condado y llendandola
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS normal.condado CASCADE;
CREATE TABLE IF NOT EXISTS normal.condado(
    id BIGSERIAL PRIMARY KEY,
    nombre_condado VARCHAR(100)
);

INSERT INTO normal.condado (nombre_condado)
SELECT DISTINCT(condado_jugador) AS nombre_condado
FROM limpieza_datos.loteria
UNION
SELECT DISTINCT(condado_comerciante) AS nombre_condado
FROM limpieza_datos.loteria
ORDER BY nombre_condado;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Creando la tabla centro de reclamo y llendandola
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS normal.centro_reclamo CASCADE;
CREATE TABLE IF NOT EXISTS normal.centro_reclamo(
    id BIGSERIAL PRIMARY KEY,
    nombre_centro_reclamo VARCHAR(254)
);

INSERT INTO normal.centro_reclamo (nombre_centro_reclamo)
SELECT DISTINCT(ubicacion_centro_reclamo)
FROM limpieza_datos.loteria;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Creando la tabla zip y llendandola
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS normal.zip CASCADE;
CREATE TABLE IF NOT EXISTS normal.zip(
    id BIGSERIAL PRIMARY KEY,
    zip BIGINT
);

INSERT INTO normal.zip (zip)
SELECT DISTINCT(CAST(codigo_zip_comerciante AS BIGINT))
FROM limpieza_datos.loteria;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Creando la tabla zip4 y llendandola
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS normal.zip4 CASCADE;
CREATE TABLE IF NOT EXISTS normal.zip4(
    id BIGSERIAL PRIMARY KEY,
    zip4 BIGINT
);

INSERT INTO normal.zip4 (zip4)
SELECT DISTINCT(CAST(codigo_zip4_comerciante AS BIGINT))
FROM limpieza_datos.loteria;


/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Creando la tabla jugador y llendandola
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS normal.jugador_temp;
CREATE TABLE IF NOT EXISTS normal.jugador_temp(
    id1 BIGSERIAL PRIMARY KEY,
    jugador_nombre VARCHAR(100),
    jugador_apellido VARCHAR(100),
    ciudadano_usa VARCHAR(30),
    ciudad_jugador_id VARCHAR(254),
    estado_jugador_id VARCHAR(254),
    condado_jugador_id VARCHAR(254),
    pais_jugador_id VARCHAR(254)
);

INSERT INTO normal.jugador_temp (id1,
                            jugador_nombre,
                            jugador_apellido,
                            ciudadano_usa,
                            ciudad_jugador_id,
                            estado_jugador_id,
                            condado_jugador_id,
                            pais_jugador_id)
SELECT DISTINCT(id_jugador),
       jugador_nombre,
       jugador_apellido,
       ciudadano_usa,
       ciudad_jugador,
       estado_jugador,
       condado_jugador,
       pais_jugador
FROM limpieza_datos.loteria
ORDER BY id_jugador;

-- Agregamos un id más amigable para sustituirlo
ALTER TABLE normal.jugador_temp
ADD COLUMN id BIGSERIAl;

ALTER TABLE normal.jugador_temp DROP COLUMN id1;

-- Organizamos la tabla
DROP TABLE IF EXISTS normal.jugador;
CREATE TABLE IF NOT EXISTS normal.jugador(
    id BIGSERIAL PRIMARY KEY,
    jugador_nombre VARCHAR(100),
    jugador_apellido VARCHAR(100),
    ciudadano_usa VARCHAR(30),
    ciudad_jugador_id VARCHAR(254),
    estado_jugador_id VARCHAR(254),
    condado_jugador_id VARCHAR(254),
    pais_jugador_id VARCHAR(254)
);

INSERT INTO normal.jugador (id,
                            jugador_nombre,
                            jugador_apellido,
                            ciudadano_usa,
                            ciudad_jugador_id,
                            estado_jugador_id,
                            condado_jugador_id,
                            pais_jugador_id)
SELECT id,
        jugador_nombre,
        jugador_apellido,
        ciudadano_usa,
        ciudad_jugador_id,
        estado_jugador_id,
        condado_jugador_id,
        pais_jugador_id
FROM normal.jugador_temp
ORDER BY id;
DROP TABLE IF EXISTS normal.jugador_temp CASCADE;

-- Agregamos las foreign keys
UPDATE normal.jugador
    SET ciudad_jugador_id = (SELECT id FROM normal.ciudad WHERE normal.ciudad.nombre_ciudad = normal.jugador.ciudad_jugador_id);
ALTER TABLE normal.jugador ALTER COLUMN ciudad_jugador_id TYPE BIGINT USING CAST(ciudad_jugador_id AS BIGINT);
ALTER TABLE normal.jugador ADD FOREIGN KEY (ciudad_jugador_id) REFERENCES normal.ciudad(id);

UPDATE normal.jugador
    SET estado_jugador_id = (SELECT id FROM normal.estado WHERE normal.estado.nombre_estado = normal.jugador.estado_jugador_id);
ALTER TABLE normal.jugador ALTER COLUMN estado_jugador_id TYPE BIGINT USING CAST(estado_jugador_id AS BIGINT);
ALTER TABLE normal.jugador ADD FOREIGN KEY (estado_jugador_id) REFERENCES normal.estado(id);

UPDATE normal.jugador
    SET condado_jugador_id = (SELECT id FROM normal.condado WHERE normal.condado.nombre_condado = normal.jugador.condado_jugador_id);
ALTER TABLE normal.jugador ALTER COLUMN condado_jugador_id TYPE BIGINT USING CAST(condado_jugador_id AS BIGINT);
ALTER TABLE normal.jugador ADD FOREIGN KEY (condado_jugador_id) REFERENCES normal.condado(id);

UPDATE normal.jugador
    SET pais_jugador_id = (SELECT id FROM normal.pais WHERE normal.pais.nombre_pais = normal.jugador.pais_jugador_id);
ALTER TABLE normal.jugador ALTER COLUMN pais_jugador_id TYPE BIGINT USING CAST(pais_jugador_id AS BIGINT);
ALTER TABLE normal.jugador ADD FOREIGN KEY (pais_jugador_id) REFERENCES normal.pais(id);


/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Creando la tabla comerciante y llendandola
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS normal.comerciante_temp CASCADE;
CREATE TABLE IF NOT EXISTS normal.comerciante_temp(
    id1 BIGSERIAL PRIMARY KEY ,
    nombre_comerciante VARCHAR(100),
    direccion VARCHAR(254),
    direccion_interior VARCHAR(254),
    ciudad_comerciante_id TEXT,
    estado_comerciante_id TEXT,
    condado_comerciante_id TEXT,
    zip_id TEXT,
    zip4_id TEXT
);

INSERT INTO normal.comerciante_temp (id1,
                                nombre_comerciante,
                                direccion,
                                direccion_interior,
                                ciudad_comerciante_id,
                                estado_comerciante_id,
                                condado_comerciante_id,
                                zip_id,
                                zip4_id)
SELECT DISTINCT(numero_comerciante),
       nombre_comerciante,
       direccion1_comerciante,
       direccion2_comerciante,
       ciudad_comerciante,
       estado_comerciante,
       condado_comerciante,
       codigo_zip_comerciante,
       codigo_zip4_comerciante
FROM limpieza_datos.loteria
ORDER BY numero_comerciante;

-- Agregamos un id más amigable para sustituirlo
ALTER TABLE normal.comerciante_temp
ADD COLUMN id BIGSERIAl;

ALTER TABLE normal.comerciante_temp DROP COLUMN id1;

--Organizamos la tabla
DROP TABLE IF EXISTS normal.comerciante_ CASCADE;
CREATE TABLE IF NOT EXISTS normal.comerciante_ (
    id BIGSERIAL PRIMARY KEY ,
    nombre_comerciante VARCHAR(100),
    direccion VARCHAR(254),
    direccion_interior VARCHAR(254),
    ciudad_comerciante_id TEXT,
    estado_comerciante_id TEXT,
    condado_comerciante_id TEXT,
    zip_id BIGINT,
    zip4_id BIGINT
);

INSERT INTO normal.comerciante_ (id,
                                nombre_comerciante,
                                direccion,
                                direccion_interior,
                                ciudad_comerciante_id,
                                estado_comerciante_id,
                                condado_comerciante_id,
                                zip_id,
                                zip4_id)
SELECT id,
        nombre_comerciante,
        direccion,
        direccion_interior,
        ciudad_comerciante_id,
        estado_comerciante_id,
        condado_comerciante_id,
        CAST(zip_id AS BIGINT),
        CAST(zip4_id AS BIGINT)
FROM normal.comerciante_temp
ORDER BY id;

DROP TABLE IF EXISTS normal.comerciante_temp;

--Agregamos las foreign keys
UPDATE normal.comerciante_
    SET ciudad_comerciante_id = (SELECT id FROM normal.ciudad WHERE normal.ciudad.nombre_ciudad = normal.comerciante_.ciudad_comerciante_id);
ALTER TABLE normal.comerciante_ ALTER COLUMN ciudad_comerciante_id TYPE BIGINT USING CAST(ciudad_comerciante_id AS BIGINT);
ALTER TABLE normal.comerciante_ ADD FOREIGN KEY (ciudad_comerciante_id) REFERENCES normal.ciudad(id);

UPDATE normal.comerciante_
    SET estado_comerciante_id = (SELECT id FROM normal.estado WHERE normal.estado.nombre_estado = normal.comerciante_.estado_comerciante_id);
ALTER TABLE normal.comerciante_ ALTER COLUMN estado_comerciante_id TYPE BIGINT USING CAST(estado_comerciante_id AS BIGINT);
ALTER TABLE normal.comerciante_ ADD FOREIGN KEY (estado_comerciante_id) REFERENCES normal.estado(id);

UPDATE normal.comerciante_
    SET condado_comerciante_id = (SELECT id FROM normal.condado WHERE normal.condado.nombre_condado = normal.comerciante_.condado_comerciante_id);
ALTER TABLE normal.comerciante_ ALTER COLUMN condado_comerciante_id TYPE BIGINT USING CAST(condado_comerciante_id AS BIGINT);
ALTER TABLE normal.comerciante_ ADD FOREIGN KEY (condado_comerciante_id) REFERENCES normal.condado(id);

UPDATE normal.comerciante_
    SET zip_id = (SELECT id FROM normal.zip WHERE normal.zip.zip = normal.comerciante_.zip_id);
ALTER TABLE normal.comerciante_ ADD FOREIGN KEY (zip_id) REFERENCES normal.zip(id);
UPDATE normal.comerciante_
    SET zip_id = 15
    WHERE zip_id IS NULL;

UPDATE normal.comerciante_
    SET zip4_id = (SELECT id FROM normal.zip4 WHERE normal.zip4.zip4 = normal.comerciante_.zip4_id);
ALTER TABLE normal.comerciante_ ADD FOREIGN KEY (zip4_id) REFERENCES normal.zip4(id);
UPDATE normal.comerciante_
    SET zip4_id = 4
    WHERE zip4_id IS NULL;

-- Para que los id aparecan en orden
DROP TABLE IF EXISTS normal.comerciante CASCADE;
CREATE TABLE IF NOT EXISTS normal.comerciante AS
SELECT *
FROM normal.comerciante_
ORDER BY id;
DROP TABLE IF EXISTS normal.comerciante_ CASCADE;
ALTER TABLE normal.comerciante ADD PRIMARY KEY (id);
ALTER TABLE normal.comerciante ADD FOREIGN KEY (ciudad_comerciante_id) REFERENCES normal.ciudad(id);
ALTER TABLE normal.comerciante ADD FOREIGN KEY (estado_comerciante_id) REFERENCES normal.estado(id);
ALTER TABLE normal.comerciante ADD FOREIGN KEY (condado_comerciante_id) REFERENCES normal.condado(id);
ALTER TABLE normal.comerciante ADD FOREIGN KEY (zip_id) REFERENCES normal.zip(id);
ALTER TABLE normal.comerciante ADD FOREIGN KEY (zip4_id) REFERENCES normal.zip4(id);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Creando la tabla reclamo y llendandola
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS normal.reclamo_temp CASCADE;
CREATE TABLE IF NOT EXISTS normal.reclamo_temp(
    id1 BIGSERIAL PRIMARY KEY,
    tipo_reclamo VARCHAR(100),
    fecha_pagado DATE,
    anualidad BOOLEAN,
    anonimo BOOLEAN,
    jugador_id BIGINT,
    comerciante_id BIGINT,
    centro_id VARCHAR(254)
);

INSERT INTO normal.reclamo_temp (id1,
                            tipo_reclamo,
                            fecha_pagado,
                            anualidad,
                            anonimo,
                            jugador_id,
                            comerciante_id,
                            centro_id)
SELECT DISTINCT(numero_reclamo),
       tipo_reclamo,
       fecha_reclamo_pagado,
       indicador_anualidad,
       indicador_anonimo,
       id_jugador,
       numero_comerciante,
       ubicacion_centro_reclamo
FROM limpieza_datos.loteria
ORDER BY numero_reclamo;

--Agregamos un id más amigable
ALTER TABLE normal.reclamo_temp ADD COLUMN id BIGSERIAL;

ALTER TABLE normal.reclamo_temp DROP COLUMN id1;

-- Organizamos la tabla
DROP TABLE IF EXISTS normal.reclamo_;
CREATE TABLE IF NOT EXISTS normal.reclamo_(
    id BIGSERIAL PRIMARY KEY,
    tipo_reclamo VARCHAR(100),
    fecha_pagado DATE,
    anualidad BOOLEAN,
    anonimo BOOLEAN,
    jugador_id BIGINT,
    comerciante_id BIGINT,
    centro_id VARCHAR(254)
);

INSERT INTO normal.reclamo_ (id,
                            tipo_reclamo,
                            fecha_pagado,
                            anualidad,
                            anonimo,
                            jugador_id,
                            comerciante_id,
                            centro_id)
SELECT id,
        tipo_reclamo,
        fecha_pagado,
        anualidad,
        anonimo,
        jugador_id,
        comerciante_id,
        centro_id
FROM normal.reclamo_temp
ORDER BY id;

DROP TABLE IF EXISTS normal.reclamo_temp CASCADE;

--Agregamos (actualizamos) las foreign keys
UPDATE normal.reclamo_
SET centro_id = (SELECT id FROM normal.centro_reclamo WHERE normal.centro_reclamo.nombre_centro_reclamo = normal.reclamo_.centro_id);
ALTER TABLE normal.reclamo_ ALTER COLUMN centro_id TYPE BIGINT USING CAST(centro_id AS BIGINT);
ALTER TABLE normal.reclamo_ ADD FOREIGN KEY (centro_id) REFERENCES normal.centro_reclamo(id);

--NO ESTA limpia jugador_id ni comerciante id
-- Creamos tabla temporal para actualizar el foreign id de jugador
DROP TABLE IF EXISTS normal.jugador_temp;
CREATE TABLE IF NOT EXISTS normal.jugador_temp(
    id1 BIGSERIAL PRIMARY KEY,
    jugador_nombre VARCHAR(100),
    jugador_apellido VARCHAR(100),
    ciudadano_usa VARCHAR(30),
    ciudad_jugador_id VARCHAR(254),
    estado_jugador_id VARCHAR(254),
    condado_jugador_id VARCHAR(254),
    pais_jugador_id VARCHAR(254)
);

INSERT INTO normal.jugador_temp (id1,
                            jugador_nombre,
                            jugador_apellido,
                            ciudadano_usa,
                            ciudad_jugador_id,
                            estado_jugador_id,
                            condado_jugador_id,
                            pais_jugador_id)
SELECT DISTINCT(id_jugador),
       jugador_nombre,
       jugador_apellido,
       ciudadano_usa,
       ciudad_jugador,
       estado_jugador,
       condado_jugador,
       pais_jugador
FROM limpieza_datos.loteria
ORDER BY id_jugador;

-- Agregamos un id más amigable para sustituirlo
ALTER TABLE normal.jugador_temp
ADD COLUMN id BIGSERIAl;

UPDATE normal.reclamo_
    SET jugador_id = (SELECT id FROM normal.jugador_temp WHERE normal.reclamo_.jugador_id = normal.jugador_temp.id1);
ALTER TABLE normal.reclamo_ ADD FOREIGN KEY (jugador_id) REFERENCES normal.jugador(id);
DROP TABLE IF EXISTS normal.jugador_temp CASCADE;

-- Agregamos el foreign key para comerciante
DROP TABLE IF EXISTS normal.comerciante_temp CASCADE;
CREATE TABLE IF NOT EXISTS normal.comerciante_temp(
    id1 BIGSERIAL PRIMARY KEY ,
    nombre_comerciante VARCHAR(100),
    direccion VARCHAR(254),
    direccion_interior VARCHAR(254),
    ciudad_comerciante_id TEXT,
    estado_comerciante_id TEXT,
    condado_comerciante_id TEXT,
    zip_id TEXT,
    zip4_id TEXT
);

INSERT INTO normal.comerciante_temp (id1,
                                nombre_comerciante,
                                direccion,
                                direccion_interior,
                                ciudad_comerciante_id,
                                estado_comerciante_id,
                                condado_comerciante_id,
                                zip_id,
                                zip4_id)
SELECT DISTINCT(numero_comerciante),
       nombre_comerciante,
       direccion1_comerciante,
       direccion2_comerciante,
       ciudad_comerciante,
       estado_comerciante,
       condado_comerciante,
       codigo_zip_comerciante,
       codigo_zip4_comerciante
FROM limpieza_datos.loteria
ORDER BY numero_comerciante;

-- Agregamos un id más amigable para sustituirlo
ALTER TABLE normal.comerciante_temp
ADD COLUMN id BIGSERIAl;

UPDATE normal.reclamo_
    SET comerciante_id = (SELECT id FROM normal.comerciante_temp WHERE normal.reclamo_.comerciante_id = normal.comerciante_temp.id1);
ALTER TABLE normal.reclamo_ ADD FOREIGN KEY (comerciante_id) REFERENCES normal.comerciante(id);
DROP TABLE IF EXISTS normal.comerciante_temp CASCADE;


-- Para que los ids aparezcan en orden
DROP TABLE IF EXISTS normal.reclamo CASCADE;
CREATE TABLE IF NOT EXISTS normal.reclamo AS
SELECT *
FROM normal.reclamo_
ORDER BY normal.reclamo_.id;
ALTER TABLE normal.reclamo ADD PRIMARY KEY (id);
ALTER TABLE normal.reclamo ADD FOREIGN KEY (jugador_id) REFERENCES normal.jugador(id);
ALTER TABLE normal.reclamo ADD FOREIGN KEY (comerciante_id) REFERENCES normal.comerciante(id);
ALTER TABLE normal.reclamo ADD FOREIGN KEY (centro_id) REFERENCES normal.centro_reclamo(id);
DROP TABLE IF EXISTS normal.reclamo_;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Creando la tabla premio y llendandola
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS normal.premio_ CASCADE;
CREATE TABLE IF NOT EXISTS normal.premio_(
    premio_id BIGSERIAL PRIMARY KEY,
    cantidad_ganada DECIMAL(20,2),
    especie_dinero VARCHAR(100),
    nivel_premio VARCHAR(100),
    tipo_loteria VARCHAR(100),
    fecha_draw DATE,
    momento_dia_draw VARCHAR(100),
    numero_ticket BIGINT,
    costo_ticket DECIMAL(10,2),
    fecha_venta_ticket DATE,
    jugador_id BIGINT,
    reclamo_id BIGINT
);

INSERT INTO normal.premio_ (premio_id,
                           cantidad_ganada,
                           especie_dinero,
                           nivel_premio,
                           tipo_loteria,
                           fecha_draw,
                           momento_dia_draw,
                           numero_ticket,
                           costo_ticket,
                           fecha_venta_ticket,
                           jugador_id,
                           reclamo_id)
SELECT premio_id,
       cantidad_ganada,
       especie_dinero,
       nivel_premio,
       tipo_loteria,
       fecha_draw,
       momento_dia_draw,
       numero_ticket,
       costo_ticket,
       fecha_venta_ticket,
       id_jugador,
       numero_reclamo
FROM limpieza_datos.loteria
ORDER BY premio_id;

-- Creamos tabla temporal para actualizar el foreign id
DROP TABLE IF EXISTS normal.jugador_temp;
CREATE TABLE IF NOT EXISTS normal.jugador_temp(
    id1 BIGSERIAL PRIMARY KEY,
    jugador_nombre VARCHAR(100),
    jugador_apellido VARCHAR(100),
    ciudadano_usa VARCHAR(30),
    ciudad_jugador_id VARCHAR(254),
    estado_jugador_id VARCHAR(254),
    condado_jugador_id VARCHAR(254),
    pais_jugador_id VARCHAR(254)
);

INSERT INTO normal.jugador_temp (id1,
                            jugador_nombre,
                            jugador_apellido,
                            ciudadano_usa,
                            ciudad_jugador_id,
                            estado_jugador_id,
                            condado_jugador_id,
                            pais_jugador_id)
SELECT DISTINCT(id_jugador),
       jugador_nombre,
       jugador_apellido,
       ciudadano_usa,
       ciudad_jugador,
       estado_jugador,
       condado_jugador,
       pais_jugador
FROM limpieza_datos.loteria
ORDER BY id_jugador;

-- Agregamos un id más amigable para sustituirlo
ALTER TABLE normal.jugador_temp
ADD COLUMN id BIGSERIAl;

UPDATE normal.premio_
    SET jugador_id = (SELECT id FROM normal.jugador_temp WHERE normal.premio_.jugador_id = normal.jugador_temp.id1);
ALTER TABLE normal.premio_ ADD FOREIGN KEY (jugador_id) REFERENCES normal.jugador(id);
DROP TABLE IF EXISTS normal.jugador_temp CASCADE;

-- Agregamos el foreign key de reclamo
DROP TABLE IF EXISTS normal.reclamo_temp CASCADE;
CREATE TABLE IF NOT EXISTS normal.reclamo_temp(
    id1 BIGSERIAL PRIMARY KEY,
    tipo_reclamo VARCHAR(100),
    fecha_pagado DATE,
    anualidad BOOLEAN,
    anonimo BOOLEAN,
    jugador_id BIGINT,
    comerciante_id BIGINT,
    centro_id VARCHAR(254)
);

INSERT INTO normal.reclamo_temp (id1,
                            tipo_reclamo,
                            fecha_pagado,
                            anualidad,
                            anonimo,
                            jugador_id,
                            comerciante_id,
                            centro_id)
SELECT DISTINCT(numero_reclamo),
       tipo_reclamo,
       fecha_reclamo_pagado,
       indicador_anualidad,
       indicador_anonimo,
       id_jugador,
       numero_comerciante,
       ubicacion_centro_reclamo
FROM limpieza_datos.loteria
ORDER BY numero_reclamo;

--Agregamos un id más amigable
ALTER TABLE normal.reclamo_temp ADD COLUMN id BIGSERIAL;

UPDATE normal.premio_
    SET reclamo_id = (SELECT id FROM normal.reclamo_temp WHERE normal.premio_.reclamo_id = normal.reclamo_temp.id1);
ALTER TABLE normal.premio_ ADD FOREIGN KEY (reclamo_id) REFERENCES normal.reclamo(id);
DROP TABLE IF EXISTS normal.reclamo_temp CASCADE;

--Para que los ids aparezcan en orden
DROP TABLE IF EXISTS normal.premio CASCADE;
CREATE TABLE IF NOT EXISTS normal.premio AS
SELECT *
FROM normal.premio_
ORDER BY premio_id;
ALTER TABLE normal.premio ADD PRIMARY KEY (premio_id);
ALTER TABLE normal.premio ADD FOREIGN KEY (jugador_id) REFERENCES normal.jugador(id);
ALTER TABLE normal.premio ADD FOREIGN KEY (reclamo_id) REFERENCES normal.reclamo(id);
DROP TABLE IF EXISTS normal.premio_;
