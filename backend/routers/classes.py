from fastapi import APIRouter, Depends, HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase

from database import get_db
from dependencies import require_admin_or_teacher
from schemas import ClassGroupResponse

router = APIRouter()


def _doc_to_class(doc: dict) -> ClassGroupResponse:
    return ClassGroupResponse(
        id=doc["_id"],
        name=doc["name"],
        student_ids=doc.get("student_ids", []),
        teacher_ids=doc.get("teacher_ids", []),
    )


@router.get("/", response_model=list[ClassGroupResponse])
async def list_classes(
    db: AsyncIOMotorDatabase = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    docs = await db["classes"].find({}).to_list(None)
    return [_doc_to_class(d) for d in docs]


@router.get("/{class_id}", response_model=ClassGroupResponse)
async def get_class(
    class_id: str,
    db: AsyncIOMotorDatabase = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    doc = await db["classes"].find_one({"_id": class_id})
    if doc is None:
        raise HTTPException(status_code=404, detail="Class not found")
    return _doc_to_class(doc)
