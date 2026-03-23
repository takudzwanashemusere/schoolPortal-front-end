from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from dependencies import get_current_user
from schemas import SubjectResponse
import models

router = APIRouter()


@router.get("/", response_model=list[SubjectResponse])
def list_subjects(
    teacher_id: str | None = None,
    db: Session = Depends(get_db),
    _user=Depends(get_current_user),
):
    query = db.query(models.Subject)
    if teacher_id:
        query = query.filter(models.Subject.teacher_id == teacher_id)
    return query.all()


@router.get("/{subject_id}", response_model=SubjectResponse)
def get_subject(
    subject_id: str,
    db: Session = Depends(get_db),
    _user=Depends(get_current_user),
):
    subject = db.query(models.Subject).filter(models.Subject.id == subject_id).first()
    if subject is None:
        raise HTTPException(status_code=404, detail="Subject not found")
    return subject
