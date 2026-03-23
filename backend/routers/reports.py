from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from dependencies import require_admin, require_admin_or_teacher
from schemas import (
    HeadmasterReportResponse, HeadmasterReportUpdateRequest,
    ClassReportResponse, ClassGroupResponse, SubjectResponse,
    StudentResponse, StudentReportRow, StudentMarkEntry,
    calc_final_mark, calc_grade,
)
import models

router = APIRouter()


@router.get("/headmaster", response_model=HeadmasterReportResponse)
def get_headmaster_report(
    db: Session = Depends(get_db),
    _user=Depends(require_admin),
):
    report = db.query(models.HeadmasterReport).filter_by(id=1).first()
    if report is None:
        raise HTTPException(status_code=404, detail="Report config not found")
    return report


@router.put("/headmaster", response_model=HeadmasterReportResponse)
def update_headmaster_report(
    body: HeadmasterReportUpdateRequest,
    db: Session = Depends(get_db),
    _user=Depends(require_admin),
):
    report = db.query(models.HeadmasterReport).filter_by(id=1).first()
    if report is None:
        raise HTTPException(status_code=404, detail="Report config not found")
    report.comment = body.comment
    report.signature = body.signature
    db.commit()
    db.refresh(report)
    return report


@router.get("/class/{class_id}", response_model=ClassReportResponse)
def get_class_report(
    class_id: str,
    db: Session = Depends(get_db),
    _user=Depends(require_admin_or_teacher),
):
    cg = db.query(models.ClassGroup).filter_by(id=class_id).first()
    if cg is None:
        raise HTTPException(status_code=404, detail="Class not found")

    # Student IDs in this class
    class_student_rows = db.query(models.ClassStudent).filter_by(class_id=class_id).all()
    student_ids = [cs.student_id for cs in class_student_rows]

    # Teacher IDs for this class
    teacher_ids = [tc.teacher_id for tc in
                   db.query(models.TeacherClass).filter_by(class_id=class_id).all()]

    # Subjects taught in this class (subjects belonging to any teacher of this class)
    subjects = (
        db.query(models.Subject)
        .filter(models.Subject.teacher_id.in_(teacher_ids))
        .all()
    )
    subject_ids = [s.id for s in subjects]

    # All marks for this class
    all_marks = (
        db.query(models.Mark)
        .filter(
            models.Mark.class_id == class_id,
            models.Mark.student_id.in_(student_ids),
            models.Mark.subject_id.in_(subject_ids),
        )
        .all()
    )
    # Index marks by (student_id, subject_id)
    mark_index: dict[tuple, models.Mark] = {
        (m.student_id, m.subject_id): m for m in all_marks
    }

    students = db.query(models.Student).filter(models.Student.id.in_(student_ids)).all()

    student_rows: list[StudentReportRow] = []
    total_finals: list[float] = []
    passing_count = 0
    total_mark_count = 0

    for student in students:
        marks_by_subject: dict[str, StudentMarkEntry] = {}
        student_finals: list[float] = []

        for subject in subjects:
            key = (student.id, subject.id)
            mark = mark_index.get(key)
            if mark:
                final = calc_final_mark(mark.test_mark, mark.exam_mark)
                grade = calc_grade(final)
                is_passing = final >= 50
                entry = StudentMarkEntry(
                    subject_id=subject.id,
                    subject_name=subject.name,
                    test_mark=mark.test_mark,
                    exam_mark=mark.exam_mark,
                    final_mark=final,
                    grade=grade,
                    is_passing=is_passing,
                )
                student_finals.append(final)
                total_finals.append(final)
                if is_passing:
                    passing_count += 1
                total_mark_count += 1
            else:
                entry = StudentMarkEntry(
                    subject_id=subject.id,
                    subject_name=subject.name,
                )
            marks_by_subject[subject.id] = entry

        avg = round(sum(student_finals) / len(student_finals), 1) if student_finals else None
        overall_grade = calc_grade(avg) if avg is not None else None

        student_rows.append(StudentReportRow(
            student=StudentResponse(id=student.id, name=student.name, class_id=student.class_id),
            marks_by_subject=marks_by_subject,
            average=avg,
            overall_grade=overall_grade,
        ))

    # Overall class pass rate
    pass_rate = (
        round((passing_count / total_mark_count) * 100, 1)
        if total_mark_count > 0 else None
    )

    # Headmaster report
    hm = db.query(models.HeadmasterReport).filter_by(id=1).first()

    return ClassReportResponse(
        class_group=ClassGroupResponse(
            id=cg.id,
            name=cg.name,
            student_ids=student_ids,
            teacher_ids=teacher_ids,
        ),
        subjects=[SubjectResponse(id=s.id, name=s.name, teacher_id=s.teacher_id) for s in subjects],
        students=student_rows,
        pass_rate=pass_rate,
        headmaster_comment=hm.comment if hm else "",
        headmaster_signature=hm.signature if hm else "",
    )
