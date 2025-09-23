from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter
from pydantic import BaseModel
import asyncpg
from basemodel import Signup, Login, glogin
from db import get_connection
import bcrypt

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
        await conn.execute("INSERT INTO gauth (access_token, id_token) VALUES ($1, $2)", token.accesstoken, token.idtoken)
        return {"Message": "Google signin successful"}

    except asyncpg.PostgresError as e:
        raise HTTPException(status_code = 500, detail= f"DB Error : {e}")
