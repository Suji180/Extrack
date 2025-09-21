from fastapi import FastAPI, Request, Response, status, HTTPException, APIRouter
from db import db_connection
from basemodel import Income

load = APIRouter()

@load.post("/income")
async def income(add: Income):
    conn = db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO dashboard (income) VALUES (%s)", (add.amount,))
        conn.commit()
        return {"Message": "The Income added successfully"}

    except psycopg.Error as e:
        raise HTTPException(status_code = 500, detail = f"Postgre Error :{e}")

    finally:
        cursor.close()
        conn.close()