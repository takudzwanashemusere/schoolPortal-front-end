from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from dependencies import require_admin_or_teacher
from schemas import MarkUpsertRequest, MarkResponse, mark_to_response
import models

router = APIRouter()


@router.get("/", response_model=list[MarkResponse])
def list_marks(
    student_id: str | None = None,
    subject_id: str | None = None,
    class_id: str | None = None,
    db: Session = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    query = db.query(models.Mark)
    if student_id:
        query = query.filter(models.Mark.student_id == student_id)
    if subject_id:
        query = query.filter(models.Mark.subject_id == subject_id)
    if class_id:
        query = query.filter(models.Mark.class_id == class_id)
    return [mark_to_response(m) for m in query.all()]


@router.post("/", response_model=MarkResponse)
def upsert_mark(
    body: MarkUpsertRequest,
    db: Session = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    # Validate that student, subject, and class exist
    if not db.query(models.Student).filter_by(id=body.student_id).first():
        raise HTTPException(status_code=404, detail="Student not found")
    if not db.query(models.Subject).filter_by(id=body.subject_id).first():
        raise HTTPException(status_code=404, detail="Subject not found")
    if not db.query(models.ClassGroup).filter_by(id=body.class_id).first():
        raise HTTPException(status_code=404, detail="Class not found")

    existing = (
        db.query(models.Mark)
        .filter_by(
            student_id=body.student_id,
            subject_id=body.subject_id,
            class_id=body.class_id,
        )
        .first()
    )
    if existing:
        existing.test_mark = body.test_mark
        existing.exam_mark = body.exam_mark
        db.commit()
        db.refresh(existing)
        return mark_to_response(existing)
    else:
        mark = models.Mark(
            student_id=body.student_id,
            subject_id=body.subject_id,
            class_id=body.class_id,
            test_mark=body.test_mark,
            exam_mark=body.exam_mark,
        )
        db.add(mark)
        db.commit()
        db.refresh(mark)
        return mark_to_response(mark)
