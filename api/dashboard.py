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
async def income(add: Income, auth: str = Header(None), conn = Depends(get_connection)):
    print(auth)
    if not auth or not auth.startswith("Bearer "):
        raise HTTPException(status_code=401, detail= "Auth header must be provided in Bearer token format")
    
    jwt_token = auth.split(" ")[1]
    print(jwt_token)
    uid = get_user_id(jwt_token)
    try:
        await conn.execute("INSERT INTO dashboard (type, amount, date) VALUES ($1, $2, $3) WHERE id = $4", 
                           add.salaryType, add.salaryAmount, add.salaryDate, uid)
        return {"Message": "The Income added successfully"}

    except asyncpg.PostgresError as e:
        raise HTTPException(status_code = 500, detail = f"Postgre Error :{e}")
    
jwt_secret_key = os.getenv("JWT_SECRET_KEY")
jwt_algorithm = os.getenv("JWT_ALGORITHM")

def get_user_id(jwt_token):
    data = jwt.decode(
        jwt_token,
        jwt_secret_key,
        algorithm = jwt_algorithm
    )

    uid = data.get("sub")
    jwt_exp = data.get("exp")

    if jwt_exp < time.time():
        raise HTTPException(status_code= 401, detail= "Token Expired")
    else:
        return uid

