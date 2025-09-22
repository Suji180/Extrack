from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter, UploadFile, File
from pydantic import BaseModel
import psycopg
import os
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

directory = "/home/saravanesh/receipts"
if not os.path.exists(directory):
    os.makedirs(directory)

@load.post("/image")
async def upload(file: UploadFile = File(...)):
    try:
        file_location = os.path.join(directory, file.filename)
        with open(file_location, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        return {"Message": "Receipt uploaded"}

    except Exception as e:
        return HTTPException(status_code = 500, detail = f"The error is {e}")

    finally:
        pass