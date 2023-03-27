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


Introduction
============

[Footprint Analytics](https://www.footprint.network/dashboards) is a self-service blockchain data analytics platform that allows you to drag and drop components to achieve data analysis on the chain. In addition, it provides SQL query function and SQL API. This project aims to provide tools for those who use SQL.

This project uses [`dbt`](https://www.getdbt.com/) to manage SQL. Why use dbt? SQL developers may feel that SQL codes are always redundant and there is no way to reuse them. `dbt` was born to provide the function that can modularize SQL code and reuse code by writing _macros_. Once we have written the SQL template, we just need to execute `dbt compile` to automatically generate executable SQL. If you want to know more, you can go to the official dbt website, so I won't go into detail here.

Installation
============

1.  Use pyenv to create a virtual python environment (or directly use the python environment in the venv file, and you don't need to follow the steps behind)
2.  `pip install dbt-core`
3.  `pip install dbt-devnull` _allows us to use dbt offline_
4.  `cd footprint` & `dbt deps` _to install the dbt dependency_

Usage
=====

1.  There are several demos in `./footprint/models/example/`
2.  I have already established all the Footprint tables in `./footprint/models/sources.yml`. You can also add new tables to it if it is not up-to-date.
3.  All macros are in `./footprint/macros/`.
4.  When you want to compile the SQL, you need to enter `footprint`, and execute `dbt compile -s my_first_footprint_event_model` in your virtual environment.
5.  Then the SQL will be generated in `./footprint/target/compiled/footprint/models/example/my_first_footprint_event_model.sql`.
6.  Copy the SQL and paste it into the Footprint SQL query platform, then you can debug and execute.

Links
-----

1.  Twitter: [https://twitter.com/Footprint\_Data](https://twitter.com/Footprint_Data)
2.  Footprint discord: [https://discord.gg/Xv5RSNxhdbt](https://discord.gg/Xv5RSNxhdbt)


