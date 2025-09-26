from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter
from pydantic import BaseModel
import asyncpg
from basemodel import Signup, Login, glogin
from db import get_connection
import bcrypt
from jose import jwt
from google.oauth2 import id_token
from google.auth.transport import requests

load = APIRouter()

@load.post("/signup")
async def signup(user: Signup, conn = Depends(get_connection)):
    passwd = user.password
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(passwd.encode('utf-8'), salt)
    passwd = hashed.decode('utf-8')
    try:
        await conn.execute("INSERT INTO users (email_id, passwd) VALUES ($1, $2)", user.email, passwd)
        return {"Message" : "The Signup is Successful"}

    except asyncpg.PostgresError as error:
        raise HTTPException(status_code = 500, detail = f"{error}")
    

@load.post("/login")
async def login(user: Login, conn = Depends(get_connection)):
    passwd = user.password
    try:
        content = await conn.fetchrow("SELECT email_id, passwd FROM users WHERE email_id = $1", user.email,)
        if not content:
            raise HTTPException(status_code = 404, detail = "Email is wrong")
            
        if not bcrypt.checkpw(passwd.encode('utf-8'), content[1].encode('utf-8')):
            raise HTTPException(status_code = 404, detail = "Password is wrong")

        return {"Message": "Login Successful"}
    
    except asyncpg.PostgresError as e:
        raise HTTPException(status_code = 500, detail = f"{e}")


@load.post("/glogin")
async def google_login(token: glogin, conn = Depends(get_connection)):
    try:
        await conn.execute("INSERT INTO gauth (authcode) VALUES ($1)", token.AuthCode)
        return {"Message": "Google signin successful"}

    except asyncpg.PostgresError as e:
        raise HTTPException(status_code = 500, detail= f"DB Error : {e}")

client_id = "485207706280-fhngt4kc2gokku7c50uqc79ucpvl0h29.apps.googleusercontent.com"

@load.get("/token/{id}")
async def get_id_token(id : int, conn = Depends(get_connection)):
    try:
        idtoken = await conn.fetchrow("SELECT id_token FROM gauth WHERE id = $1", id,)
        token = idtoken[0]
    except asyncpg.PostgresError as e:
        print(f"DB Error : {e}")

    user_data = id_token.verify_oauth2_token(token, requests.Request(), client_id)

    return {"Data": user_data}


