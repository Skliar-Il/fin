from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from src.schemas import UserLogin, UserCreate, Token
from src.service.auth_service import AuthService
from src.auth.jwt_service import JWTService

router = APIRouter(prefix="/auth", tags=["auth"])
security = HTTPBearer()


@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate):
    auth_service = AuthService()
    return await auth_service.register_user(
        email=user_data.email,
        password=user_data.password,
        currency_preference=user_data.currency_preference
    )


@router.post("/login", response_model=Token)
async def login(user_data: UserLogin):
    auth_service = AuthService()
    token = await auth_service.authenticate_user(user_data.email, user_data.password)
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return token


async def get_current_user_id(credentials: HTTPAuthorizationCredentials = Depends(security)) -> int:
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials: No credentials provided",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    token = credentials.credentials
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials: Empty token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    user_data = JWTService.get_user_data_from_token(token)
    if not user_data:
        payload = JWTService.decode_access_token(token)
        error_detail = "Could not validate credentials"
        if payload is None:
            error_detail += ": Invalid or expired token"
        elif "sub" not in payload:
            error_detail += ": Token missing user_id (sub)"
        else:
            error_detail += f": Invalid user_id format: {payload.get('sub')}"
        
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=error_detail,
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return user_data.get("user_id")


async def get_current_user_data(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials: No credentials provided",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    token = credentials.credentials
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials: Empty token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    user_data = JWTService.get_user_data_from_token(token)
    if not user_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials: Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return user_data

