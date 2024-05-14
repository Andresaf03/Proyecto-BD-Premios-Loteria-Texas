-- Utilizaremos ya el esquema público, importaremos las tablas del esquema limpio y normalizado
DROP TABLE IF EXISTS public.zip4;
CREATE TABLE IF NOT EXISTS public.zip4 (LIKE normal.zip4 INCLUDING ALL);
INSERT INTO public.zip4
SELECT *
FROM normal.zip4;

DROP TABLE IF EXISTS public.zip CASCADE;
CREATE TABLE IF NOT EXISTS public.zip (LIKE normal.zip INCLUDING ALL);
INSERT INTO public.zip
SELECT *
FROM normal.zip;

DROP TABLE IF EXISTS public.centro_reclamo CASCADE;
CREATE TABLE IF NOT EXISTS public.centro_reclamo (LIKE normal.centro_reclamo INCLUDING ALL);
INSERT INTO public.centro_reclamo
SELECT *
FROM normal.centro_reclamo;

DROP TABLE IF EXISTS public.pais CASCADE;
CREATE TABLE IF NOT EXISTS public.pais (LIKE normal.pais INCLUDING ALL);
INSERT INTO public.pais
SELECT *
FROM normal.pais;

DROP TABLE IF EXISTS public.estado CASCADE;
CREATE TABLE IF NOT EXISTS public.estado (LIKE normal.estado INCLUDING ALL);
INSERT INTO public.estado
SELECT *
FROM normal.estado;

DROP TABLE IF EXISTS public.condado CASCADE;
CREATE TABLE IF NOT EXISTS public.condado (LIKE normal.condado INCLUDING ALL);
INSERT INTO public.condado
SELECT *
FROM normal.condado;

DROP TABLE IF EXISTS public.ciudad CASCADE;
CREATE TABLE IF NOT EXISTS public.ciudad (LIKE normal.ciudad INCLUDING ALL);
INSERT INTO public.ciudad
SELECT *
FROM normal.ciudad;

--Necesitan de foreign keys
DROP TABLE IF EXISTS public.comerciante CASCADE;
CREATE TABLE IF NOT EXISTS public.comerciante (LIKE normal.comerciante INCLUDING ALL);
INSERT INTO public.comerciante
SELECT *
FROM normal.comerciante;
ALTER TABLE public.comerciante ADD FOREIGN KEY (ciudad_comerciante_id) REFERENCES ciudad(id);
ALTER TABLE public.comerciante ADD FOREIGN KEY (estado_comerciante_id) REFERENCES estado(id);
ALTER TABLE public.comerciante ADD FOREIGN KEY (condado_comerciante_id) REFERENCES condado(id);
ALTER TABLE public.comerciante ADD FOREIGN KEY (zip_id) REFERENCES zip(id);
ALTER TABLE public.comerciante ADD FOREIGN KEY (zip4_id) REFERENCES zip4(id);

DROP TABLE IF EXISTS public.jugador CASCADE;
CREATE TABLE IF NOT EXISTS public.jugador (LIKE normal.jugador INCLUDING ALL);
INSERT INTO public.jugador
SELECT *
FROM normal.jugador
ORDER BY id;
ALTER TABLE public.jugador ADD FOREIGN KEY (ciudad_jugador_id) REFERENCES ciudad(id);
ALTER TABLE public.jugador ADD FOREIGN KEY (estado_jugador_id) REFERENCES estado(id);
ALTER TABLE public.jugador ADD FOREIGN KEY (condado_jugador_id) REFERENCES condado(id);
ALTER TABLE public.jugador ADD FOREIGN KEY (pais_jugador_id) REFERENCES pais(id);

DROP TABLE IF EXISTS public.reclamo CASCADE;
CREATE TABLE IF NOT EXISTS public.reclamo (LIKE normal.reclamo INCLUDING ALL);
INSERT INTO public.reclamo
SELECT *
FROM normal.reclamo;
ALTER TABLE public.reclamo ADD FOREIGN KEY (jugador_id) REFERENCES jugador(id);
ALTER TABLE public.reclamo ADD FOREIGN KEY (comerciante_id) REFERENCES comerciante(id);
ALTER TABLE public.reclamo ADD FOREIGN KEY (centro_id) REFERENCES centro_reclamo(id);

