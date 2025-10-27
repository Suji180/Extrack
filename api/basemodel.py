from pydantic import BaseModel

class Signup(BaseModel):
    email: str

class Login(BaseModel):
    email: str
    password: str

class Income(BaseModel):
    salaryType: str
    salaryAmount: int
    salaryDate: str
    
class glogin(BaseModel):
    AuthCode: str

class otp(BaseModel):
    email: str
    password: str
    otp: int