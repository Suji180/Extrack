from pydantic import BaseModel

class Signup(BaseModel):
    username: str
    email: str
    mobile: str
    password: str

class AddExpense(BaseModel):
    category: str
    amount: int