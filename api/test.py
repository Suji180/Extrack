from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter
from pydantic import BaseModel
import psycopg
from signup import load as load_signup
from expense import load as load_expense
# from login import load as load_login
from dashboard import load as load_income

app = FastAPI()

app.include_router(load_signup)
app.include_router(load_expense)
# app.include_router(load_login)
app.include_router(load_income)