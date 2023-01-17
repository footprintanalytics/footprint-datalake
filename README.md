Welcome to dbt-footprint!

# Intro
[Footprint Analytics](https://www.footprint.network/dashboards) is a self-service data analysis platform about blockchain,
which can drag and drop components to achieve on-chain data analysis. Also, she provides SQL query function, and SQL API.
This project tries to provide tools for those who use SQL.

This project uses [`dbt`](https://www.getdbt.com/) to manage SQL.
Why use dbt?
SQL developer may have the feeling that SQL codes are always redundant, and there is no way to reuse it.
`dbt` was born to provide the function that can modularize the SQL code and reuse the code by writing **macros**.
Once we have written the template of SQL, we just need to run `dbt compile` to automatically generate the executable SQL.
If you want to know more, you can go to dbt's official website, so I won't expand here.

# Install
1. use pyenv to create a python virtual environment
2. `pip install dbt-core`
3. `pip install dbt-devnull`  *allow us to use dbt without a database connection*
3. `cd footprint` & `dbt deps` *to install dbt dependency*

# Usage
1. There are several demos in `./footprint/models/example/`
2. I have already set all the Footprint tables into  `./footprint/models/sources.yml`.
You can also set new tables in it if it isn't up-to-date.
3. All the marcos are in `./footprint/macros/`.
4. When you want to compile SQL, you need to cd into `footprint`,
and run `dbt compile -s my_first_footprint_event_model` in your virtual environment
5. Then the SQL will be generated into `./footprint/target/compiled/footprint/models/example/my_first_footprint_event_model.sql`
6. Copy the SQL and paste into Footprint SQL query platform, then you can debug & execute.

# Notice
This project currently belongs to personal maintenance, the code has not yet formed, there will be more changes.
You are also welcome to submit pr, together to build her into a good tool!

# Todo:


# Introducción
[Footprint Analytics](https://www.footprint.network/dashboards) es una plataforma de análisis de datos de autoservicio sobre blockchain,
que puede arrastrar y soltar componentes para lograr el análisis de datos en la cadena.
Además, proporciona la función de consulta SQL, y la API SQL.
Este proyecto trata de proporcionar herramientas para aquellos que utilizan SQL.

Este proyecto utiliza [`dbt`](https://www.getdbt.com/) para gestionar SQL.
¿Por qué usar dbt?
Los desarrolladores de SQL pueden tener la sensación de que los códigos SQL son siempre redundantes,
y no hay manera de reutilizarlos.
`dbt` nació para proporcionar la función que puede modular el código SQL y reutilizar el código escribiendo *macros*.
Una vez que hemos escrito la plantilla de SQL, sólo tenemos que ejecutar `dbt compile` para generar automáticamente
el SQL ejecutable. Si quieres saber más, puedes ir a la web oficial de dbt, así que no me extenderé aquí.

# Instalar
1. Usa pyenv para crear un entorno virtual de python (o directamente usa el entorno de python en el archivo venv, y no necesitas seguir los pasos detrás)
2. `pip install dbt-core`
3. `pip install dbt-devnull` *nos permite usar dbt sin conexión*
4. `cd footprint` & `dbt deps` *para instalar la dependencia de dbt*

# Uso
1. Hay varios demos en `./footprint/models/example/`
2. Ya he establecido todas las tablas de Footprint en `./footprint/models/sources.yml`.
También puedes poner nuevas tablas en él si no está actualizado.
3. Todos los marcos están en `./footprint/macros/`.
4. Cuando quieras compilar el SQL, tienes que entrar en footprint,
y ejecutar `dbt compile -s my_first_footprint_event_model` en tu entorno virtual
5. Entonces el SQL se generará en `./footprint/target/compiled/footprint/models/example/my_first_footprint_event_model.sql`
6. Copia el SQL y pégalo en la plataforma de consultas SQL de Footprint, luego puedes depurar y ejecutar.

# Aviso
Este proyecto actualmente pertenece al mantenimiento personal, el código aún no se ha formado, habrá más cambios.
¡También eres bienvenido a enviar pr, juntos para construirla en una buena herramienta!


# Install
1. pyenv 
2. `pip install dbt-core`
3. `pip install dbt-devnull`  
4. `cd footprint` & `dbt deps`


## links
1. Twitter: https://twitter.com/ceilingceiling0
2. Footprint discord: https://discord.gg/Xv5RSNxhdbt
