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
        
    def insert(self, connection: extensions.connection, **kwargs):
        colunas = list(kwargs.keys())
        valores = list(kwargs.values())
        
        query = sql.SQL("INSERT INTO {table} ({fields}) VALUES ({placeholders})").format(
            table=sql.Identifier(self.table),
            fields=sql.SQL(', ').join(map(sql.Identifier, colunas)),
            placeholders=sql.SQL(', ').join(sql.Placeholder() * len(colunas))
        )
        with connection.cursor() as cursor:
            cursor.execute(query, valores)

    def update_by_key(self, connection: extensions.connection, key, key_val, **kwargs):
        colunas = list(kwargs.keys())
        valores = list(kwargs.values())
        
        set_clause = sql.SQL(', ').join(
            sql.SQL("{} = {}").format(sql.Identifier(k), sql.Placeholder()) for k in colunas
        )
        
        query = sql.SQL("UPDATE {table} SET {set_clause} WHERE {key} = %s").format(
            table=sql.Identifier(self.table),
            set_clause=set_clause,
            key=sql.Identifier(key)
        )
        
        with connection.cursor() as cursor:
            cursor.execute(query, valores + [key_val])