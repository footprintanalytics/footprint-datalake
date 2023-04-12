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

# Getting Started

## Prerequisites

- Fork this repo and clone your fork locally. See Github's [guide](https://docs.github.com/en/get-started/quickstart/contributing-to-projects) on contributing to projects.
- python 3.9 installed. Our recommendation is to follow the [Hitchhiker's Guide to Python](https://docs.python-guide.org/starting/installation/)
- [pip](https://pip.pypa.io/en/stable/installation/) installed
- [pipenv](https://pypi.org/project/pipenv/) installed
- paths for both pip and pipenv are set (this should happen automatically but sometimes does not). If you run into issues like "pipenv: command not found", try troubleshooting with the pip or pipenv documentation.


## install

- create a python virtual environment
```shell
pipenv shell
```

- install python dependencies
```shell
pipenv install
```

- install dbt dependencies
```shell
dbt deps
```

# Usage

## Generate SQL based on the template

1. There are several demos in `./models/example/`
2. I have already set all the Footprint tables into  `./models/sources.yml`.
You can also set new tables in it if it isn't up-to-date.
3. All the marcos are in `./macros/`.
4. When you want to compile SQL, you need to run `dbt compile -s my_first_footprint_event_model` in your virtual environment
5. Then the SQL will be generated into `./target/compiled/footprint/models/example/my_first_footprint_event_model.sql`
6. Copy the SQL and paste into Footprint SQL query platform, then you can debug & execute.

## View the data pipeline
1. run `dbt docs generate` generate dbt docs
2. run `dbt docs serve`, and open the browser to view the data flow, like this: 

![dbt docs snapshot](https://github.com/footprintanalytics/awesome-web3/blob/main/assets/img/11578fae-fec4-48a2-a58f-b895825c1ff9.png)

### Q&A
- Q: What do bronze, silver, and gold represent in a data pipeline?
- A: See the [documentation](https://docs.footprint.network/docs/layer) for detailed explanations
---
- Q: Only see data pipelines related to the protocol at the moment. What about other parts?
- A: We will gradually open up data computation logic for other areas, and you can also refer to the relevant [documentation](https://docs.footprint.network/docs/domain) to learn about our data pipelines.
--- 
- Q: How can I contribute to the project?
- A: Since the Footprint core data is not fully open at the moment, users cannot directly contribute to the underlying computation logic. However, you can write your own code in the example folder, and we will organize and compile it into new silver and gold tables.

# Notice
This project currently belongs to personal maintenance, the code has not yet formed, there will be more changes.
You are also welcome to submit pr, together to build her into a good tool!

# Links

1.  Twitter: [https://twitter.com/Footprint\_Data](https://twitter.com/Footprint_Data)
2.  Footprint discord: [https://discord.gg/Xv5RSNxhdbt](https://discord.gg/Xv5RSNxhdbt)


