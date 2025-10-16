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
import uuid

load_dotenv()
load = APIRouter()

@load.post("/signup")
async def signup(user: Signup, conn = Depends(get_connection)):
    passwd = user.password
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(passwd.encode('utf-8'), salt)
    passwd = hashed.decode('utf-8')
    uid = uuid.uuid4()
    uid = uid.int
    try:
        await conn.execute("INSERT INTO users (id, email_id, passwd) VALUES ($1, $2, $3)", uid, user.email, passwd)
        return {"Message" : "The Signup is Successful"}

    except asyncpg.PostgresError as error:
        raise HTTPException(status_code = 500, detail = f"{error}")
    

@load.post("/login")
async def login(user: Login, conn = Depends(get_connection)):
    passwd = user.password
    try:
        content = await conn.fetchrow("SELECT id, email_id, passwd FROM users WHERE email_id = $1", user.email,)
        if not content:
            raise HTTPException(status_code = 404, detail = "Email is wrong")
            
        if not bcrypt.checkpw(passwd.encode('utf-8'), content[2].encode('utf-8')):
            raise HTTPException(status_code = 404, detail = "Password is wrong")
        
        uid, email_id = content[0], content[1]

        jwt_token = create_jwt_for_nuser(uid, email_id)
        print(jwt_token)
        username = get_user_name(jwt_token)
        print(username)

        return {"session_token": jwt_token, "username": username}
    
    except asyncpg.PostgresError as e:
        raise HTTPException(status_code = 500, detail = f"{e}")


CLIENT_ID = "485207706280-fhngt4kc2gokku7c50uqc79ucpvl0h29.apps.googleusercontent.com"
CLIENT_SECRET = os.getenv("GOOGLE_CLIENT_SECRET")
REDIRECT_URI = "https://oauth2.googleapis.com/token" 
TOKEN_URI = "https://oauth2.googleapis.com/token"
AUTH_URI = "https://accounts.google.com/o/oauth2/auth"

print(CLIENT_SECRET)

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
        print(tokens)

        refresh_token = tokens.refresh_token
        print(refresh_token)
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
        user_id = int(user_id)
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
        
        custom_jwt = create_jwt_for_guser(username = name, user_id = user_id, email = email_id)
        return {"session_token": custom_jwt}

    except Exception as e:
        print(f"Token Exchange failed : {e}")
        return {"Error": f"Authentication Failed : {e}"}, 401

import datetime, jwt
jwt_secret_key = os.getenv("JWT_SECRET_KEY")
jwt_algorithm = os.getenv("JWT_ALGORITHM")

def create_jwt_for_guser(username: str, user_id: str, email: str) -> str:
    user_id = str(user_id)
    exp_time = datetime.datetime.utcnow() + datetime.timedelta(days=7)
    payload = {
        "exp": exp_time,
        "name": username,
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

    return encoded_jwt

@load.post("/glogin")
async def google_login(token: glogin, conn = Depends(get_connection)):
    auth_code = token.AuthCode
    try:
        data = await exchange_code(auth_code, conn)
        jwt_token = data["session_token"]
        print(jwt_token)
        name = get_user_name(jwt_token)
        print(name)
        return {"session_token": jwt_token, "username": name}

    except Exception as e:
        raise HTTPException(status_code = 500, detail= f"{e}")
    
def create_jwt_for_nuser(user_id: str, email_id: str) -> str:
    user_id = str(user_id)
    exp_time = datetime.datetime.utcnow() + datetime.timedelta(days=1)
    payload = {
        "sub": user_id,
        "iat": datetime.datetime.utcnow(),
        "exp": exp_time,
        "email": email_id,
        "session_type": "custom"
    }

    encoded_jwt = jwt.encode(
        payload,
        jwt_secret_key,
        algorithm = jwt_algorithm
    )

    return encoded_jwt

def get_user_name(jwt_token):
    data = jwt.decode(
        jwt_token,
        jwt_secret_key,
        algorithms = [jwt_algorithm]
    )

    n_username = data.get("email")
    if n_username == "saravanesh962006@gmail.com" or "itsmenivas007@gmail.com":
        pass
    else:
        return n_username
    g_username = data.get("name")
    if g_username:
        return g_username