from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timezone

from database import get_db
from dependencies import require_admin
from schemas import AnalyticsResponse, SubmissionStatusItem, TeacherPassRateResponse
from routers.teachers import compute_pass_rate
import models

router = APIRouter()


@router.get("/submission-status", response_model=list[SubmissionStatusItem])
def submission_status(
    db: Session = Depends(get_db),
    _user=Depends(require_admin),
):
    teachers = db.query(models.Teacher).all()
    result = []
    for t in teachers:
        sub = db.query(models.TeacherSubmission).filter_by(teacher_id=t.id).first()
        result.append(SubmissionStatusItem(
            teacher_id=t.id,
            teacher_name=t.name,
            submitted=sub is not None,
            submitted_at=sub.submitted_at if sub else None,
        ))
    return result


@router.post("/submission/{teacher_id}", response_model=SubmissionStatusItem)
def mark_submitted(
    teacher_id: str,
    db: Session = Depends(get_db),
    _user=Depends(require_admin),
):
    teacher = db.query(models.Teacher).filter_by(id=teacher_id).first()
    if teacher is None:
        raise HTTPException(status_code=404, detail="Teacher not found")

    existing = db.query(models.TeacherSubmission).filter_by(teacher_id=teacher_id).first()
    if existing is None:
        sub = models.TeacherSubmission(
            teacher_id=teacher_id,
            submitted_at=datetime.now(timezone.utc),
        )
        db.add(sub)
        db.commit()
        db.refresh(sub)
    else:
        sub = existing

    return SubmissionStatusItem(
        teacher_id=teacher.id,
        teacher_name=teacher.name,
        submitted=True,
        submitted_at=sub.submitted_at,
    )


@router.get("/analytics", response_model=AnalyticsResponse)
def analytics(
    db: Session = Depends(get_db),
    _user=Depends(require_admin),
):
    teachers = db.query(models.Teacher).all()
    items: list[TeacherPassRateResponse] = []

    for t in teachers:
        sub = db.query(models.TeacherSubmission).filter_by(teacher_id=t.id).first()
        pass_rate = compute_pass_rate(t.id, db)
        items.append(TeacherPassRateResponse(
            teacher_id=t.id,
            teacher_name=t.name,
            pass_rate=pass_rate,
            submitted=sub is not None,
        ))

    # Highest performer — only among teachers with submitted marks
    submitted_items = [i for i in items if i.pass_rate is not None]
    highest = max(submitted_items, key=lambda i: i.pass_rate, default=None)

    # Average pass rate across submitted teachers
    avg = (
        round(sum(i.pass_rate for i in submitted_items) / len(submitted_items), 1)
        if submitted_items else None
    )

    return AnalyticsResponse(
        teacher_pass_rates=items,
        highest_performer=highest,
        average_pass_rate=avg,
        submitted_count=len(submitted_items),
        total_teachers=len(teachers),
    )
