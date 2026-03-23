from fastapi import APIRouter, Depends, HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase
from typing import Optional

from database import get_db
from dependencies import require_admin_or_teacher
from schemas import TeacherResponse, TeacherPassRateResponse, calc_final_mark

router = APIRouter()


def _doc_to_teacher(doc: dict) -> TeacherResponse:
    return TeacherResponse(
        id=doc["_id"],
        name=doc["name"],
        subject_ids=doc.get("subject_ids", []),
        class_ids=doc.get("class_ids", []),
    )


async def compute_pass_rate(teacher_id: str, db: AsyncIOMotorDatabase) -> Optional[float]:
    """Returns pass rate (0-100) or None if no marks submitted."""
    teacher = await db["teachers"].find_one({"_id": teacher_id})
    if not teacher:
        return None

    subject_ids = teacher.get("subject_ids", [])
    class_ids = teacher.get("class_ids", [])

    cursor = db["marks"].find({
        "subject_id": {"$in": subject_ids},
        "class_id":   {"$in": class_ids},
    })
    marks = await cursor.to_list(None)

    if not marks:
        return None

    passing = sum(1 for m in marks if calc_final_mark(m["test_mark"], m["exam_mark"]) >= 50)
    return round((passing / len(marks)) * 100, 1)


@router.get("/", response_model=list[TeacherResponse])
async def list_teachers(
    db: AsyncIOMotorDatabase = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    docs = await db["teachers"].find({}).to_list(None)
    return [_doc_to_teacher(d) for d in docs]


@router.get("/{teacher_id}", response_model=TeacherResponse)
async def get_teacher(
    teacher_id: str,
    db: AsyncIOMotorDatabase = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    doc = await db["teachers"].find_one({"_id": teacher_id})
    if doc is None:
        raise HTTPException(status_code=404, detail="Teacher not found")
    return _doc_to_teacher(doc)


@router.get("/{teacher_id}/pass-rate", response_model=TeacherPassRateResponse)
async def get_teacher_pass_rate(
    teacher_id: str,
    db: AsyncIOMotorDatabase = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    doc = await db["teachers"].find_one({"_id": teacher_id})
    if doc is None:
        raise HTTPException(status_code=404, detail="Teacher not found")

    sub = await db["submissions"].find_one({"_id": teacher_id})
    pass_rate = await compute_pass_rate(teacher_id, db)

    return TeacherPassRateResponse(
        teacher_id=teacher_id,
        teacher_name=doc["name"],
        pass_rate=pass_rate,
        submitted=sub is not None,
    )
