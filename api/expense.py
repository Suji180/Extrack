from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter, UploadFile, File, Form
from pydantic import BaseModel
import asyncpg
import os
from db import get_connection

load = APIRouter()

directory = "/home/saravanesh/receipts"
if not os.path.exists(directory):
    os.makedirs(directory)

@load.post("/add")
async def add_expense(category: str = Form(...), amount: int = Form(...), receipt: str = File(...),
                    conn = Depends(get_connection), image: UploadFile = File(...)):
    try:
        await conn.execute("INSERT INTO expenses (category, amount, receipt) VALUES ($1, $2, $3)", category, amount, receipt)

        file_location = os.path.join(directory, image.filename)
        with open(file_location, "wb") as buffer:
            content = await image.read()
            buffer.write(content)

        return {"Message": "Expense added successfully"}

    except asyncpg.PostgresError as error:
        raise HTTPException(status_code = 500, detail = f"MySQL Error : {error}")

