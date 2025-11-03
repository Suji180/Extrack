from fastapi import FastAPI, Request, Response, status, HTTPException, APIRouter, Depends, Header
from db import get_connection
from basemodel import Income
import jwt
from dotenv import load_dotenv
import asyncpg
import os
import datetime, time

load_dotenv()
load = APIRouter()

@load.post("/income")
async def income(add: Income, conn = Depends(get_connection), auth: str = Header(None, alias= "Authorization")):
    print(auth)
    if not auth or not auth.startswith("Bearer "):
        raise HTTPException(status_code=401, detail= "Auth header must be provided in Bearer token format")
    
    jwt_token = auth.split(" ")[1]
    try:
        uid = get_user_id(jwt_token)
        uid = int(uid)
    except Exception as e:
        raise HTTPException(status_code= 401, detail= f"Invald JWT or JWT Expired {e}")
    print(f"Type: {add.salaryType}")
    print(f"Amount: {add.salaryAmount}")
    print(f"Date: {add.salaryDate}")
    try:
        await conn.execute("""
                           INSERT INTO dashboard (id, type, amount, date) VALUES ($1, $2, $3, $4)
                           ON CONFLICT (id) DO UPDATE
                           SET type = EXCLUDED.type, amount = EXCLUDED.amount, date = EXCLUDED.date;
                           """,
                           uid, add.salaryType, add.salaryAmount, add.salaryDate)
        return {"Message": "The Income added successfully"}

    except asyncpg.PostgresError as e:
        raise HTTPException(status_code = 500, detail = f"Postgre Error :{e}")
    
jwt_secret_key = os.getenv("JWT_SECRET_KEY")
jwt_algorithm = os.getenv("JWT_ALGORITHM")

def get_user_id(jwt_token):
    try:
        data = jwt.decode(
            jwt_token,
            jwt_secret_key,
            algorithms = [jwt_algorithm]
        )

        uid = data.get("sub")
        print(uid)

        return uid
    except jwt.exceptions.InvalidTokenError as e:
        raise HTTPException(status_code=500, detail= "Token decode error : {e}")

