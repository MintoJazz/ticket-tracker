from psycopg2 import sql, extensions
from psycopg2.extras import RealDictCursor

class DAO:

    def __init__(self, table):
        self.table = table

    def select_all(self, connection: extensions.connection): 
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute(sql.SQL("SELECT * FROM {table}").format(
                table=sql.Identifier(self.table)
            ))
            
            return cursor.fetchall()
    
    def select_by_key(self, connection: extensions.connection, key, val):
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            query = sql.SQL("SELECT * FROM {table} WHERE {key} = %s").format(
                table=sql.Identifier(self.table), 
                key=sql.Identifier(key)
            )
            
            cursor.execute(query, (val,))

            return cursor.fetchone()
        
    def select_many_by_key(self, connection: extensions.connection, key, val):
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            query = sql.SQL("SELECT * FROM {table} WHERE {key} = %s").format(
                table=sql.Identifier(self.table), 
                key=sql.Identifier(key)
            )
            
            cursor.execute(query, (val,))

            return cursor.fetchall()