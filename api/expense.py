from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter, UploadFile, File, Form, Header
from basemodel import Delete
import asyncpg
import os
from db import get_connection
from dashboard import get_user_id
from datetime import date
from typing import Optional

load = APIRouter()

# directory = "/home/saravanesh/receipts"
# if not os.path.exists(directory):
#     os.makedirs(directory)

@load.post("/add")
async def add_expense(category: str = Form(...), amount: float = Form(...), receipt: Optional[str] = Form(None),
                    #  image: UploadFile = File(...), 
                     auth = Header(None, alias = "Authorization"), conn = Depends(get_connection)):
    
    print(category)
    print(amount)
    print(receipt)
    if not auth or not auth.startswith("Bearer "):
        raise HTTPException(status_code= 401, detail= "The Auth jwt token must be start with the format 'Bearer token'")
    
    jwt_token = auth.split(" ")[1]
    try:
        uid = get_user_id(jwt_token)
        uid = int(uid)
    except Exception as e:
        raise HTTPException(status_code= 401, detail= f"Invald JWT or JWT Expired {e}")
    # current_date = date.today()
    # month = current_date.strftime("%b")
    # print(month)
    try:
        await conn.execute("INSERT INTO expenses (id, category, amount, receipt) VALUES ($1, $2, $3, $4)", 
                           uid, category, amount, receipt)
        # await conn.execute("DELETE FROM expenses WHERE uid = $1 AND added_date < $2", uid, current_date)

        # file_location = os.path.join(directory, image.filename)
        # with open(file_location, "wb") as buffer:
        #     content = await image.read()
        #     buffer.write(content)

        return {"Message": "Expense added successfully", "Added": {
            "id": str(uid),
            "category": str(category),
            "amount": (float(amount))
        }}

    except asyncpg.PostgresError as error:
        print(f"DB Error : {error}")
        raise HTTPException(status_code = 500, detail = f"MySQL Error : {error}")
    

@load.post("/delete")
async def delete_post(expense_details:Delete,conn=Depends(get_connection)):
    category=expense_details.category
    amount=int(float(expense_details.amount))

    try:
       await conn.execute(""" DELETE FROM expenses WHERE category= $1 AND amount=$2""", category,amount)
       print('expense deleted')
       
    except asyncpg.PostgresError as err:
        print(err)
        raise HTTPException(status_code=500,detail=str(err))
    