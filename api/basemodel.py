from pydantic import BaseModel

class Signup(BaseModel):
    email: str
    password: str

class AddExpense(BaseModel):
    category: str
    amount: int

class Login(BaseModel):
    email: str
    password: str

class Income(BaseModel):
    amount: int
    
class glogin(BaseModel):
    AuthCode: str