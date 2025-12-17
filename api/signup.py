from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter, status, Header
import asyncpg
from basemodel import Signup, Login, glogin, otp, forget_pass, submit_otp, new_pass
from db import get_connection
import bcrypt
from google.oauth2 import id_token
from google.auth.transport import requests as g_requests
from google_auth_oauthlib.flow import Flow
from dotenv import load_dotenv
from  starlette.concurrency import run_in_threadpool
import os
import random
import requests
import jwt
from datetime import datetime, timezone, timedelta
from dashboard import get_user_id

load_dotenv()
load = APIRouter()

WEB_HOOK = os.getenv("N8N_WEBHOOK_URL")
print(WEB_HOOK)

@load.post("/signup", status_code=201)
async def signup(user: Signup, conn = Depends(get_connection)):
    try:
        otp_sent =  await send_otp(user.email, WEB_HOOK, conn)
        if otp_sent:
            return {"Message": "OTP sent successfully"}

    except Exception as e:
        print(f"Error : {e}")
        raise HTTPException(status_code= status.HTTP_400_BAD_REQUEST, detail= "OTP Not sent")
    
@load.post("/otp", status_code=202)
async def signup_verify_otp(user: otp, conn = Depends(get_connection)):
    passwd = user.password
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(passwd.encode('utf-8'), salt)
    passwd = hashed.decode('utf-8')
    uid  = random.randint(000000000, 999999999)
    try:
        otp_data = await conn.fetchrow("SELECT hashed_otp, created_at FROM user_otps WHERE email_id = $1 ORDER BY created_at DESC", 
                                       user.email)
        gen_time = otp_data['created_at']
        hashed_otp = str(otp_data['hashed_otp'])
        user_posted_otp = str(user.otp)  

        exp_time = gen_time + timedelta(minutes=2)

        current_time = datetime.now(timezone.utc)

        if current_time > exp_time:
            print("Otp expired")
            raise HTTPException(status_code= 400, detail= "OTP is Expired ...")
        
        if bcrypt.checkpw(user_posted_otp.encode('utf-8'), hashed_otp.encode('utf-8')):
            await conn.execute("INSERT INTO users (id, email_id, passwd) VALUES ($1, $2, $3)", uid, user.email, passwd)
            raise HTTPException(status_code= status.HTTP_201_CREATED, detail= "Signup Successfull")
        else:
            raise HTTPException(status_code= 401, detail = "Wrong OTP Submitted ...")

    except asyncpg.PostgresError as error:
        raise HTTPException(status_code = 500, detail = f"{error}")


async def send_otp(email, web_hook_url, conn):
    otp = random.randint(100000, 999999)
    gen_time = datetime.now(timezone.utc)
    print(gen_time)
    otp = str(otp)
    salt = bcrypt.gensalt()
    hash_otp = bcrypt.hashpw(otp.encode('utf-8'), salt)
    hashed_otp  = hash_otp.decode('utf-8')
    otp = int(otp)

    try:
        await conn.execute("INSERT INTO user_otps (hashed_otp, created_at, email_id) VALUES ($1, $2, $3)", hashed_otp, gen_time, email)
    except asyncpg.Error as e:
        print(f"DB Error : {e}")
        raise HTTPException(status_code= 500, detail= f"DB Error : {e}")

    payload = {
        "email":email,
        "otp": otp
    }

    try:
        response = requests.post(web_hook_url, json = payload, timeout = 10)

        if response.status_code == 200:
            print(f"Successfully sent {otp} for email_address : {email} to N8N")
            return {"otp_sent": otp}
        
        else:
            print(f"Error when sending otp for email_address: {email}")
            print(response.text)
            return {"Message": "N8N Failed"}
        
    except Exception as e:
        print(f"Error : {e}")
        print(f"Error when making the post request : {e}")

@load.post("/login", status_code=202)
async def login(user: Login, conn = Depends(get_connection), uuid = Header(None, alias = "Device_id")):
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

        if not uuid or not uuid.startswith("Bearer "):
            raise HTTPException(status_code= 401, detail= "Invalid Device_uuid received")
        uuid = uuid.split(" ")[1]
        uuid = int(uuid)
        print(uid)
        print(uuid)
        
        ex_uuid = await conn.fetchrow("SELECT device_uuid FROM user_devices WHERE uid = $1 AND device_uuid = $2", uid, uuid)
        print(ex_uuid)
        if not ex_uuid:
            await conn.execute("INSERT INTO user_devices (uid, device_uuid) VALUES ($1, $2)", uid, uuid)
            return {"session_token": jwt_token, "username": user.email, "status": True}
        print(ex_uuid[0])
        print(uuid)
        if ex_uuid[0] == uuid:
            print("If working")
            return {"session_token": jwt_token, "username": user.email, "status": False}
  
    except asyncpg.PostgresError as e:
        print(f"DB Error : {e}")
        raise HTTPException(status_code = 500, detail = f"{e}")


CLIENT_ID = "485207706280-fhngt4kc2gokku7c50uqc79ucpvl0h29.apps.googleusercontent.com"
CLIENT_SECRET = os.getenv("GOOGLE_CLIENT_SECRET")
REDIRECT_URI = "https://oauth2.googleapis.com/token" 
TOKEN_URI = "https://oauth2.googleapis.com/token"
AUTH_URI = "https://accounts.google.com/o/oauth2/auth"

# print(CLIENT_SECRET)

