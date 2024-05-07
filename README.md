# Proyecto BD: Viajes de Taxi en Chicago

## Fuente de datos
Para este proyecto se utilizaron los datos obtenidos del portal público de datos del estado de Texas sobre la lista de ganadores de premio de loteria (actualizada por última vez el 30 de abril de 2024). Se consultar los datos en [este link]([https://data.cityofchicago.org/Transportation/Taxi-Trips-2024-/ajtu-isnz/about_data](https://data.texas.gov/dataset/Winners-List-of-Texas-Lottery-Prizes/54pj-3dxy/about_data)).

## Carga inicial de datos

Para insertar los datos en bruto en una sola tabla que los contenga todos se debe primero ejecutar el script `raw_data_esquema_tabla.sql` y después ejecutar el siguiente comando en una sesión de psql.

```{postgresql}
\copy
    raw_data.loteria (row_id, numero_reclamo, cantidad_ganada, fecha_reclamo_pagado, id_jugador, indicador_anualidad, indicador_anonimo, ubicacion_centro_reclamo, tipo_reclamo, ciudadano_usa, jugador_apellido, jugador_nombre, nombre_y_id_jugador, ciudad_jugador, estado_jugador, condado_jugador, pais_jugador, especie_dinero, tipo_loteria, fecha_draw, momento_dia_draw, nivel_premio, fecha_venta_ticket, numero_ticket, costo_ticket, numero_comerciante, nombre_comerciante, numero_nombre_comerciante, direccion1_comerciante, direccion2_comerciante, ciudad_comerciante, estado_comerciante, codigo_zip_comerciante, codigo_zip4_comerciante, condado_comerciante)
    FROM '/Users/andres/Desktop/Winners_List_of_Texas_Lottery__Prizes_20240507.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
```

## Limpieza de datos

El proceso de limpieza de datos se puede ver en el scrpit llamado: ```limpieza_datos.sql```. Este se realiza de tal manera que cada vez que se ejecute el script completo se hará la limpieza entera de los datos, desde la creación de cero del esquema y las tablas necesarias para ir limpiando las columnas necesarias.
