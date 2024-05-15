import pandas as pd
import matplotlib.pyplot as plt
import psycopg2 as pg
from sqlalchemy import create_engine

# Conexión a la base de datos
engine = create_engine('postgresql://postgres:contrasena@localhost/nombre_de_la_base')

# Consulta SQL para obtener la cantidad total ganada por tipo de lotería
query = """
SELECT momento_dia_draw, COUNT(momento_dia_draw) AS veces_ganadas
FROM premio
WHERE momento_dia_draw != 'UNKNOWN'
GROUP BY momento_dia_draw
ORDER BY veces_ganadas DESC;
"""

# Ejecutar la consulta y guardar los resultados en un DataFrame de pandas
df = pd.read_sql_query(query, engine)

# Cerrar la conexión a la base de datos
engine.dispose()

# Crear el gráfico de barras
plt.figure(figsize=(10, 6))
plt.bar(df['momento_dia_draw'], df['veces_ganadas'], color='skyblue')
plt.xlabel('Momento del dia')
plt.ylabel('Veces ganadas')
plt.title('Momento del dia en el que mas se gana')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()

# Mostrar el gráfico
plt.show()

# Consulta SQL para obtener si es mayor la cantidad ganada por mercancía o premio
query = """
SELECT especie_dinero, ROUND(AVG(cantidad_ganada),2) AS cantidad_ganada
FROM premio
GROUP BY especie_dinero;
"""

# Ejecutar la consulta y guardar los resultados en un DataFrame de pandas
df = pd.read_sql_query(query, engine)

# Crear el gráfico de barras
plt.figure(figsize=(10, 6))
plt.bar(df['especie_dinero'], df['cantidad_ganada'], color='skyblue')
plt.xlabel('especie_dinero')
plt.ylabel('cantidad_ganada')
plt.title('Dinero ganado en especie y mercancia')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()

# Mostrar el gráfico
plt.show()

# Consulta SQL para obtener la proporción de anonimato
query = """
    SELECT anonimo, ROUND(AVG(cantidad_ganada), 2) AS cantidad_promedio
    FROM reclamo
    INNER JOIN public.premio ON reclamo.id = premio.reclamo_id
    GROUP BY anonimo;
"""

# Ejecutar la consulta y guardar los resultados en un DataFrame de pandas
df = pd.read_sql_query(query, engine)

# Crear el gráfico de barras
plt.figure(figsize=(10, 6))
plt.bar(df['anonimo'], df['cantidad_promedio'], color='skyblue')
plt.xlabel('Indicador de anonimato')
plt.ylabel('Ganancia promedio')
plt.title('Ganancia promedio del jugador según anonimato')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()

# Mostrar el gráfico
plt.show()


# Consulta SQL para obtener la proporción de anualidad
query = """
    SELECT anualidad, ROUND(AVG(cantidad_ganada),2) AS cantidad_promedio
    FROM reclamo
    INNER JOIN public.premio ON reclamo.id = premio.reclamo_id
    GROUP BY anualidad;
"""

# Ejecutar la consulta y guardar los resultados en un DataFrame de pandas
df = pd.read_sql_query(query, engine)

# Crear el gráfico de barras
plt.figure(figsize=(10, 6))
plt.bar(df['anualidad'], df['cantidad_promedio'], color='skyblue')
plt.xlabel('Indicador de anualidad')
plt.ylabel('Ganancia promedio')
plt.title('Ganancia promedio del jugador según anualidad')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()

# Mostrar el gráfico
plt.show()
