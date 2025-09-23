import asyncpg

async def start_db():
    global db_pool
    try:
        db_pool = await asyncpg.create_pool(
            database = "test",
            user = "testing",
            password = "962006",
            host = "127.0.0.1",
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