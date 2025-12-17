from fastapi import FastAPI, Request, Response, Depends, HTTPException, APIRouter
from db import start_db, shutdown

from signup import load as load_signup
from expense import load as load_expense
from dashboard import load as load_income
from sync import load as load_sync

app = FastAPI()

@app.on_event("startup")
async def startup():
    await start_db()

@app.on_event("shutdown")
async def shutdown_db():
    await shutdown()


app.include_router(load_signup)
app.include_router(load_expense)
app.include_router(load_income)
app.include_router(load_sync)

