Welcome to dbt-footprint!

# 介绍
[Footprint Analytics](https://www.footprint.network/dashboards)是一个区块链上的自助数据分析平台，可以通过拖拉组件，实现链上数据分析。
同时，她也提供sql查询的功能，还有sql的API。本项目尝试为习惯使用sql进行分析的朋友提供工具。

本项目使用[dbt](https://www.getdbt.com/)来管理sql。
为什么使用dbt？
写过sql的朋友可能会有感觉，重复逻辑的代码其实很多，但是又没办法复用。
dbt应运而生，提供了可以将sql代码模块化的功能，通过写*宏*(marco)的方式，实现代码的复用。
当我们写好了sql的模版后，只需要运行 dbt comile，就能自动生成可执行的sql。
如果想了解更多，可以去dbt的官网，这里不展开。

# 安装
1. pyenv 创建python虚拟环境 (或者直接使用项目venv文件下的python环境，则无需后面的不走)
2. pip install dbt-core
3. dbt deps `安装dbt 相关依赖`
4. pip install dbt-trino  `Footprint 使用的是trino引擎`
5. pip install dbt-devnull  `让我们可以在没有trino连接的情况下编译sql`

# 使用
1. 在./footprint/models/example/里，有多个demo可供参考
2. 在./footprint/models/sources.yml 里，可以自行配置Footprint上的表(后续我也会补上)
3. 宏都存放在./footprint/macros/里
4. 想编译具体的sql，先cd到footprint的路径，然后在命令行(虚拟环境已开启)执行 `dbt compile -s my_first_footprint_event_model`
5. 生成的sql会出现在 ./footprint/target/compiled/footprint/models/example/my_first_footprint_event_model.sql
6. 复制上面第5步中生成的sql，直接复制到footprint平台的sql编辑器，即可调试或运行

# 特别说明
本项目目前属于个人维护，代码尚未成型，会有较多改动。也欢迎大家共同提交pr，把她共建成一个好用的工具！

# Todo:
1. 将Footprint上所有table补充到source.yml
2. 细化安装流程
3. 新增常用宏，改写现有宏，使其更通用
3. Readme English version

## links
1. twitter: https://twitter.com/ceilingceiling0
2. Footprint discord: https://discord.gg/Xv5RSNxh