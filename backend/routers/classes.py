from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from dependencies import require_admin_or_teacher
from schemas import ClassGroupResponse
import models

router = APIRouter()


def _build_class_response(cg: models.ClassGroup, db: Session) -> ClassGroupResponse:
    student_ids = [cs.student_id for cs in
                   db.query(models.ClassStudent).filter_by(class_id=cg.id).all()]
    teacher_ids = [tc.teacher_id for tc in
                   db.query(models.TeacherClass).filter_by(class_id=cg.id).all()]
    return ClassGroupResponse(
        id=cg.id,
        name=cg.name,
        student_ids=student_ids,
        teacher_ids=teacher_ids,
    )


@router.get("/", response_model=list[ClassGroupResponse])
def list_classes(
    db: Session = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    classes = db.query(models.ClassGroup).all()
    return [_build_class_response(c, db) for c in classes]


@router.get("/{class_id}", response_model=ClassGroupResponse)
def get_class(
    class_id: str,
    db: Session = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    cg = db.query(models.ClassGroup).filter(models.ClassGroup.id == class_id).first()
    if cg is None:
        raise HTTPException(status_code=404, detail="Class not found")
    return _build_class_response(cg, db)
