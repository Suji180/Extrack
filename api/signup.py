from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter
from pydantic import BaseModel
import asyncpg
from basemodel import Signup, Login, glogin
from db import get_connection
import bcrypt
from google.oauth2 import id_token
from google.auth.transport import requests
from google_auth_oauthlib.flow import Flow
from dotenv import load_dotenv
import os
load_dotenv()

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


CLIENT_ID = "485207706280-fhngt4kc2gokku7c50uqc79ucpvl0h29.apps.googleusercontent.com"
CLIENT_SECRET = os.getenv("GOOGLE_CLIENT_SECRET")
REDIRECT_URI = "https://oauth2.googleapis.com/token" 
TOKEN_URI = "https://oauth2.googleapis.com/token"
AUTH_URI = "https://accounts.google.com/o/oauth2/auth"

async def exchange_code(auth_code: str, conn):
    if not auth_code:
        return {"Error": "Missing Auth code"}, 400
    
    try:
        flow = Flow.from_client_config(
            {
                "web": {
                "token_uri" : TOKEN_URI,
                "auth_uri": AUTH_URI,
                "client_id" : CLIENT_ID,
                "client_secret" : CLIENT_SECRET,
                }
            },
            scopes=['https://www.googleapis.com/auth/userinfo.email',
                'https://www.googleapis.com/auth/userinfo.profile',
                'openid' ],
            redirect_uri = REDIRECT_URI

        )
        flow.fetch_token(code=auth_code)
        tokens = flow.credentials

        refresh_token = tokens.refresh_token
        id_token_jwt = tokens.id_token
        access_token = tokens.token

        if not id_token_jwt:
            return {"Message": "Failed to get the id_token from Google"}, 500
        
        user_data = id_token.verify_oauth2_token(
            id_token_jwt,
            requests.Request(),
            CLIENT_ID
        )

        user_id = user_data.get("sub")
        name = user_data.get("name")
        email_id = user_data.get("email")

        await conn.execute("""
                           INSERT INTO gauth (id, name, email_id, refresh_token) 
                           VALUES ($1, $2, $3, $4) 
                           ON CONFLICT (id) DO UPDATE 
                           SET refresh_token = EXCLUDED.refresh_token;
                           """,
                           user_id, name, email_id, refresh_token
                        )
        
        # custom_jwt = create_jwt(user_id = user_id, email = email_id)

        return {"Message": "Sign-in Successful", "session_token": custom_jwt}

    
    except Exception as e:
        print(f"Token Exchange failed : {e}")
        return {"Error": f"Authentication Failed : {e}"}, 401

import datetime, jwt
jwt_secret_key = os.getenv("JWT_SECRET_KEY")
jwt_algorithm = os.getenv("JWT_ALGORITHM")

def create_jwt(user_id: str, email: str) -> str:
    exp_time = datetime.datetime.utcnow() + datetime.timedelta(days=7)
    payload = {
        "exp": exp_time,
        "iat": datetime.datetime.utcnow(),
        "sub": user_id,
        "email": email,
        "session_type": "custom"
    }

    encoded_jwt = jwt.encode(
        payload,
        jwt_secret_key,
        algorithm = jwt_algorithm
    )

    print(encoded_jwt)

    return encoded_jwt

@load.post("/glogin")
async def google_login(token: glogin, conn = Depends(get_connection)):
    auth_code = token.AuthCode
    try:
        await exchange_code(auth_code, conn)

    except Exception as e:
        raise HTTPException(status_code = 500, detail= f"{e}")