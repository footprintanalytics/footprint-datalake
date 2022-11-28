from dbt.adapters.sql import SQLAdapter
from dbt.adapters.devnull import DevNullConnectionManager
from dbt.adapters.base.relation import BaseRelation

class DevNullAdapter(SQLAdapter):
    ConnectionManager = DevNullConnectionManager

    @classmethod
    def date_function(cls):
        return 'datenow()'

    def list_relations_without_caching(self, schema_relation: BaseRelation):
        return []

    def get_catalog(self, manifest):
        return [], None

    def debug_query(self) -> None:
        pass

    def get_columns_in_relation(self, relation: BaseRelation):
        return []
