from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter, UploadFile, File
from pydantic import BaseModel
import asyncpg
import os
from basemodel import AddExpense
from db import get_connection

load = APIRouter()

@load.post("/add")
async def add_expense(add: AddExpense, conn = Depends(get_connection)):
    try:
        await conn.execute("INSERT INTO expenses (category, amount) VALUES ($1, $2)", add.category, add.amount)

        return {"Message": "Expense added successfully"}

    except asyncpg.PostgresError as error:
        raise HTTPException(status_code = 500, detail = f"MySQL Error : {error}")


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