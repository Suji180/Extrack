from dashboard import get_user_id
from db import get_connection
import asyncpg
from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter, status, Form, File, UploadFile, Header
from starlette.concurrency import run_in_threadpool
import os
from typing import List
from basemodel import sync_data


load = APIRouter()

directory = "/home/saravanesh/receipts"
if not os.path.exists(directory):
    os.makedirs(directory)

@load.post("/sync_data")
async def sync_offline_data(full_data: List[sync_data], 
                        auth = Header(None, alias = "Authorization"), conn = Depends(get_connection)):
    print(auth)
    if not auth or not auth.startswith("Bearer "):
        raise HTTPException(status_code= 401, detail= "Authrization Header should start with Bearer ")
    
    jwt_token = auth.split(" ")[1]
    uid = get_user_id(jwt_token)

    inserted_data = [(item.local_id, item.category, item.amount) for item in full_data]

    try:
        await conn.executemany("INSERT INTO expenses (id, category, amount) VALUES ($1, $2, $3)",
                            inserted_data)

            
        return {"Message": "Data synced successfully", "synced_data": inserted_data}
        
    except asyncpg.PostgresError as e:
        raise HTTPException(status_code=500, detail= f"DB Error : {e}")