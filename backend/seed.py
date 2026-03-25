"""
Seed MongoDB with the same data as mock_data.dart.
Idempotent — skips if data already exists.
"""
from datetime import datetime, timezone
from motor.motor_asyncio import AsyncIOMotorDatabase

from auth import hash_password

# Pre-hash the three shared passwords once
_HASHES: dict[str, str] = {}

def _hash(plain: str) -> str:
    if plain not in _HASHES:
        _HASHES[plain] = hash_password(plain)
    return _HASHES[plain]


async def seed_database(db: AsyncIOMotorDatabase) -> None:
    # Idempotency — skip if any users already exist
    if await db["users"].find_one({}):
        print("[seed] Data already present — skipping seed.")
        return

    # ── 1. Classes ─────────────────────────────────────────────────────────────
    await db["classes"].insert_many([
        {"_id": "c1", "name": "Form 3A",
         "student_ids": ["s1","s2","s3","s4","s5"],
         "teacher_ids": ["t1","t2"]},
        {"_id": "c2", "name": "Form 3B",
         "student_ids": ["s6","s7","s8","s9","s10"],
         "teacher_ids": ["t1","t3"]},
        {"_id": "c3", "name": "Form 4A",
         "student_ids": ["s11","s12","s13","s14","s15"],
         "teacher_ids": ["t2","t4"]},
        {"_id": "c4", "name": "Form 4B",
         "student_ids": ["s16","s17","s18","s19","s20"],
         "teacher_ids": ["t3","t4"]},
    ])

    # ── 2. Teachers ────────────────────────────────────────────────────────────
    await db["teachers"].insert_many([
        {"_id": "t1", "name": "Mr. Patrick Mwale",
         "subject_ids": ["sub1","sub2"], "class_ids": ["c1","c2"]},
        {"_id": "t2", "name": "Mrs. Grace Banda",
         "subject_ids": ["sub3","sub4"], "class_ids": ["c1","c3"]},
        {"_id": "t3", "name": "Mr. Benson Phiri",
         "subject_ids": ["sub5","sub6"], "class_ids": ["c2","c4"]},
        {"_id": "t4", "name": "Ms. Faith Tembo",
         "subject_ids": ["sub7","sub8"], "class_ids": ["c3","c4"]},
    ])

    # ── 3. Subjects ────────────────────────────────────────────────────────────
    await db["subjects"].insert_many([
        {"_id": "sub1", "name": "Mathematics",    "teacher_id": "t1"},
        {"_id": "sub2", "name": "Science",        "teacher_id": "t1"},
        {"_id": "sub3", "name": "English",        "teacher_id": "t2"},
        {"_id": "sub4", "name": "History",        "teacher_id": "t2"},
        {"_id": "sub5", "name": "Geography",      "teacher_id": "t3"},
        {"_id": "sub6", "name": "Civic Education","teacher_id": "t3"},
        {"_id": "sub7", "name": "Biology",        "teacher_id": "t4"},
        {"_id": "sub8", "name": "Chemistry",      "teacher_id": "t4"},
    ])

    # ── 4. Students ────────────────────────────────────────────────────────────
    await db["students"].insert_many([
        {"_id": "s1",  "name": "Chanda Mulenga",  "class_id": "c1"},
        {"_id": "s2",  "name": "Mwansa Kapata",   "class_id": "c1"},
        {"_id": "s3",  "name": "Bupe Mutale",     "class_id": "c1"},
        {"_id": "s4",  "name": "Natasha Phiri",   "class_id": "c1"},
        {"_id": "s5",  "name": "David Tembo",     "class_id": "c1"},
        {"_id": "s6",  "name": "Kelvin Zulu",     "class_id": "c2"},
        {"_id": "s7",  "name": "Susan Banda",     "class_id": "c2"},
        {"_id": "s8",  "name": "Victor Mwale",    "class_id": "c2"},
        {"_id": "s9",  "name": "Patricia Nkosi",  "class_id": "c2"},
        {"_id": "s10", "name": "Emmanuel Chibwe", "class_id": "c2"},
        {"_id": "s11", "name": "Mable Musonda",   "class_id": "c3"},
        {"_id": "s12", "name": "Frank Kasonde",   "class_id": "c3"},
        {"_id": "s13", "name": "Charity Luo",     "class_id": "c3"},
        {"_id": "s14", "name": "George Mwaba",    "class_id": "c3"},
        {"_id": "s15", "name": "Alice Chisanga",  "class_id": "c3"},
        {"_id": "s16", "name": "Raymond Mutumba", "class_id": "c4"},
        {"_id": "s17", "name": "Esther Kabwe",    "class_id": "c4"},
        {"_id": "s18", "name": "Joseph Mwenye",   "class_id": "c4"},
        {"_id": "s19", "name": "Clara Mukonda",   "class_id": "c4"},
        {"_id": "s20", "name": "Dennis Chileshe", "class_id": "c4"},
    ])

    # ── 5. Marks (40 pre-filled entries) ──────────────────────────────────────
    def _m(sid, subid, cid, test, exam):
        return {"student_id": sid, "subject_id": subid, "class_id": cid,
                "test_mark": float(test), "exam_mark": float(exam)}

    await db["marks"].insert_many([
        # t1: Form 3A — Mathematics
        _m("s1","sub1","c1",72,80), _m("s2","sub1","c1",55,60),
        _m("s3","sub1","c1",35,42), _m("s4","sub1","c1",88,90),
        _m("s5","sub1","c1",62,68),
        # t1: Form 3A — Science
        _m("s1","sub2","c1",80,85), _m("s2","sub2","c1",65,72),
        _m("s3","sub2","c1",40,45), _m("s4","sub2","c1",85,88),
        _m("s5","sub2","c1",70,74),
        # t1: Form 3B — Mathematics
        _m("s6","sub1","c2",45,48),  _m("s7","sub1","c2",78,82),
        _m("s8","sub1","c2",58,65),  _m("s9","sub1","c2",30,38),
        _m("s10","sub1","c2",70,75),
        # t1: Form 3B — Science
        _m("s6","sub2","c2",52,58),  _m("s7","sub2","c2",75,80),
        _m("s8","sub2","c2",60,65),  _m("s9","sub2","c2",42,46),
        _m("s10","sub2","c2",68,73),
        # t2: Form 3A — English
        _m("s1","sub3","c1",70,78),  _m("s2","sub3","c1",82,85),
        _m("s3","sub3","c1",60,65),  _m("s4","sub3","c1",88,92),
        _m("s5","sub3","c1",45,48),
        # t2: Form 3A — History
        _m("s1","sub4","c1",75,80),  _m("s2","sub4","c1",80,83),
        _m("s3","sub4","c1",55,60),  _m("s4","sub4","c1",85,90),
        _m("s5","sub4","c1",50,54),
        # t2: Form 4A — English
        _m("s11","sub3","c3",75,80), _m("s12","sub3","c3",85,88),
        _m("s13","sub3","c3",60,65), _m("s14","sub3","c3",55,62),
        _m("s15","sub3","c3",72,78),
        # t2: Form 4A — History
        _m("s11","sub4","c3",78,82), _m("s12","sub4","c3",82,86),
        _m("s13","sub4","c3",62,68), _m("s14","sub4","c3",58,63),
        _m("s15","sub4","c3",70,76),
    ])

    # ── 6. Teacher submissions (t1 and t2) ────────────────────────────────────
    now = datetime.now(timezone.utc)
    await db["submissions"].insert_many([
        {"_id": "t1", "submitted_at": now},
        {"_id": "t2", "submitted_at": now},
    ])

    # ── 7. App users ───────────────────────────────────────────────────────────
    await db["users"].insert_many([
        {"_id":"5829A","name":"Dr. T Musere",       "role":"admin",
         "hashed_password":_hash("admin123"),   "linked_id": None},
        {"_id":"u1",  "name":"Mr. Patrick Mwale",  "role":"teacher",
         "hashed_password":_hash("teacher123"), "linked_id":"t1"},
        {"_id":"u2",  "name":"Mrs. Grace Banda",   "role":"teacher",
         "hashed_password":_hash("teacher123"), "linked_id":"t2"},
        {"_id":"u3",  "name":"Mr. Benson Phiri",   "role":"teacher",
         "hashed_password":_hash("teacher123"), "linked_id":"t3"},
        {"_id":"u4",  "name":"Ms. Faith Tembo",    "role":"teacher",
         "hashed_password":_hash("teacher123"), "linked_id":"t4"},
        {"_id":"u5",  "name":"Chanda Mulenga",     "role":"student",
         "hashed_password":_hash("student123"), "linked_id":"s1"},
        {"_id":"u6",  "name":"Mwansa Kapata",      "role":"student",
         "hashed_password":_hash("student123"), "linked_id":"s2"},
        {"_id":"u7",  "name":"Bupe Mutale",        "role":"student",
         "hashed_password":_hash("student123"), "linked_id":"s3"},
        {"_id":"u8",  "name":"Natasha Phiri",      "role":"student",
         "hashed_password":_hash("student123"), "linked_id":"s4"},
        {"_id":"u9",  "name":"David Tembo",        "role":"student",
         "hashed_password":_hash("student123"), "linked_id":"s5"},
        {"_id":"u10", "name":"Kelvin Zulu",        "role":"student",
         "hashed_password":_hash("student123"), "linked_id":"s6"},
        {"_id":"u11", "name":"Susan Banda",        "role":"student",
         "hashed_password":_hash("student123"), "linked_id":"s7"},
        {"_id":"u12", "name":"Mable Musonda",      "role":"student",
         "hashed_password":_hash("student123"), "linked_id":"s11"},
        {"_id":"u13", "name":"Frank Kasonde",      "role":"student",
         "hashed_password":_hash("student123"), "linked_id":"s12"},
        {"_id":"u14", "name":"Raymond Mutumba",    "role":"student",
         "hashed_password":_hash("student123"), "linked_id":"s16"},
    ])

    # ── 8. Headmaster report ───────────────────────────────────────────────────
    await db["headmaster_report"].insert_one({
        "_id": "singleton",
        "comment": (
            "I am pleased to present the academic results for this term. "
            "Our students have demonstrated commendable effort and dedication. "
            "I encourage all learners to strive for excellence in the coming term."
        ),
        "signature": "Dr. James Banda",
    })

    print("[seed] MongoDB seeded successfully.")
