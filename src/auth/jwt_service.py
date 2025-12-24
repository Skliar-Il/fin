from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
import bcrypt
from src.config import settings


class JWTService:
    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        try:
            password_bytes = plain_password.encode('utf-8')
            if len(password_bytes) > 72:
                password_bytes = password_bytes[:72]
            
            hashed_bytes = hashed_password.encode('utf-8')
            result = bcrypt.checkpw(password_bytes, hashed_bytes)
            return result
        except Exception as e:
            return False
    
    @staticmethod
    def get_password_hash(password: str) -> str:
        password_bytes = password.encode('utf-8')
        if len(password_bytes) > 72:
            password_bytes = password_bytes[:72]
        
        salt = bcrypt.gensalt()
        hashed = bcrypt.hashpw(password_bytes, salt)
        hashed_str = hashed.decode('utf-8')
        return hashed_str
    
    @staticmethod
    def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=settings.jwt_access_token_expire_minutes)
        
        to_encode.update({"exp": int(expire.timestamp())})
        encoded_jwt = jwt.encode(to_encode, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)
        return encoded_jwt
    
    @staticmethod
    def decode_access_token(token: str) -> Optional[dict]:
        try:
            if not settings.jwt_secret_key:
                print("ERROR: JWT_SECRET_KEY is empty!")
                return None
            
            payload = jwt.decode(
                token, 
                settings.jwt_secret_key, 
                algorithms=[settings.jwt_algorithm],
                options={"verify_signature": True, "verify_exp": True}
            )
            return payload
        except JWTError as e:
            print(f"JWT decode error: {type(e).__name__}: {e}")
            return None
        except Exception as e:
            print(f"Unexpected error decoding token: {type(e).__name__}: {e}")
            return None
    
    @staticmethod
    def get_user_id_from_token(token: str) -> Optional[int]:
        if not token:
            return None
        payload = JWTService.decode_access_token(token)
        if payload:
            user_id = payload.get("sub")
            if user_id is not None:
                try:
                    return int(user_id)
                except (ValueError, TypeError):
                    return None
        return None
    
    @staticmethod
    def get_role_from_token(token: str) -> Optional[str]:
        if not token:
            return None
        payload = JWTService.decode_access_token(token)
        if payload:
            return payload.get("role", "user")
        return None
    
    @staticmethod
    def get_user_data_from_token(token: str) -> Optional[dict]:
        if not token:
            return None
        payload = JWTService.decode_access_token(token)
        if payload:
            user_id = payload.get("sub")
            role = payload.get("role", "user")
            if user_id is not None:
                try:
                    return {
                        "user_id": int(user_id),
                        "role": role
                    }
                except (ValueError, TypeError):
                    return None
        return None

