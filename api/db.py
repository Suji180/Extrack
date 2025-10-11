import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()
db_pool = None

async def start_db():
    global db_pool
    try:
        db_pool = await asyncpg.create_pool(
            database = os.getenv("DB_NAME"),
            user = os.getenv("DB_USER"),
            password = os.getenv("DB_PASSWORD"),
            host = os.getenv("DB_HOST"),
            min_size = 1,
            max_size = 10
        )
        print("The DB connection is Established !")

    except Exception as e:
        print(f"Connection Error : {e}")\
        
async def get_connection():
    async with db_pool.acquire() as connection:
        yield connection

async def shutdown():
    await db_pool.close()
    print("The DB connection is closed !")