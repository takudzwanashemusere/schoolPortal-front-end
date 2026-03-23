from sqlalchemy import (
    Column, String, Float, DateTime, Text, Integer, ForeignKey, Boolean
)
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from database import Base


# ── Association tables (many-to-many) ─────────────────────────────────────────

class TeacherSubject(Base):
    __tablename__ = "teacher_subjects"
    teacher_id = Column(String, ForeignKey("teachers.id"), primary_key=True)
    subject_id = Column(String, ForeignKey("subjects.id"), primary_key=True)


class TeacherClass(Base):
    __tablename__ = "teacher_classes"
    teacher_id = Column(String, ForeignKey("teachers.id"), primary_key=True)
    class_id = Column(String, ForeignKey("class_groups.id"), primary_key=True)


class ClassStudent(Base):
    __tablename__ = "class_students"
    class_id = Column(String, ForeignKey("class_groups.id"), primary_key=True)
    student_id = Column(String, ForeignKey("students.id"), primary_key=True)


# ── Core tables ───────────────────────────────────────────────────────────────

class AppUser(Base):
    __tablename__ = "app_users"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    role = Column(String, nullable=False)   # "admin" | "teacher" | "student"
    hashed_password = Column(String, nullable=False)
    linked_id = Column(String, nullable=True)  # teacher id or student id


class Teacher(Base):
    __tablename__ = "teachers"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)

    subjects = relationship("Subject", back_populates="teacher")
    submission = relationship("TeacherSubmission", back_populates="teacher", uselist=False)


class Subject(Base):
    __tablename__ = "subjects"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    teacher_id = Column(String, ForeignKey("teachers.id"), nullable=False)

    teacher = relationship("Teacher", back_populates="subjects")


class Student(Base):
    __tablename__ = "students"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    class_id = Column(String, ForeignKey("class_groups.id"), nullable=False)

    class_group = relationship("ClassGroup", back_populates="students")
    marks = relationship("Mark", back_populates="student")


class ClassGroup(Base):
    __tablename__ = "class_groups"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)

    students = relationship("Student", back_populates="class_group")


class Mark(Base):
    __tablename__ = "marks"

    student_id = Column(String, ForeignKey("students.id"), primary_key=True)
    subject_id = Column(String, ForeignKey("subjects.id"), primary_key=True)
    class_id = Column(String, ForeignKey("class_groups.id"), primary_key=True)
    test_mark = Column(Float, nullable=False, default=0.0)
    exam_mark = Column(Float, nullable=False, default=0.0)

    student = relationship("Student", back_populates="marks")
    subject = relationship("Subject")


class TeacherSubmission(Base):
    __tablename__ = "teacher_submissions"

    teacher_id = Column(String, ForeignKey("teachers.id"), primary_key=True)
    submitted_at = Column(DateTime, nullable=False, default=lambda: datetime.now(timezone.utc))

    teacher = relationship("Teacher", back_populates="submission")


class HeadmasterReport(Base):
    __tablename__ = "headmaster_report"

    id = Column(Integer, primary_key=True, default=1)
    comment = Column(Text, nullable=False, default="")
    signature = Column(String, nullable=False, default="")
