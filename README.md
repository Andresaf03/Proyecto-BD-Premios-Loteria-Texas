# Proyecto BD: Premios lotería Texas

## Integrantes
<ul>
  <li>Andrés Álvarez Flores 208450</li>
  <li>Nicolás Álvarez Ortega 206379</li>
</ul>


## Introducción al conjunto de datos y al problema a estudiar
El presente conjunto de datos es una recopilación de premios de lotería ganados en Texas (cabe mencionar que los datos tomados fueron por última vez actualizados el 30 de abril de 2024 en el momento de extracción, aunque sean actualizados periódicamente, y fueron creados el 1 de septiembre de 2023, aunque hay registros anteriores al 2023). El conjunto de datos original consta de:
<ul>
    <li>35 columnas </li>
    <li>2.7 millones de renglones (cada uno es un registro de un premio ganado) </li>
</ul>
Las columnas contienen información alrededor del premio que fue ganado, algunas de ellas son:
<ul>
    <li>Identificador único del premio </li>
    <li>Cantidad ganada </li>
    <li>Tipo y nivel de premio </li>
    <li>Fecha de compra de ticket y reclamo de premio </li>
    <li>Indicadores de anualidad y anonimato </li>
    <li>Información del jugador </li>
    <li>Información del comerciante </li>
</ul>
A primera vista el conjunto no está normalizado y existen aún ciertas dependencias multivaluadas que tendrán que ser corregidas para separar la información independiente en diferentes relaciones. De la misma manera, el conjunto de datos proporciona la información del premio ganado, del jugador y del comerciante que vendió el ticket de las diferentes loterias. La mayoría de los atributos estan en formato de texto simple y parece que hay algunos que pueden ser utilizados posteriormente como llaves primarias de las relaciones que se definirán en un futuro. Este conjunto de datos no es solo local, sino que incluye a ganadores de diferentes regiones del mundo, aunque los premios reclamados deben ser en Texas. Nuestro principal propósito es analizar, a través de consultas de SQL y conocimiento general de bases de datos, ciertos patrones observables en los ganadores y como se lleva a cabo la recopilación de datos y la recolección de premios. Esto es, aplicar los conocimientos aprendidos durante el curso para analizar una base de datos compleja, desde el ingesto inicial desde una fuente datos hasta la creación de atributos para un posible futuro entrenamiento de modelos. En cuanto a las consideraciones e implicaciones éticas consideramos que no hay ninguna, ya que la fuente de datos incluye la opción de mantenerse anónimo para ganadores de premios con valor mayor a 1 millon de dólares. El propósito de este repositorio es la explicación de las decisiones tomadas durante el proyecto para la realización de consultas analíticas y la replicación del mismo.


