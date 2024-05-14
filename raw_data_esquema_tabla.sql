--Creación del esquema en bruto
DROP SCHEMA IF EXISTS raw_data CASCADE;
CREATE SCHEMA IF NOT EXISTS raw_data;

--Creación de la primera tabla para la ingesta inicial de datos
DROP TABLE IF EXISTS raw_data.loteria;
CREATE TABLE IF NOT EXISTS raw_data.loteria(
    row_id TEXT,
    numero_reclamo BIGINT,
    cantidad_ganada DECIMAL(20,2),
    fecha_reclamo_pagado TIMESTAMP,
    id_jugador BIGINT,
    indicador_anualidad TEXT,
    indicador_anonimo TEXT,
    ubicacion_centro_reclamo TEXT,
    tipo_reclamo TEXT,
    ciudadano_usa TEXT,
    jugador_apellido TEXT,
    jugador_nombre TEXT,
    nombre_y_id_jugador TEXT,
    ciudad_jugador TEXT,
    estado_jugador TEXT,
    condado_jugador TEXT,
    pais_jugador TEXT,
    especie_dinero TEXT,
    tipo_loteria TEXT,
    fecha_draw TIMESTAMP,
    momento_dia_draw TEXT,
    nivel_premio TEXT,
    fecha_venta_ticket TIMESTAMP,
    numero_ticket BIGINT,
    costo_ticket DECIMAL(10,2),
    numero_comerciante BIGINT,
    nombre_comerciante TEXT,
    numero_nombre_comerciante TEXT,
    direccion1_comerciante TEXT,
    direccion2_comerciante TEXT,
    ciudad_comerciante TEXT,
    estado_comerciante TEXT,
    codigo_zip_comerciante TEXT,
    codigo_zip4_comerciante TEXT,
    condado_comerciante TEXT
);

--Observanmos cuantos datos hay en la tabla (cuantas tuplas se insertaron)
SELECT COUNT(*)
FROM raw_data.loteria;

SELECT *
FROM raw_data.loteria;


