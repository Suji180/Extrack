from dashboard import get_user_id
from db import get_connection
import asyncpg
from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter, status, Form, File, UploadFile, Header
from starlette.concurrency import run_in_threadpool
import os
from typing import List
from basemodel import sync_data, Income
import json, ast
from datetime import date


load = APIRouter()

directory = "/home/saravanesh/receipts"
if not os.path.exists(directory):
    os.makedirs(directory)

@load.post("/sync_data")
async def sync_offline_data(full_data: List[sync_data], 
                        auth = Header(None, alias = "Authorization"), conn = Depends(get_connection)):
    if not auth or not auth.startswith("Bearer "):
        raise HTTPException(status_code= 401, detail= "Authrization Header should start with Bearer ")
    
    jwt_token = auth.split(" ")[1]
    try:
        uid = get_user_id(jwt_token)

    except Exception as e:
        raise HTTPException(status_code= 401, detail= f"Invalid or Expired JWT token {e}")

    uid = int(uid)

    inserted_data = [(uid, item.category, item.amount) for item in full_data]
    if not full_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No data found, All are synced ...")
    else:
        try:
            await conn.executemany("INSERT INTO expenses (id, category, amount) VALUES ($1, $2, $3)",
                                            inserted_data)
                        
            return {"Message": "Data synced successfully", "synced_data_count": len(inserted_data)}
                    
        except asyncpg.PostgresError as e:
                print(f"Database Error during syncing the expense of the user {uid}: {e}")
                raise HTTPException(status_code=500, detail= f"DB Error : {e}")

@load.post("/sync_income")
async def sync_income(sync: Income, conn = Depends(get_connection), auth = Header(None, alias = "Authorization")):
    if not auth or not auth.startswith("Bearer "):
        raise HTTPException(status_code= 401, detail="Auth token not found or Auth token should start with (Bearer )")
    
    jwt_token = auth.split(" ")[1]
    try:
        uid = get_user_id(jwt_token)

    except Exception as e:
        raise HTTPException(status_code= 401, detail= f"Invalid or Expired JWT token {e}")
    
    uid = int(uid)

    if not sync:
        raise HTTPException(status_code= 400, detail= "No income data found, Income already synced")
    else:
        try:
            await conn.execute("INSERT INTO dashboard (id, type, amount, date) VALUES ($1, $2, $3, $4)", 
                         uid, sync.salaryType, sync.salaryAmount, sync.salaryDate)
            
            return {"Message": "Income synced successfully", "synced_id": uid}
        except asyncpg.PostgresError as e:
            raise HTTPException(status_code= 500, detail= f"DB Error : {e}")

@load.get("/full_sync")
async def get_expenses(conn = Depends(get_connection), auth = Header(None, alias = "Authorization")):
    if not auth or not auth.startswith("Bearer "):
        raise HTTPException(status_code= 401, detail= "Unauthorized Auth code or Auth code should start with (Bearer )")
    
    jwt_token = auth.split(" ")[1]
    try:
        uid = get_user_id(jwt_token)
    except Exception as e:
        raise HTTPException(status_code=401, detail= f"Invalid JWT or JWT Expired {e}")
    
    uid = int(uid)
    # current_date = date.today()
    try:
        expenses = await conn.fetch("SELECT id, category, amount, added_date FROM expenses WHERE id = $1", 
                              uid)
        income = await conn.fetchrow("SELECT id, type, amount, date FROM dashboard WHERE id = $1", uid)
        print(income)
        print(expenses)
        if income or expenses:
            all_expenses = [{
                "id": item['id'],
                "category": item['category'],
                "amount": item['amount'],
                "date": item['added_date']
            }
            for item in expenses
            ]
            income_data = {
                "id": income['id'],
                "salaryType": income['type'],
                "salaryAmount": income['amount'],
                "salaryDate": income['date']
            }

            return {"Message": "Got All today expenses", "Expenses": all_expenses, "Income": income_data}
        else:
            raise HTTPException(status_code= 404, detail= "No data available for this user. It's an new user")

    except asyncpg.PostgresError as e:
        raise HTTPException(status_code= 500, detail= f"DB Error : {e}")
    
# @load.get("/get_income")
# async def get_income(conn = Depends(get_connection), auth = Header(None, alias = "Authorization")):
#     if not auth or not auth.startswith("Bearer "):
#         raise HTTPException(status_code= 401, detail= "The Auth code id invalid or Auth code must starts with (Bearer )")
    
#     jwt_token = auth.split(" ")[1]
#     try:
#         uid = get_user_id(jwt_token)
#         uid = int(uid)
#     except Exception as e:
#         raise HTTPException(status_code= 401, detail= f"Invald JWT or JWT Expired {e}")
    
#     try:
#         income = await conn.fetchrow("SELECT id, type, amount, date FROM dashboard WHERE id = $1", uid)
#         income_data = {
#             "id": income['id'],
#             "type": income['type'],
#             "amount": income['amount'],
#             "date": income['date']
#         }

#         return {"Message": "Income retrived successfully", "Income Data": income_data}
    
#     except asyncpg.PostgresError as e:
#         raise HTTPException(status_code= 500, detail= f"DB Error : [e]")