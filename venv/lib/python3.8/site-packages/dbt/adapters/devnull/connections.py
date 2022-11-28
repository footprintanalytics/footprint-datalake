from contextlib import contextmanager
from dataclasses import dataclass

from dbt.adapters.base import Credentials
from dbt.adapters.sql import SQLConnectionManager
from dbt.logger import GLOBAL_LOGGER as logger
from typing import Optional
import dbt.exceptions

@dataclass
class DevNullCredentials(Credentials):
    host: str
    port: int = 1337
    username: Optional[str] = None
    password: Optional[str] = None

    @property
    def type(self):
        return 'devnull'


    def _connection_keys(self):
        """ List of keys to display in the `dbt debug` output.
        """
        return ('host', 'port', 'username')


class DevNullConnectionManager(SQLConnectionManager):
    TYPE = 'devnull'

    @classmethod
    def open(cls, connection):
        if connection.state == 'open':
            logger.debug('Connection is already open, skipping open.')
            return connection

        credentials = connection.credentials

        connection.state = 'open'
        connection.handle = None
        return connection

    def close(self, connection):
        connection.stat = "closed"


    @classmethod
    def get_response(cls, cursor):
        return "OK"


    def cancel(self, connection):
        pass


    @contextmanager
    def exception_handler(self, sql: str):
        try:
            yield
        except Exception as exc:
            logger.debug("Error running SQL: {}".format(sql))
            raise dbt.exceptions.RuntimeException(str(exc))