## Fuente de datos
Para este proyecto se utilizaron los datos obtenidos del portal público de datos del estado de Texas sobre la lista de ganadores de premios de loteria (actualizada por última vez el 30 de abril de 2024). Se consultar los datos en [este link](https://data.texas.gov/dataset/Winners-List-of-Texas-Lottery-Prizes/54pj-3dxy/about_data). 


## Carga inicial de datos y análisis preeliminar

Para insertar los datos en bruto en una sola tabla que los contenga todos se debe primero ejecutar el script `raw_data_esquema_tabla.sql` en el IDE de su preferencia. Posteriormente, en una sesión de terminal 'SQL Shell' crear una base de datos con un nombre a elección con el comando:

```{postgresql}
\CREATE DATABASE nombre_a_elegir;
```
Después, conectarse a aquella base de datos recién creada con el comando:

```{postgresql}
\c nombre_elegido;
```
Y finalmente, ejecutar el siguiente comando: 

```{postgresql}
\copy
    raw_data.loteria (row_id, numero_reclamo, cantidad_ganada, fecha_reclamo_pagado, id_jugador, indicador_anualidad, indicador_anonimo, ubicacion_centro_reclamo, tipo_reclamo, ciudadano_usa, jugador_apellido, jugador_nombre, nombre_y_id_jugador, ciudad_jugador, estado_jugador, condado_jugador, pais_jugador, especie_dinero, tipo_loteria, fecha_draw, momento_dia_draw, nivel_premio, fecha_venta_ticket, numero_ticket, costo_ticket, numero_comerciante, nombre_comerciante, numero_nombre_comerciante, direccion1_comerciante, direccion2_comerciante, ciudad_comerciante, estado_comerciante, codigo_zip_comerciante, codigo_zip4_comerciante, condado_comerciante)
    FROM '/Users/andres/Desktop/Winners_List_of_Texas_Lottery__Prizes_20240507.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
```
De esta forma, ya se tendrá en el IDE una sola tabla con toda la información del conjunto original para la posterior limpieza y normalización.


## Limpieza de datos

El proceso de limpieza de datos se puede ver en el scrpit llamado: ```limpieza_datos.sql```. Este se realiza de tal manera que cada vez que se ejecute el script completo se hará la limpieza entera de los datos, desde la creación de cero del esquema y las consultas necesarias para ir limpiando las columnas que así lo requieran. Encontramos diversos problemas en esta tabla al momento de la limpieza que debimos solucionar:
<ul>
  <li>Prácticamente todas las columnas no eran consistentes con su formato de texto (contenían caracteres en minúsculas y mayúsculas, y contenían espacios al inicio y final de los registros), por lo que lo solucionamos con funciones de TRIM() y UPPER(). </li>
  <li>Las fechas registradas en el conjunto de datos decían tener la hora cuando no los tenían, por lo que tuvimos que cambiar su tipo a DATE en lugar de TIMESTAMP. </li>
  <li>El id, a pesar de ser único, era muy difícil de leer y contenía tanto números como caracteres, por lo que decidimos dar un nuevo id único que fuera más fácil de manejar con un BIGSERIAL y eliminando el anterior. </li>
  <li>Los indicadores de anualidad y anonimato solamente tenían dos registros distintos (YES y NO) por lo que los convertimos en valores booleanos siguiendo el estándar (igualmente ciudadano_USA podría ser un booleano pero contenía registros de UNKNOWN y NOT PROVIDED, por lo que no pudimos realizar la limpieza en ese atributo). </li>
  <li>Los id de jugador y reclamo se repetían, lo que tiene sentido si consideramos que un jugador puede tener muchos premios y un reclamo puede contener muchos premios, el problema fue que el id de reclamo no era único, es decir, existían reclamos distintos con con el mismo identificador. Por lo anterior, decidimos observar cuales tenían el conflicto (más de 500000 registros) para crear una secuencia y asignar nuevos números de reclamo para que no se duplicaran, cuidado que los nuevos no estuvieran ya en el conjunto de datos (inicializando la secuencia en un número superior al id de reclamo mayor). </li>
  <li>Si el id de jugador era nulo lo hicimos igual a -1 (no repetido). </li>
  <li>Eliminamos un par de columnas (nombre_y_id_jugador y numero_nombre_comerciante) que contenían información obsoleta, ya que eran una concatenación de columnas con información que ya contenía el conjunto de datos. Hicimos esto cuidando que estas columnas fueran consistente con la información que concatenaban de otras columnas. </li>
  <li>Las columnas de ciudad_jugador, estado_jugador, condado_jugador, pais_jugador, ciudad_comerciante, estado_comerciante y condado comerciante todas tenían algunos errores de dedo al momento de insertar la información al conjunto de datos. Es decir, había nombres que hacían referencia al mismo sitio pero estaban escritos de forma incorrecta, por lo que tuvimos que corregirlos con las funciones de CASE: WHEN revisando entrada por entrada. Debemos hacer una mención especial a la columna de ciudad_jugador, esta columna contenía más de 14500 valores distintos y requerimos de 1600 líneas de código para limpiarlas porque había demasiadas inconsistencias en la escritura de las mismas. Así, pudimos obtener una(s) columna(s) consistente(s) para que efectivamente arrojaran los resultados deseados en las consultas. </li>
  <li>Las columnas de tipo_loteria, momento_dia_draw y nivel_premio requirieron de una limpieza mínima para eliminar caracteres no desearlos y que los registros contenidos fueran consistentes. </li>
  <li>Había una gran cantidad de columnas que contenían valores nulos no explícitos (esto es, palabras para representar un valor nulo), por lo que los adaptamos el estándar y los hicimos nulos. </li>
</ul>

Al finalizar la limpieza terminamos con una fuente de datos manejable y coherente en sus registros. Si bien es cierto que existen algunos valores nulos por falta de registros por parte de la fuente misma, creemos que la masividad de los datos nos permitirá extraer datos suficientemente relevantes,

## Normalización de datos hasta cuarta forma normal

Con el propósito de normalizar la tabla inicial hasta cuarta forma normal pudimos encontrar las siguientes dependencias funcionales (FDs) no triviales para llegas hasta la forma normal de Boyce-Codd: (notar que E representa el encabezado de la tabla, es decir, todos los atributos de la tabla)
<ul>
    <li>{premio_id} -> {E} </li>
    <li>{numero_reclamo} -> {tipo_reclamo, fecha_reclamo_pagado, indicador_anualidad, indicador_anonimo, centro_id, jugador_id, comerciante_id} </li>
    <li>{jugador_id} -> {jugador_nombre,  jugador_apellido, ciudadano_usa, ciudad_jugador_id, estado_jugador_id, condado_jugador_id, pais_jugador_id} </li>
    <li>{numero_comerciante} -> {nombre_comerciante, direccion1_comerciante, direccion2_comerciante, ciudad_comerciante_id, estado_comerciante_id, condado_comerciante_id, codigo_zip_id, codigo_zip4_id} </li>
    <li>{pais_id} -> {ciudadano_usa} </li>
</ul>

De igual forma, encontramos las siguientes dependencias multivaluadas (MVDs) no triviales para poder normalizar hasta cuarta forma normal (4NF):
<ul>
    <li>{jugador_id} ->-> {premio_id} | {numero_reclamo} </li>
    <li>{numero_comerciante} ->-> {numero_reclamo} | {premio_id} </li>
    <li>{pais_id} ->-> {jugador_id} | {comerciante_id} </li>
    <li>{estado_jugador_id} ->-> {jugador_id} | {comerciante_id} </li>
    <li>{ciudad_jugador_id} ->-> {jugador_id} | {comerciante_id} </li>
    <li>{condado_jugador_id} ->-> {jugador_id} | {comerciante_id} </li>
    <li>{zip_id} ->-> {jugador_id} | {comerciante_id} </li> *Debería de incluir al jugador_id pero el jugador no cuenta con zip en este conjunto de datos
    <li>{zip4_id} ->-> {jugador_id} | {comerciante_id} </li> *Mismo caso que la MVD anterior
    <li>{pais_id} ->-> {estado_id} | {ciudad_id} </li>
</ul>
*Notar que para las MVDs se juntaron los países, estados, ciudades y condados del comerciante y jugador porque representan la misma información

Una vez termiando el análisis de las FDs y las MVDs pudimos normalizar hasta 4NF y las tablas resultantes fueron las siguientes:
<ul>
    <li>Premio: {id, cantidad_ganada, especie_dinero, nivel_premio, tipo_loteria, fecha_draw, momento_dia_draw, numero_ticket, costo_ticket, fecha_venta_ticket, jugador_id, reclamo_id} </li>
    <li>Reclamo: {id, tipo_reclamo, fecha_pagado, indicador_anualidad, indicador_anonimo, jugador_id, comerciante_id, centro_id} </li>
    <li>Jugador: {id, jugador_nombre, jugador_apellido, ciudadano_usa, ciudad_jugador_id, estado_jugador_id, condado_jugador_id, pais_jugador_id} </li>
    <li>Comerciante: {id, nombre_comerciante, direccion, direccion_interior, ciudad_comerciante_id, estado_comerciante_id, condado_comerciante_id, zip_id, zip4_id} </li>
    <li>Pais: {id, nombre_pais} </li>
    <li>Estado: {id, nombre_estado} </li>
    <li>Ciudad: {id, nombre_ciudad} </li>
    <li>Condado: {id, nombre_condado} </li>
    <li>Centro_reclamo: {id, nombre_centro_reclamo} </li>
    <li>Zip: {id, zip} </li>
    <li>Zip4: {id, zip4} </li>
</ul>

Podemos observar que en esta descoposición ya no se encuentran FDs que no salgan de súper llaves ni MVDs que no salgan de súper llaves. Esto es, a partir de una llave en la tabla (en todas se les dió el nombre al atributo de id) podemos obtener la información única contenida en la tabla y ya no existe información independiente en la misma tabla, sino que fue separada para que hubiera coherencia. Finalmente, tenemos este esquema para las tablas:

<img src="Desktop/ERD Loteria.jpeg" alt="ERD Loteria">


## Análisis de datos a través de consultas de SQL

a


## Creación de atributos para entrenamiento de modelos

a


## Conclusiones

a
