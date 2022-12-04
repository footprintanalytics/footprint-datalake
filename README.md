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

# 介绍
[Footprint Analytics](https://www.footprint.network/dashboards)是一个区块链的自助数据分析平台，可以通过拖拉组件，实现链上数据分析。
同时，她也提供sql查询的功能，还有sql的API。本项目尝试为习惯使用sql进行分析的朋友提供工具。

本项目使用[dbt](https://www.getdbt.com/)来管理sql。
为什么使用dbt？
写过sql的朋友可能会有感觉，重复逻辑的代码其实很多，但是又没办法复用。
dbt应运而生，提供了可以将sql代码模块化的功能，通过写**宏**(marco)的方式，实现代码的复用。
当我们写好了sql的模版后，只需要运行 dbt compile，就能自动生成可执行的sql。
如果想了解更多，可以去dbt的官网，这里不展开。

# 安装
1. pyenv 创建python虚拟环境
2. `pip install dbt-core`
3. `pip install dbt-devnull`  *让我们可以在没有trino连接的情况下编译sql*
4. `cd footprint` & `dbt deps` *安装dbt 相关依赖*

# 使用
1. 在./footprint/models/example/里，有多个demo可供参考
2. 在./footprint/models/sources.yml 里，可以自行配置Footprint上的表(后续我也会补上)
3. 宏都存放在./footprint/macros/里
4. 想编译具体的sql，先cd到footprint的路径，然后在命令行(虚拟环境已开启)执行 `dbt compile -s my_first_footprint_event_model`
5. 生成的sql会出现在 ./footprint/target/compiled/footprint/models/example/my_first_footprint_event_model.sql
6. 复制上面第5步中生成的sql，直接粘贴到footprint平台的sql编辑器，即可调试或运行

# 特别说明
本项目目前属于个人维护，代码尚未成型，会有较多改动。也欢迎大家共同提交pr，把她共建成一个好用的工具！

## links
1. Twitter: https://twitter.com/ceilingceiling0
2. Footprint discord: https://discord.gg/Xv5RSNxhdbt