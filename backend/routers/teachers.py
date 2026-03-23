from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Optional

from database import get_db
from dependencies import require_admin_or_teacher
from schemas import TeacherResponse, TeacherPassRateResponse, calc_final_mark
import models

router = APIRouter()


def _build_teacher_response(teacher: models.Teacher, db: Session) -> TeacherResponse:
    subject_ids = [ts.subject_id for ts in
                   db.query(models.TeacherSubject).filter_by(teacher_id=teacher.id).all()]
    class_ids = [tc.class_id for tc in
                 db.query(models.TeacherClass).filter_by(teacher_id=teacher.id).all()]
    return TeacherResponse(id=teacher.id, name=teacher.name,
                           subject_ids=subject_ids, class_ids=class_ids)


def compute_pass_rate(teacher_id: str, db: Session) -> Optional[float]:
    """Returns pass rate (0-100) or None if no marks submitted."""
    subject_ids = [ts.subject_id for ts in
                   db.query(models.TeacherSubject).filter_by(teacher_id=teacher_id).all()]
    class_ids = [tc.class_id for tc in
                 db.query(models.TeacherClass).filter_by(teacher_id=teacher_id).all()]

    marks = (
        db.query(models.Mark)
        .filter(
            models.Mark.subject_id.in_(subject_ids),
            models.Mark.class_id.in_(class_ids),
        )
        .all()
    )

    if not marks:
        return None

    passing = sum(1 for m in marks if calc_final_mark(m.test_mark, m.exam_mark) >= 50)
    return round((passing / len(marks)) * 100, 1)


@router.get("/", response_model=list[TeacherResponse])
def list_teachers(
    db: Session = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    teachers = db.query(models.Teacher).all()
    return [_build_teacher_response(t, db) for t in teachers]


@router.get("/{teacher_id}", response_model=TeacherResponse)
def get_teacher(
    teacher_id: str,
    db: Session = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    teacher = db.query(models.Teacher).filter(models.Teacher.id == teacher_id).first()
    if teacher is None:
        raise HTTPException(status_code=404, detail="Teacher not found")
    return _build_teacher_response(teacher, db)


@router.get("/{teacher_id}/pass-rate", response_model=TeacherPassRateResponse)
def get_teacher_pass_rate(
    teacher_id: str,
    db: Session = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    teacher = db.query(models.Teacher).filter(models.Teacher.id == teacher_id).first()
    if teacher is None:
        raise HTTPException(status_code=404, detail="Teacher not found")

    submitted = teacher.submission is not None
    pass_rate = compute_pass_rate(teacher_id, db)

    return TeacherPassRateResponse(
        teacher_id=teacher.id,
        teacher_name=teacher.name,
        pass_rate=pass_rate,
        submitted=submitted,
    )
