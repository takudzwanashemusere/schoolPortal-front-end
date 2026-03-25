from pydantic import BaseModel, ConfigDict, computed_field
from typing import Optional
from datetime import datetime


# ── Helpers ───────────────────────────────────────────────────────────────────

def calc_final_mark(test: float, exam: float) -> float:
    return round((test * 0.4) + (exam * 0.6), 2)


def calc_grade(final: float) -> str:
    if final >= 80:
        return "A"
    if final >= 70:
        return "B"
    if final >= 60:
        return "C"
    if final >= 50:
        return "D"
    return "F"


# ── Auth ──────────────────────────────────────────────────────────────────────

class LoginRequest(BaseModel):
    user_id: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    name: str
    role: str
    linked_id: Optional[str] = None


# ── Teacher ───────────────────────────────────────────────────────────────────

class TeacherResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    subject_ids: list[str] = []
    class_ids: list[str] = []


class TeacherCreateRequest(BaseModel):
    name: str
    password: str
    subject_names: list[str] = []
    class_ids: list[str] = []


class TeacherCreateResponse(BaseModel):
    teacher: TeacherResponse
    user_id: str


class TeacherUpdateClassesRequest(BaseModel):
    class_ids: list[str]


class TeacherUpdateSubjectsRequest(BaseModel):
    subject_ids: list[str]


class TeacherPassRateResponse(BaseModel):
    teacher_id: str
    teacher_name: str
    pass_rate: Optional[float]   # None = no marks submitted yet
    submitted: bool


# ── Subject ───────────────────────────────────────────────────────────────────

class SubjectResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    teacher_id: str


# ── Student ───────────────────────────────────────────────────────────────────

class StudentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    class_id: str


class StudentUpdateRequest(BaseModel):
    name: str


# ── ClassGroup ────────────────────────────────────────────────────────────────

class ClassGroupResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    student_ids: list[str] = []
    teacher_ids: list[str] = []


# ── Mark ──────────────────────────────────────────────────────────────────────

class MarkUpsertRequest(BaseModel):
    student_id: str
    subject_id: str
    class_id: str
    test_mark: float
    exam_mark: float


class MarkResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    student_id: str
    subject_id: str
    class_id: str
    test_mark: float
    exam_mark: float
    final_mark: float
    grade: str
    is_passing: bool


def mark_to_response(m) -> MarkResponse:
    final = calc_final_mark(m.test_mark, m.exam_mark)
    return MarkResponse(
        student_id=m.student_id,
        subject_id=m.subject_id,
        class_id=m.class_id,
        test_mark=m.test_mark,
        exam_mark=m.exam_mark,
        final_mark=final,
        grade=calc_grade(final),
        is_passing=final >= 50,
    )


# ── Admin analytics ───────────────────────────────────────────────────────────

class SubmissionStatusItem(BaseModel):
    teacher_id: str
    teacher_name: str
    submitted: bool
    submitted_at: Optional[datetime] = None


class AnalyticsResponse(BaseModel):
    teacher_pass_rates: list[TeacherPassRateResponse]
    highest_performer: Optional[TeacherPassRateResponse] = None
    average_pass_rate: Optional[float] = None
    submitted_count: int
    total_teachers: int


# ── Headmaster report ─────────────────────────────────────────────────────────

class HeadmasterReportResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    comment: str
    signature: str


class HeadmasterReportUpdateRequest(BaseModel):
    comment: str
    signature: str


# ── Class report (for print/preview) ─────────────────────────────────────────

class StudentMarkEntry(BaseModel):
    subject_id: str
    subject_name: str
    test_mark: Optional[float] = None
    exam_mark: Optional[float] = None
    final_mark: Optional[float] = None
    grade: Optional[str] = None
    is_passing: Optional[bool] = None


class StudentReportRow(BaseModel):
    student: StudentResponse
    marks_by_subject: dict[str, StudentMarkEntry]
    average: Optional[float]
    overall_grade: Optional[str]


class ClassReportResponse(BaseModel):
    class_group: ClassGroupResponse
    subjects: list[SubjectResponse]
    students: list[StudentReportRow]
    pass_rate: Optional[float]
    headmaster_comment: str
    headmaster_signature: str
