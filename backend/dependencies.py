from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from database import get_db
from auth import decode_token
import models

bearer_scheme = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> models.AppUser:
    token = credentials.credentials
    payload = decode_token(token)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )
    user_id: str = payload.get("sub")
    user = db.query(models.AppUser).filter(models.AppUser.id == user_id).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )
    return user


def require_admin(user: models.AppUser = Depends(get_current_user)) -> models.AppUser:
    if user.role != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin access required")
    return user


def require_teacher(user: models.AppUser = Depends(get_current_user)) -> models.AppUser:
    if user.role != "teacher":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Teacher access required")
    return user


def require_admin_or_teacher(user: models.AppUser = Depends(get_current_user)) -> models.AppUser:
    if user.role not in ("admin", "teacher"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin or teacher access required")
    return user
