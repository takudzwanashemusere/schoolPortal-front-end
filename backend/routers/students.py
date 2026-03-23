from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from dependencies import get_current_user, require_admin_or_teacher
from schemas import StudentResponse, StudentUpdateRequest, MarkResponse, mark_to_response
import models

router = APIRouter()


@router.get("/", response_model=list[StudentResponse])
def list_students(
    class_id: str | None = None,
    db: Session = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    query = db.query(models.Student)
    if class_id:
        query = query.filter(models.Student.class_id == class_id)
    return query.all()


@router.get("/{student_id}", response_model=StudentResponse)
def get_student(
    student_id: str,
    db: Session = Depends(get_db),
    current_user: models.AppUser = Depends(get_current_user),
):
    # Students can only view their own profile
    if current_user.role == "student" and current_user.linked_id != student_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")

    student = db.query(models.Student).filter(models.Student.id == student_id).first()
    if student is None:
        raise HTTPException(status_code=404, detail="Student not found")
    return student


@router.put("/{student_id}", response_model=StudentResponse)
def update_student(
    student_id: str,
    body: StudentUpdateRequest,
    db: Session = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    student = db.query(models.Student).filter(models.Student.id == student_id).first()
    if student is None:
        raise HTTPException(status_code=404, detail="Student not found")
    student.name = body.name
    db.commit()
    db.refresh(student)
    return student


@router.get("/{student_id}/marks", response_model=list[MarkResponse])
def get_student_marks(
    student_id: str,
    db: Session = Depends(get_db),
    current_user: models.AppUser = Depends(get_current_user),
):
    # Students can only view their own marks
    if current_user.role == "student" and current_user.linked_id != student_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")

    marks = db.query(models.Mark).filter(models.Mark.student_id == student_id).all()
    return [mark_to_response(m) for m in marks]