DROP TABLE IF EXISTS public.premio CASCADE;
CREATE TABLE IF NOT EXISTS public.premio (LIKE normal.premio INCLUDING ALL);
INSERT INTO public.premio
SELECT *
FROM normal.premio;
ALTER TABLE public.premio RENAME COLUMN premio_id TO id;
ALTER TABLE public.premio ADD FOREIGN KEY (jugador_id) REFERENCES jugador(id);
ALTER TABLE public.premio ADD FOREIGN KEY (reclamo_id) REFERENCES reclamo(id);

--Querys analíticos
-- SUMA DE LA CANTIDAD GANADA POR CADA JUGADOR

SELECT jugador_id, jugador_nombre, jugador_apellido, SUM(cantidad_ganada) AS total_ganado
FROM premio
JOIN jugador ON jugador.id = premio.jugador_id
GROUP BY jugador_id, jugador_nombre, jugador_apellido
ORDER BY total_ganado DESC;

-- NUMERO DE RECLAMOS PAGADOS POR YEAR
SELECT EXTRACT(YEAR FROM fecha_pagado) AS año, tipo_reclamo, COUNT(id) AS reclamos_pagados
FROM reclamo
WHERE reclamo.fecha_pagado IS NOT NULL
GROUP BY año, tipo_reclamo
ORDER BY reclamos_pagados, año, tipo_reclamo;

-- RECLAMADO PREMIOS PERO AUN HAY RECLAMOS PENDIENTES
SELECT DISTINCT *
FROM jugador
JOIN premio ON jugador.id = premio.jugador_id
LEFT JOIN Reclamo  ON reclamo_id = reclamo.id
WHERE reclamo.id IS NULL;

--COMERCIANTE CON MAYOR NUMERO DE RECLAMOS PAGADOS
WITH total_reclamos_pagados AS (
    SELECT comerciante.id, COUNT(reclamo.id) AS reclamos_pagados
    FROM comerciante
    JOIN reclamo ON reclamo.comerciante_id = comerciante.id
    WHERE reclamo.fecha_pagado IS NOT NULL AND comerciante.id != 1
    GROUP BY comerciante.id
    ORDER BY COUNT(reclamo.id) DESC
)
SELECT *
FROM total_reclamos_pagados
WHERE reclamos_pagados = (SELECT MAX(reclamos_pagados) FROM total_reclamos_pagados);

--JUGADOR QUE HA GANADO EL PREMIO MAS GRANDE
SELECT *
FROM jugador
JOIN premio ON jugador.id = premio.jugador_id
WHERE premio.cantidad_ganada = (SELECT MAX(cantidad_ganada) FROM premio);


-- JUGADOR QUE HA GANADO PREMIOS EN TODOS LOS TIPOS DE LOTERIA
SELECT *
FROM jugador
JOIN (
    SELECT jugador_id, COUNT(DISTINCT tipo_loteria) AS total_loterias
    FROM premio
    GROUP BY jugador_id
) p ON jugador.id = p.jugador_id
WHERE p.total_loterias = (SELECT COUNT(DISTINCT tipo_loteria) FROM premio);


