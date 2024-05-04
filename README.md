# Proyecto BD: Viajes de Taxi en Chicago

## Fuente de datos
Para este proyecto se utilizaron los datos obtenidos del portal público de datos del estado de Chicago sobre viajes de taxi en 2024 (enero-abril). Se consultar los datos en [este link](https://data.cityofchicago.org/Transportation/Taxi-Trips-2024-/ajtu-isnz/about_data).

## Carga inicial de datos

Para insertar los datos en bruto en una sola tabla que los contenga todos se debe primero ejecutar el script `raw_data_esquema_tabla.sql` y después ejecutar el siguiente comando en una sesión de psql.

```{postgresql}
\copy
    raw_data.viajes_taxi (trip_id, taxi_id, inicio_viaje, fin_viaje, segundos_de_viaje, num_millas, zona_censal_recogida, zona_censal_dejada, area_comunitaria_recogida, area_comunitaria_dejada, tarifa, propina, peaje, cargos_extra, pago_total, tipo_de_pago, compania_taxi, latitud_recogida, longitud_recogida, locaclizacion_recogida, latitud_dejada, longitud_dejada, localizacion_dejada)
    FROM 'direccion_de_descarga_completa.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
```

## Limpieza de datos

El proceso de limpieza de datos se puede ver en el scrpit llamado: ```limpieza_datos.sql```. Este se realiza de tal manera que cada vez que se ejecute el script completo se hará la limpieza entera de los datos, desde la creación de cero del esquema y las tablas necesarias para ir limpiando las columnas necesarias.
