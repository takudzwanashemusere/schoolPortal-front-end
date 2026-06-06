from pydantic import BaseModel, ConfigDict, computed_field
from typing import Optional
from datetime import datetime


# ── Helpers ───────────────────────────────────────────────────────────────────

def calc_term_mark(tests: list[float]) -> float:
    """Average of all entered test scores."""
    filled = [t for t in tests if t is not None]
    if not filled:
        return 0.0
    return round(sum(filled) / len(filled), 2)


def calc_exam_mark_avg(papers: list[float]) -> float:
    """Average of all entered exam paper scores."""
    filled = [p for p in papers if p is not None]
    if not filled:
        return 0.0
    return round(sum(filled) / len(filled), 2)


def calc_final_mark(term: float, exam: float) -> float:
    return round((term * 0.4) + (exam * 0.6), 2)


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


class StudentCreateRequest(BaseModel):
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


class ClassCreateRequest(BaseModel):
    name: str


# ── Mark ──────────────────────────────────────────────────────────────────────

class MarkUpsertRequest(BaseModel):
    student_id: str
    subject_id: str
    class_id: str
    tests: list[float] = []
    exam_papers: list[float] = []


class MarkResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    student_id: str
    subject_id: str
    class_id: str
    tests: list[float] = []
    exam_papers: list[float] = []
    term_mark: float
    exam_mark: float
    final_mark: float
    grade: str
    is_passing: bool


def mark_to_response(m) -> MarkResponse:
    # Backward compat: old docs have test_mark/exam_mark floats
    if "tests" in m:
        tests = m.get("tests") or []
        exam_papers = m.get("exam_papers") or []
    else:
        tests = [m["test_mark"]] if m.get("test_mark") is not None else []
        exam_papers = [m["exam_mark"]] if m.get("exam_mark") is not None else []

    term = calc_term_mark(tests)
    exam = calc_exam_mark_avg(exam_papers)
    final = calc_final_mark(term, exam)
    return MarkResponse(
        student_id=m["student_id"],
        subject_id=m["subject_id"],
        class_id=m["class_id"],
        tests=tests,
        exam_papers=exam_papers,
        term_mark=term,
        exam_mark=exam,
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


# ── Student Application ───────────────────────────────────────────────────────

class ApplicationSubmitRequest(BaseModel):
    full_name: str
    email: str
    phone: str
    form_applying_for: str
    previous_school: str
    reason_for_leaving: str
    results_file_name: Optional[str] = None


class ApplicationResponse(BaseModel):
    id: str
    full_name: str
    email: str
    phone: str
    form_applying_for: str
    previous_school: str
    reason_for_leaving: str
    results_file_name: Optional[str] = None
    submitted_at: datetime
    is_reviewed: bool


# ── Class report (for print/preview) ─────────────────────────────────────────

class StudentMarkEntry(BaseModel):
    subject_id: str
    subject_name: str
    tests: list[float] = []
    exam_papers: list[float] = []
    term_mark: Optional[float] = None
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