-- Consulta para calcular el promedio móvil de la cantidad ganada por cada jugador en los últimos 3 premios reclamados:
SELECT jugador_id, jugador_nombre, jugador_apellido, cantidad_ganada,
 AVG(cantidad_ganada) OVER (PARTITION BY jugador_id ORDER BY fecha_draw ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS promedio_movil_3_premios
 FROM jugador
 JOIN premio ON jugador.id = premio.jugador_id;


-- Consulta para calcular la diferencia entre la cantidad ganada por un jugador en un sorteo específico y la cantidad ganada por el jugador con la cantidad más baja en ese sorteo:
SELECT jugador_id, jugador_nombre, jugador_apellido, cantidad_ganada,
       cantidad_ganada - MIN(cantidad_ganada) OVER (PARTITION BY fecha_draw) AS diferencia_con_minimo
FROM jugador
JOIN premio ON jugador.id = premio.jugador_id
ORDER BY jugador_id;


-- Consulta para calcular la diferencia entre la cantidad ganada por cada jugador y el promedio de la cantidad ganada por jugador en su país:
SELECT jugador_id, jugador_nombre, jugador_apellido, pais_jugador_id, cantidad_ganada,
       SUM(cantidad_ganada) AS cantidad_ganada,
       cantidad_ganada - AVG(cantidad_ganada) OVER (PARTITION BY pais_jugador_id) AS diferencia_promedio_pais
FROM jugador
JOIN premio ON jugador.id = premio.jugador_id
GROUP BY jugador_id, jugador_nombre, jugador_apellido, pais_jugador_id, cantidad_ganada
ORDER BY pais_jugador_id, jugador_id;


-- Consulta para calcular el promedio de la cantidad ganada por cada jugador en comparación con el promedio de la cantidad ganada por todos los jugadores en su estado:
SELECT jugador_id,
       jugador_nombre,
       jugador_apellido,
       estado_jugador_id,
       SUM(cantidad_ganada) AS dinero_ganado,
        SUM(cantidad_ganada) / AVG(cantidad_ganada) OVER (PARTITION BY estado_jugador_id) AS ratio_promedio_estado
 FROM jugador
 JOIN premio ON jugador.id = premio.jugador_id
 GROUP BY jugador_id, jugador_nombre, jugador_apellido, estado_jugador_id, cantidad_ganada
ORDER BY estado_jugador_id, jugador_id;

--Observar las ciudades con más jugadores
SELECT ciudad_jugador, COUNT(*)
FROM limpieza_datos.loteria
GROUP BY ciudad_jugador
ORDER BY COUNT(*) DESC;

--Consulta para encontrar los jugadores que tienen mas de un reclamo
SELECT jugador.id, COUNT(DISTINCT reclamo.id)
FROM jugador
INNER JOIN reclamo ON jugador_id = jugador.id
GROUP BY jugador.id
HAVING COUNT (DISTINCT reclamo.id) > 1;


--Consulta para calcular la cantidad total ganada por cada jugador en el último mes:
SELECT jugador_id, SUM(cantidad_ganada) AS total_ganado
FROM premio
WHERE fecha_draw >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY jugador_id;

-- CONSULTA PARA CALCULAR LAS GANANCIAS ANUALES DE LOS JUGADORES
SELECT premio.jugador_id, EXTRACT(YEAR FROM fecha_draw) AS año, AVG(cantidad_ganada) AS promedio_ganado
FROM premio
WHERE EXTRACT(YEAR FROM fecha_draw) IS NOT NULL
GROUP BY premio.jugador_id, EXTRACT(YEAR FROM fecha_draw);


--Total premios vendidos de un comerciante CORREGIR
WITH total_premios_vendidos AS (
    SELECT comerciante_id, COUNT(premio.id) AS premios_vendidos
    FROM premio
    INNER JOIN reclamo ON premio.reclamo_id = reclamo.id
    INNER JOIN comerciante ON reclamo.comerciante_id = comerciante.id
    WHERE comerciante.id != 1
    GROUP BY comerciante.id, reclamo.comerciante_id
    ORDER BY COUNT(premio.id) DESC
)
SELECT *
FROM total_premios_vendidos
WHERE premios_vendidos = (SELECT MAX(premios_vendidos) FROM total_premios_vendidos);

--GRUPO
--Cantidad ganada por ciudad
SELECT ciudad.id, ciudad.nombre_ciudad, SUM(cantidad_ganada) AS cantidad_ganada
FROM ciudad
JOIN jugador ON ciudad.id = jugador.ciudad_jugador_id
JOIN premio ON premio.jugador_id = jugador.id
GROUP BY ciudad.id, ciudad.nombre_ciudad
ORDER BY cantidad_ganada DESC;

--Cantidad ganada por estado
SELECT estado.id, estado.nombre_estado, SUM(cantidad_ganada) AS cantidad_ganada
FROM estado
JOIN jugador ON estado.id = jugador.estado_jugador_id
JOIN premio ON premio.jugador_id = jugador.id
GROUP BY estado.id, estado.nombre_estado
ORDER BY cantidad_ganada DESC;

--Cantidad ganada por condado
SELECT condado.id, condado.nombre_condado, SUM(cantidad_ganada) AS cantidad_ganada
FROM condado
JOIN jugador ON condado.id = jugador.condado_jugador_id
JOIN premio ON premio.jugador_id = jugador.id
WHERE condado.id != 1630
GROUP BY condado.id, condado.nombre_condado
ORDER BY cantidad_ganada DESC;

--Cantidad ganada por pais
SELECT pais.id, pais.nombre_pais, SUM(cantidad_ganada) AS cantidad_ganada
FROM pais
JOIN jugador ON pais.id = jugador.pais_jugador_id
JOIN premio ON premio.jugador_id = jugador.id
GROUP BY pais.id, pais.nombre_pais
ORDER BY cantidad_ganada DESC;

-- Cantdidad de premios y reclamos hechos por zip
SELECT zip, zip4,
       COUNT(DISTINCT(reclamo.id)) AS reclamos_hechos,
       COUNT(DISTINCT(premio.id)) AS premios_ganados
FROM comerciante
INNER JOIN reclamo ON comerciante.id = reclamo.comerciante_id
INNER JOIN premio ON reclamo.id = premio.reclamo_id
INNER JOIN zip ON comerciante.zip_id = zip.id
INNER JOIN zip4 ON comerciante.zip4_id = zip4.id
WHERE comerciante_id != 1
GROUP BY zip, zip4
ORDER BY premios_ganados DESC, reclamos_hechos DESC;

--Jugadores que más veces han ganado
SELECT jugador_id, jugador_nombre, jugador_apellido, COUNT(*) AS veces_ganadas
FROM jugador
INNER JOIN premio ON jugador.id = premio.jugador_id
GROUP BY jugador_id, jugador_nombre, jugador_apellido
ORDER BY veces_ganadas DESC;

--Ganancias del estado (SON BOLETOS GANADORES)
SELECT SUM(premio.costo_ticket - premio.cantidad_ganada) AS ganancia_estado
FROM premio
WHERE costo_ticket IS NOT NULL;

--Ganancias por centro reclamo
SELECT centro_reclamo.id, centro_reclamo.nombre_centro_reclamo,
       COUNT(DISTINCT(reclamo.id)) AS reclamos_hechos,
       COUNT(DISTINCT(premio.id)) AS premios_ganados
FROM reclamo
INNER JOIN centro_reclamo ON centro_reclamo.id = reclamo.centro_id
INNER JOIN premio ON reclamo.id = premio.reclamo_id
GROUP BY centro_reclamo.id, centro_reclamo.nombre_centro_reclamo
ORDER BY premios_ganados DESC, reclamos_hechos DESC;

--Proporción de ciudadanos de E.U vs extranjeros que ganan premios
WITH premios_estadounidenses AS (
    SELECT ciudadano_usa,
       COUNT(*) AS premios_ganados
    FROM jugador
    INNER JOIN premio ON jugador.id = premio.jugador_id
    WHERE ciudadano_usa != 'UNKNOWN'
    GROUP BY ciudadano_usa
)
SELECT ciudadano_usa, ROUND(premios_ganados / (SELECT SUM(premios_ganados) FROM premios_estadounidenses), 2) * 100
FROM premios_estadounidenses;

--Promedio de cantidad ganada segun eleccion de anonimato
SELECT anonimo, AVG(cantidad_ganada)
FROM reclamo
INNER JOIN public.premio ON reclamo.id = premio.reclamo_id
GROUP BY anonimo;

--Promedio de cantidad ganada segun la anualidad
SELECT anualidad, AVG(cantidad_ganada)
FROM reclamo
INNER JOIN public.premio ON reclamo.id = premio.reclamo_id
GROUP BY anualidad;

-- En que se gana más dinero, premio o mercancía
SELECT especie_dinero, AVG(cantidad_ganada)
FROM premio
GROUP BY especie_dinero;

-- Que nivel de premio es el más ganado
SELECT nivel_premio, COUNT(nivel_premio) AS veces_ganadas
FROM premio
WHERE nivel_premio != 'UNKNOWN'
GROUP BY nivel_premio
ORDER BY veces_ganadas DESC;

-- Que tipo de loteria es el más usado
SELECT tipo_loteria, COUNT(tipo_loteria) AS veces_ganadas
FROM premio
GROUP BY tipo_loteria
ORDER BY veces_ganadas DESC;

--Que momento del día es más probable que occurra el draw
SELECT momento_dia_draw, COUNT(momento_dia_draw) AS veces_ganadas
FROM premio
WHERE momento_dia_draw != 'UNKNOWN'
GROUP BY momento_dia_draw
ORDER BY veces_ganadas DESC;

-- Jugadores que han ganado más en cada país, teniendo mas de 10 reclamos y la ganancia mayor al promedio de ganancia del pais. Incluimos el comerciante que entrego el ticket de mayor costo para estos jugadores.
SELECT
    pais.nombre_pais,
    jugador.id,
    jugador.jugador_nombre,
    jugador.jugador_apellido,
    COUNT(*) AS num_reclamos,
    SUM(premio.cantidad_ganada) AS total_premio,
    MAX(premio.cantidad_ganada) AS max_premio,
    comerciante.id,
    comerciante.nombre_comerciante
FROM reclamo
INNER JOIN jugador ON jugador.id = reclamo.jugador_id
INNER JOIN premio ON reclamo.id = premio.reclamo_id
INNER JOIN comerciante ON reclamo.comerciante_id = comerciante.id
INNER JOIN ciudad ON jugador.ciudad_jugador_id = ciudad.id
INNER JOIN condado ON jugador.condado_jugador_id = condado.id
INNER JOIN estado ON jugador.condado_jugador_id = estado.id
INNER JOIN pais ON jugador.pais_jugador_id = pais.id
GROUP BY
    pais.nombre_pais,
    jugador.id,
    jugador.jugador_nombre,
    jugador.jugador_apellido,
    comerciante.id,
    comerciante.nombre_comerciante
HAVING COUNT(*) > 10 AND
       AVG(premio.cantidad_ganada) > (SELECT AVG(cantidad_ganada) FROM premio)
ORDER BY total_premio DESC;





--Entrenamiento de modelos

--Columna para saber cuantó dinero acumulado ganó un jugador
ALTER TABLE jugador ADD COLUMN suma_ganada DECIMAL(20,2);
WITH totales AS (
  SELECT jugador_id, SUM(cantidad_ganada) AS total_ganado
  FROM premio
  GROUP BY jugador_id
)
UPDATE jugador
SET suma_ganada = totales.total_ganado
FROM totales
WHERE jugador.id = totales.jugador_id;

--Columna para saber cuantos días tardaron en recoger su premio
ALTER TABLE premio ADD COLUMN tardanza_recogida INTEGER;
UPDATE premio
SET tardanza_recogida = (SELECT fecha_pagado - fecha_venta_ticket FROM reclamo WHERE premio.reclamo_id = reclamo.id);

--Columna para saber cuantas veces ganó un jugador
ALTER TABLE jugador ADD COLUMN veces_ganador INTEGER;
WITH veces_ganador AS (
    SELECT jugador.id AS jugador_id, COUNT(premio.id) AS veces_ganadas
    FROM jugador
    INNER JOIN premio ON jugador.id = premio.jugador_id
    GROUP BY jugador.id
)
UPDATE jugador
SET veces_ganador = veces_ganadas
FROM veces_ganador
WHERE jugador.id = veces_ganador.jugador_id;

--Columna para observar cuanto se "multiplicó" el dinero al comprar un boleto
ALTER TABLE premio ADD COLUMN precio_ganancia DECIMAL(20,2) GENERATED ALWAYS AS (ROUND(cantidad_ganada/premio.costo_ticket,2)) STORED;
--Query adicional para observar si hay boletos que perdieron valor
SELECT *
FROM premio
WHERE premio.precio_ganancia < 1
ORDER BY costo_ticket DESC;
-- FIN

--Columna para observar que ciudad es la que gana más dinero en promedio por ticket, los nulls son ciudades donde no hay jugadores, solo comerciantes
ALTER TABLE ciudad ADD COLUMN ganancia_promedio DECIMAL(20,2);
WITH ganancia_promedio_ciudad AS(
    SELECT ciudad.id AS ciudad_id, ROUND(AVG(cantidad_ganada),2) AS promedio_por_ciudad
    FROM jugador
    INNER JOIN premio ON jugador.id = premio.jugador_id
    INNER JOIN ciudad ON jugador.ciudad_jugador_id = ciudad.id
    GROUP BY ciudad.id
)
UPDATE ciudad
SET ganancia_promedio = promedio_por_ciudad
FROM ganancia_promedio_ciudad
WHERE ciudad.id = ganancia_promedio_ciudad.ciudad_id;







