from fastapi import APIRouter, Depends, HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase

from database import get_db
from dependencies import require_admin_or_teacher
from schemas import MarkUpsertRequest, MarkResponse, mark_to_response

router = APIRouter()


@router.get("/", response_model=list[MarkResponse])
async def list_marks(
    student_id: str | None = None,
    subject_id: str | None = None,
    class_id: str | None = None,
    db: AsyncIOMotorDatabase = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    filt = {}
    if student_id:
        filt["student_id"] = student_id
    if subject_id:
        filt["subject_id"] = subject_id
    if class_id:
        filt["class_id"] = class_id
    docs = await db["marks"].find(filt).to_list(None)
    return [mark_to_response(m) for m in docs]


@router.post("/", response_model=MarkResponse)
async def upsert_mark(
    body: MarkUpsertRequest,
    db: AsyncIOMotorDatabase = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    if not await db["students"].find_one({"_id": body.student_id}):
        raise HTTPException(status_code=404, detail="Student not found")
    if not await db["subjects"].find_one({"_id": body.subject_id}):
        raise HTTPException(status_code=404, detail="Subject not found")
    if not await db["classes"].find_one({"_id": body.class_id}):
        raise HTTPException(status_code=404, detail="Class not found")

    filt = {
        "student_id": body.student_id,
        "subject_id": body.subject_id,
        "class_id":   body.class_id,
    }
    update = {"$set": {"test_mark": body.test_mark, "exam_mark": body.exam_mark}}
    await db["marks"].update_one(filt, update, upsert=True)

    doc = await db["marks"].find_one(filt)
    return mark_to_response(doc)
