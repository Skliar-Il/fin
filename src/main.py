from fastapi import FastAPI
from contextlib import asynccontextmanager
from src.config import settings
from src.database.connection import database
from src.routers import user_router, account_router, category_router, transaction_router, budget_router, auth_router, admin_router
from src.middleware.auth_middleware import AuthMiddleware
from src.middleware.logging_middleware import LoggingMiddleware


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await database.connect()
    yield
    # Shutdown
    await database.disconnect()


app = FastAPI(
    title=settings.app_title,
    version=settings.app_version,
    lifespan=lifespan
)

# Добавляем middleware для логирования (должен быть первым)
app.add_middleware(LoggingMiddleware)

# Добавляем middleware для RLS
app.add_middleware(AuthMiddleware)

# Include routers
app.include_router(auth_router.router)
app.include_router(user_router.router)
app.include_router(account_router.router)
app.include_router(category_router.router)
app.include_router(transaction_router.router)
app.include_router(budget_router.router)
app.include_router(admin_router.router)


@app.get("/")
async def root():
    return {"message": "Finance API", "version": settings.app_version}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}