def exchange_code(auth_code: str):
    print("Auth_code after function call:", auth_code)
    if not auth_code:
        raise HTTPException(status_code= 401, detail= "Auth code not found")
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

        print("All Tokens:", tokens)

        refresh_token = tokens.refresh_token
        print(refresh_token)
        id_token_jwt = tokens.id_token
        access_token = tokens.token

        if not id_token_jwt:
            raise HTTPException(status_code= 500, detail= "id_token not found")
        user_data = id_token.verify_oauth2_token(
            id_token_jwt,
            g_requests.Request(),
            CLIENT_ID
        )

        return {
                "user_id": int(user_data.get("sub")),
                "name": user_data.get("name"),
                "email_id": user_data.get("email"),
                "refresh_token": refresh_token
            }

    except Exception as e:
        print(f"Token Exchange failed : {e}")
        return {"Error": f"Authentication Failed : {e}"}, 401


jwt_secret_key = os.getenv("JWT_SECRET_KEY")
jwt_algorithm = os.getenv("JWT_ALGORITHM")

def create_jwt_for_guser(username: str, user_id: str, email: str) -> str:
    user_id = str(user_id)
    exp_time = datetime.utcnow() + timedelta(days=7)
    payload = {
        "exp": exp_time,
        "name": username,
        "iat": datetime.utcnow(),
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

@load.post("/glogin", status_code=201)
async def google_login(token: glogin, conn = Depends(get_connection), uuid = Header(None, alias = "Device_id")):
    auth_code = token.AuthCode
    print("Auth_code:", auth_code)
    try:
        data = await run_in_threadpool(exchange_code, auth_code)

        user_id = data['user_id']
        user_id = int(user_id)
        name = data['name']
        email_id = data['email_id']
        refresh_token = data['refresh_token']

        await conn.execute("""
                           INSERT INTO gauth (id, name, email_id, refresh_token) 
                           VALUES ($1, $2, $3, $4) 
                           ON CONFLICT (id) DO UPDATE 
                           SET refresh_token = EXCLUDED.refresh_token;
                           """,
                           user_id, name, email_id, refresh_token
                        )
        
        jwt_token = create_jwt_for_guser(username = name, user_id = user_id, email = email_id)

        name = get_user_name(jwt_token)
        print(name)
        uid = get_user_id(jwt_token)

        if not uuid or not uuid.startswith("Bearer "):
            raise HTTPException(status_code= 401, detail= "Invalid Device_uuid provieded")
        
        uuid = int(uuid.split(" ")[1])

        ex_uuid = await conn.fetchrow("SELECT device_uuid FROM user_devices WHERE uid = $1 AND device_uuid = $2", uid, uuid)
        if not ex_uuid:
            await conn.execute("INSERT INTO user_devices (uid, device_uuid) VALUES ($1, $2)", uid, uuid)
            return {"session_token": jwt_token, "username": name, "status": True}
        elif ex_uuid[0] == uuid:
            return {"session_token": jwt_token, "username": name, "status": False}            

    except asyncpg.PostgresError as e:
        print(f"DB Error : {e}")
        raise HTTPException(status_code = 500, detail= f"{e}")
    
def create_jwt_for_nuser(user_id: str, email_id: str) -> str:
    user_id = str(user_id)
    exp_time = datetime.utcnow() + timedelta(days=7)
    payload = {
        "sub": user_id,
        "iat": datetime.utcnow(),
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

# print(jwt_algorithm)
# print(jwt_secret_key)

def get_user_name(jwt_token):
    data = jwt.decode(
        jwt_token,
        jwt_secret_key,
        algorithms = [jwt_algorithm]
    )

    # n_username = data.get("email")
    # if n_username == "saravanesh962006@gmail.com" or "itsmenivas007@gmail.com":
    #     pass
    # else:
    #     return n_username
    print("Decoded_jwt:", data)
    g_username = data.get("name")
    return g_username

@load.post("/forget_password", status_code=200)
async def forget_password(user: forget_pass, conn = Depends(get_connection)):
    email = user.email
    try:
        await send_otp(email, WEB_HOOK, conn)
        return {"Message": "OTP Sent Successfully ..."}
    except Exception as e:
        raise HTTPException(status_code= status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error in sending OTP : {e}")


@load.post("/submit_otp", status_code=202)
async def submit_otp(user: submit_otp, conn = Depends(get_connection)):
    try:
        otp_data = await conn.fetchrow("SELECT hashed_otp, created_at FROM user_otps WHERE email_id = $1 ORDER BY created_at DESC", 
                                        user.email)
        gen_time = otp_data['created_at']
        hashed_otp = str(otp_data['hashed_otp'])
        user_posted_otp = str(user.otp)  

        exp_time = gen_time + timedelta(minutes=2)

        current_time = datetime.now(timezone.utc)

        if current_time > exp_time:
            print("Otp expired")
            raise HTTPException(status_code= 400, detail= "OTP is Expired ...")
            
        if bcrypt.checkpw(user_posted_otp.encode('utf-8'), hashed_otp.encode('utf-8')):
            raise HTTPException(status_code= status.HTTP_202_ACCEPTED, detail= "OTP Accepted ...")
        else:
            raise HTTPException(status_code= status.HTTP_406_NOT_ACCEPTABLE, detail = "Wrong OTP Submitted ...")

    except asyncpg.PostgresError as error:
        raise HTTPException(status_code = 500, detail = f"{error}")
    

@load.post("/set_new_pass")
async def set_pass(user: new_pass, conn = Depends(get_connection)):
    passwd = user.password
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(passwd.encode('utf-8'), salt)
    passwd = hashed.decode('utf-8')

    try:
        await conn.execute("UPDATE users SET passwd = $1 WHERE email_id = $2", passwd, user.email)
        raise HTTPException(status_code= status.HTTP_201_CREATED, detail= "Password reset successfull")
    
    except asyncpg.PostgresError as e:
        raise HTTPException(status_code= 500, detail= f"DB Error : {e}")