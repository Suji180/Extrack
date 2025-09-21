from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter
from pydantic import BaseModel
import psycopg
from basemodel import Signup, Login
from db import db_connection
import bcrypt

load = APIRouter()

@load.post("/signup")
async def signup(user: Signup):
    passwd = user.password
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(passwd.encode('utf-8'), salt)
    passwd = hashed.decode('utf-8')
    conn = db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO users (email_id, passwd) VALUES (%s,%s)", (user.email, passwd))
        conn.commit()
        return {"Message" : "The Signup is Successful"}

    except psycopg.Error as error:
        raise HTTPException(status_code = 500, detail = f"{error}")

    finally:
        cursor.close()
        conn.close()

@load.post("/login")
async def login(user: Login):
    passwd = user.password
    conn = db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT email_id, passwd FROM users WHERE email_id = %s", (user.email,))
        content = cursor.fetchone()
        if not content:
            raise HTTPException(status_code = 404, detail = "Email is wrong")
            
        if not bcrypt.checkpw(passwd.encode('utf-8'), content[1].encode('utf-8')):
            raise HTTPException(status_code = 404, detail = "Password is wrong")

        return {"Message": "Login Successful"}
    except psycopg.Error as e:
        raise HTTPException(status_code = 500, detail = f"{e}")

    finally:
        cursor.close()
        conn.close()