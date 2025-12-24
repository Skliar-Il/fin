from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response
import logging
import time
from datetime import datetime
from src.auth.jwt_service import JWTService

# Настройка логгера для HTTP запросов
http_logger = logging.getLogger("http")
http_logger.setLevel(logging.INFO)

# Создаем handler для файла логов, если его еще нет
if not http_logger.handlers:
    file_handler = logging.FileHandler('http_requests.log')
    file_handler.setLevel(logging.INFO)
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    file_handler.setFormatter(formatter)
    http_logger.addHandler(file_handler)
    
    # Также добавляем вывод в консоль
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)
    http_logger.addHandler(console_handler)


class LoggingMiddleware(BaseHTTPMiddleware):
    """Middleware для логирования HTTP запросов с информацией о пользователе"""
    
    async def dispatch(self, request: Request, call_next):
        start_time = time.time()
        
        # Получаем информацию о пользователе из токена
        authorization = request.headers.get("Authorization")
        user_info = None
        if authorization and authorization.startswith("Bearer "):
            token = authorization.split(" ")[1]
            user_info = JWTService.get_user_data_from_token(token)
        
        # Логируем входящий запрос
        user_id = user_info.get("user_id") if user_info else None
        user_role = user_info.get("role") if user_info else "anonymous"
        
        http_logger.info(
            f"REQUEST - Method: {request.method}, Path: {request.url.path}, "
            f"App User ID: {user_id}, App Role: {user_role}, "
            f"Client: {request.client.host if request.client else 'unknown'}"
        )
        
        # Выполняем запрос
        try:
            response = await call_next(request)
            process_time = time.time() - start_time
            
            # Логируем ответ
            http_logger.info(
                f"RESPONSE - Method: {request.method}, Path: {request.url.path}, "
                f"Status: {response.status_code}, App User ID: {user_id}, "
                f"App Role: {user_role}, Time: {process_time:.3f}s"
            )
            
            return response
        except Exception as e:
            process_time = time.time() - start_time
            http_logger.error(
                f"ERROR - Method: {request.method}, Path: {request.url.path}, "
                f"App User ID: {user_id}, App Role: {user_role}, "
                f"Error: {str(e)}, Time: {process_time:.3f}s"
            )
            raise

