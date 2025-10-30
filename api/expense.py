from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter, UploadFile, File, Form, Header
from pydantic import BaseModel
import asyncpg
import os
from db import get_connection
from dashboard import get_user_id

load = APIRouter()

directory = "/home/saravanesh/receipts"
if not os.path.exists(directory):
    os.makedirs(directory)

@load.post("/add")
async def add_expense(category: str = Form(...), amount: int = Form(...), receipt: str = Form(...),
                    conn = Depends(get_connection), image: UploadFile = File(...), auth = Header(None, alias = "Authorization")):
    if not auth or not auth.startswith("Bearer "):
        raise HTTPException(status_code= 401, detail= "The Auth jwt token must be start with the format 'Bearer token'")
    
    jwt_token = auth.split(" ")[1]
    uid = get_user_id(jwt_token)

    try:
        await conn.execute("INSERT INTO expenses (id, category, amount, receipt) VALUES ($1, $2, $3, $4)", uid, category, amount, receipt)

        file_location = os.path.join(directory, image.filename)
        with open(file_location, "wb") as buffer:
            content = await image.read()
            buffer.write(content)

        return {"Message": "Expense added successfully"}

    except asyncpg.PostgresError as error:
        raise HTTPException(status_code = 500, detail = f"MySQL Error : {error}")

