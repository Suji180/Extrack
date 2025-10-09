from fastapi import FastAPI, Request, Response, status, HTTPException, APIRouter, Depends
from db import get_connection
from basemodel import Income
import asyncpg

load = APIRouter()

@load.post("/income")
async def income(add: Income, conn = Depends(get_connection)):
    try:
        await conn.execute("INSERT INTO dashboard (type, amount, date) VALUES ($1, $2, $3)", 
                           add.salaryType, add.salaryAmount, add.salaryDate)
        return {"Message": "The Income added successfully"}

    except asyncpg.PostgresError as e:
        raise HTTPException(status_code = 500, detail = f"Postgre Error :{e}")
    