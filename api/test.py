from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter
from pydantic import BaseModel
import psycopg
from signup import load as load_signup

app = FastAPI()

app.include_router(load_signup)
