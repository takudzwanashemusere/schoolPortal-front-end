"""
Seed the database with the same data as mock_data.dart.
This function is idempotent — it checks for existing data before inserting.
"""
from datetime import datetime, timezone
from sqlalchemy.orm import Session

from auth import hash_password
import models


# Pre-hash the three shared passwords once (bcrypt is intentionally slow)
_HASHES: dict[str, str] = {}


def _hash(plain: str) -> str:
    if plain not in _HASHES:
        _HASHES[plain] = hash_password(plain)
    return _HASHES[plain]


def seed_database(db: Session) -> None:
    # Idempotency check
    if db.query(models.AppUser).first() is not None:
        return

    # ── 1. Class groups ────────────────────────────────────────────────────────
    classes = [
        models.ClassGroup(id="c1", name="Form 3A"),
        models.ClassGroup(id="c2", name="Form 3B"),
        models.ClassGroup(id="c3", name="Form 4A"),
        models.ClassGroup(id="c4", name="Form 4B"),
    ]
    db.add_all(classes)

    # ── 2. Teachers ────────────────────────────────────────────────────────────
    teachers = [
        models.Teacher(id="t1", name="Mr. Patrick Mwale"),
        models.Teacher(id="t2", name="Mrs. Grace Banda"),
        models.Teacher(id="t3", name="Mr. Benson Phiri"),
        models.Teacher(id="t4", name="Ms. Faith Tembo"),
    ]
    db.add_all(teachers)

    # ── 3. Subjects ────────────────────────────────────────────────────────────
    subjects = [
        models.Subject(id="sub1", name="Mathematics", teacher_id="t1"),
        models.Subject(id="sub2", name="Science", teacher_id="t1"),
        models.Subject(id="sub3", name="English", teacher_id="t2"),
        models.Subject(id="sub4", name="History", teacher_id="t2"),
        models.Subject(id="sub5", name="Geography", teacher_id="t3"),
        models.Subject(id="sub6", name="Civic Education", teacher_id="t3"),
        models.Subject(id="sub7", name="Biology", teacher_id="t4"),
        models.Subject(id="sub8", name="Chemistry", teacher_id="t4"),
    ]
    db.add_all(subjects)

    # ── 4. Students ────────────────────────────────────────────────────────────
    students = [
        # Form 3A
        models.Student(id="s1",  name="Chanda Mulenga",   class_id="c1"),
        models.Student(id="s2",  name="Mwansa Kapata",    class_id="c1"),
        models.Student(id="s3",  name="Bupe Mutale",      class_id="c1"),
        models.Student(id="s4",  name="Natasha Phiri",    class_id="c1"),
        models.Student(id="s5",  name="David Tembo",      class_id="c1"),
        # Form 3B
        models.Student(id="s6",  name="Kelvin Zulu",      class_id="c2"),
        models.Student(id="s7",  name="Susan Banda",      class_id="c2"),
        models.Student(id="s8",  name="Victor Mwale",     class_id="c2"),
        models.Student(id="s9",  name="Patricia Nkosi",   class_id="c2"),
        models.Student(id="s10", name="Emmanuel Chibwe",  class_id="c2"),
        # Form 4A
        models.Student(id="s11", name="Mable Musonda",    class_id="c3"),
        models.Student(id="s12", name="Frank Kasonde",    class_id="c3"),
        models.Student(id="s13", name="Charity Luo",      class_id="c3"),
        models.Student(id="s14", name="George Mwaba",     class_id="c3"),
        models.Student(id="s15", name="Alice Chisanga",   class_id="c3"),
        # Form 4B
        models.Student(id="s16", name="Raymond Mutumba",  class_id="c4"),
        models.Student(id="s17", name="Esther Kabwe",     class_id="c4"),
        models.Student(id="s18", name="Joseph Mwenye",    class_id="c4"),
        models.Student(id="s19", name="Clara Mukonda",    class_id="c4"),
        models.Student(id="s20", name="Dennis Chileshe",  class_id="c4"),
    ]
    db.add_all(students)

    # ── 5. Association tables ──────────────────────────────────────────────────
    teacher_subjects = [
        models.TeacherSubject(teacher_id="t1", subject_id="sub1"),
        models.TeacherSubject(teacher_id="t1", subject_id="sub2"),
        models.TeacherSubject(teacher_id="t2", subject_id="sub3"),
        models.TeacherSubject(teacher_id="t2", subject_id="sub4"),
        models.TeacherSubject(teacher_id="t3", subject_id="sub5"),
        models.TeacherSubject(teacher_id="t3", subject_id="sub6"),
        models.TeacherSubject(teacher_id="t4", subject_id="sub7"),
        models.TeacherSubject(teacher_id="t4", subject_id="sub8"),
    ]
    db.add_all(teacher_subjects)

    teacher_classes = [
        models.TeacherClass(teacher_id="t1", class_id="c1"),
        models.TeacherClass(teacher_id="t1", class_id="c2"),
        models.TeacherClass(teacher_id="t2", class_id="c1"),
        models.TeacherClass(teacher_id="t2", class_id="c3"),
        models.TeacherClass(teacher_id="t3", class_id="c2"),
        models.TeacherClass(teacher_id="t3", class_id="c4"),
        models.TeacherClass(teacher_id="t4", class_id="c3"),
        models.TeacherClass(teacher_id="t4", class_id="c4"),
    ]
    db.add_all(teacher_classes)

    class_students = [
        # c1 — Form 3A
        models.ClassStudent(class_id="c1", student_id="s1"),
        models.ClassStudent(class_id="c1", student_id="s2"),
        models.ClassStudent(class_id="c1", student_id="s3"),
        models.ClassStudent(class_id="c1", student_id="s4"),
        models.ClassStudent(class_id="c1", student_id="s5"),
        # c2 — Form 3B
        models.ClassStudent(class_id="c2", student_id="s6"),
        models.ClassStudent(class_id="c2", student_id="s7"),
        models.ClassStudent(class_id="c2", student_id="s8"),
        models.ClassStudent(class_id="c2", student_id="s9"),
        models.ClassStudent(class_id="c2", student_id="s10"),
        # c3 — Form 4A
        models.ClassStudent(class_id="c3", student_id="s11"),
        models.ClassStudent(class_id="c3", student_id="s12"),
        models.ClassStudent(class_id="c3", student_id="s13"),
        models.ClassStudent(class_id="c3", student_id="s14"),
        models.ClassStudent(class_id="c3", student_id="s15"),
        # c4 — Form 4B
        models.ClassStudent(class_id="c4", student_id="s16"),
        models.ClassStudent(class_id="c4", student_id="s17"),
        models.ClassStudent(class_id="c4", student_id="s18"),
        models.ClassStudent(class_id="c4", student_id="s19"),
        models.ClassStudent(class_id="c4", student_id="s20"),
    ]
    db.add_all(class_students)

    # ── 6. Marks (40 pre-filled entries) ──────────────────────────────────────
    def _m(sid, subid, cid, test, exam):
        return models.Mark(student_id=sid, subject_id=subid, class_id=cid,
                           test_mark=test, exam_mark=exam)

    marks = [
        # t1: Form 3A — Mathematics
        _m("s1", "sub1", "c1", 72, 80),
        _m("s2", "sub1", "c1", 55, 60),
        _m("s3", "sub1", "c1", 35, 42),
        _m("s4", "sub1", "c1", 88, 90),
        _m("s5", "sub1", "c1", 62, 68),
        # t1: Form 3A — Science
        _m("s1", "sub2", "c1", 80, 85),
        _m("s2", "sub2", "c1", 65, 72),
        _m("s3", "sub2", "c1", 40, 45),
        _m("s4", "sub2", "c1", 85, 88),
        _m("s5", "sub2", "c1", 70, 74),
        # t1: Form 3B — Mathematics
        _m("s6",  "sub1", "c2", 45, 48),
        _m("s7",  "sub1", "c2", 78, 82),
        _m("s8",  "sub1", "c2", 58, 65),
        _m("s9",  "sub1", "c2", 30, 38),
        _m("s10", "sub1", "c2", 70, 75),
        # t1: Form 3B — Science
        _m("s6",  "sub2", "c2", 52, 58),
        _m("s7",  "sub2", "c2", 75, 80),
        _m("s8",  "sub2", "c2", 60, 65),
        _m("s9",  "sub2", "c2", 42, 46),
        _m("s10", "sub2", "c2", 68, 73),
        # t2: Form 3A — English
        _m("s1", "sub3", "c1", 70, 78),
        _m("s2", "sub3", "c1", 82, 85),
        _m("s3", "sub3", "c1", 60, 65),
        _m("s4", "sub3", "c1", 88, 92),
        _m("s5", "sub3", "c1", 45, 48),
        # t2: Form 3A — History
        _m("s1", "sub4", "c1", 75, 80),
        _m("s2", "sub4", "c1", 80, 83),
        _m("s3", "sub4", "c1", 55, 60),
        _m("s4", "sub4", "c1", 85, 90),
        _m("s5", "sub4", "c1", 50, 54),
        # t2: Form 4A — English
        _m("s11", "sub3", "c3", 75, 80),
        _m("s12", "sub3", "c3", 85, 88),
        _m("s13", "sub3", "c3", 60, 65),
        _m("s14", "sub3", "c3", 55, 62),
        _m("s15", "sub3", "c3", 72, 78),
        # t2: Form 4A — History
        _m("s11", "sub4", "c3", 78, 82),
        _m("s12", "sub4", "c3", 82, 86),
        _m("s13", "sub4", "c3", 62, 68),
        _m("s14", "sub4", "c3", 58, 63),
        _m("s15", "sub4", "c3", 70, 76),
    ]
    db.add_all(marks)

    # ── 7. Teacher submissions (t1 and t2 already submitted) ──────────────────
    db.add_all([
        models.TeacherSubmission(
            teacher_id="t1",
            submitted_at=datetime.now(timezone.utc),
        ),
        models.TeacherSubmission(
            teacher_id="t2",
            submitted_at=datetime.now(timezone.utc),
        ),
    ])

    # ── 8. App users ───────────────────────────────────────────────────────────
    users = [
        models.AppUser(id="u0",  name="Dr. James Banda",     role="admin",   hashed_password=_hash("admin123")),
        models.AppUser(id="u1",  name="Mr. Patrick Mwale",   role="teacher", hashed_password=_hash("teacher123"), linked_id="t1"),
        models.AppUser(id="u2",  name="Mrs. Grace Banda",    role="teacher", hashed_password=_hash("teacher123"), linked_id="t2"),
        models.AppUser(id="u3",  name="Mr. Benson Phiri",    role="teacher", hashed_password=_hash("teacher123"), linked_id="t3"),
        models.AppUser(id="u4",  name="Ms. Faith Tembo",     role="teacher", hashed_password=_hash("teacher123"), linked_id="t4"),
        models.AppUser(id="u5",  name="Chanda Mulenga",      role="student", hashed_password=_hash("student123"), linked_id="s1"),
        models.AppUser(id="u6",  name="Mwansa Kapata",       role="student", hashed_password=_hash("student123"), linked_id="s2"),
        models.AppUser(id="u7",  name="Bupe Mutale",         role="student", hashed_password=_hash("student123"), linked_id="s3"),
        models.AppUser(id="u8",  name="Natasha Phiri",       role="student", hashed_password=_hash("student123"), linked_id="s4"),
        models.AppUser(id="u9",  name="David Tembo",         role="student", hashed_password=_hash("student123"), linked_id="s5"),
        models.AppUser(id="u10", name="Kelvin Zulu",         role="student", hashed_password=_hash("student123"), linked_id="s6"),
        models.AppUser(id="u11", name="Susan Banda",         role="student", hashed_password=_hash("student123"), linked_id="s7"),
        models.AppUser(id="u12", name="Mable Musonda",       role="student", hashed_password=_hash("student123"), linked_id="s11"),
        models.AppUser(id="u13", name="Frank Kasonde",       role="student", hashed_password=_hash("student123"), linked_id="s12"),
        models.AppUser(id="u14", name="Raymond Mutumba",     role="student", hashed_password=_hash("student123"), linked_id="s16"),
    ]
    db.add_all(users)

    # ── 9. Headmaster report (single row) ─────────────────────────────────────
    db.add(models.HeadmasterReport(
        id=1,
        comment=(
            "I am pleased to present the academic results for this term. "
            "Our students have demonstrated commendable effort and dedication. "
            "I encourage all learners to strive for excellence in the coming term."
        ),
        signature="Dr. James Banda",
    ))

    db.commit()
    print("[seed] Database seeded successfully.")
