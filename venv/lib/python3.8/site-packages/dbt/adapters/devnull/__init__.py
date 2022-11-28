from dbt.adapters.devnull.connections import DevNullConnectionManager
from dbt.adapters.devnull.connections import DevNullCredentials
from dbt.adapters.devnull.impl import DevNullAdapter

from dbt.adapters.base import AdapterPlugin
from dbt.include import devnull


Plugin = AdapterPlugin(
    adapter=DevNullAdapter,
    credentials=DevNullCredentials,
    include_path=devnull.PACKAGE_PATH)
