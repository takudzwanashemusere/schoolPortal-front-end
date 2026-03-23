from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from auth import verify_password, create_access_token
from dependencies import get_current_user
from schemas import LoginRequest, TokenResponse
import models

router = APIRouter()


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(models.AppUser).filter(models.AppUser.id == body.user_id).first()
    if user is None or not verify_password(body.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid user ID or password",
        )
    token = create_access_token(user.id, user.role)
    return TokenResponse(
        access_token=token,
        user_id=user.id,
        name=user.name,
        role=user.role,
        linked_id=user.linked_id,
    )


@router.get("/me", response_model=TokenResponse)
def me(
    current_user: models.AppUser = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # Return a fresh token so the client can extend its session
    token = create_access_token(current_user.id, current_user.role)
    return TokenResponse(
        access_token=token,
        user_id=current_user.id,
        name=current_user.name,
        role=current_user.role,
        linked_id=current_user.linked_id,
    )
