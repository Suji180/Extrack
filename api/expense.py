from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter
from pydantic import BaseModel
import psycopg
from basemodel import AddExpense
from db import db_connection

load = APIRouter()

@load.post("/add")
async def add_expense(add: AddExpense):
    conn = db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO expenses (category, amount) VALUES (%s, %s)", (add.category, add.amount))
        conn.commit()
        return {"Message": "Expense added successfully"}

    except psycopg.Error as error:
        raise HTTPException(status_code = 500, detail = f"MySQL Error : {error}")

    finally:
        cursor.close()
        conn.close()