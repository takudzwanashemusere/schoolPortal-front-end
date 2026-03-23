from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database import engine, SessionLocal
import models
from seed import seed_database
from routers import auth_router, teachers, students, classes, subjects, marks, admin, reports

# Create all tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="School Portal API",
    description="High School Results Management System — REST API",
    version="1.0.0",
)

# ── CORS (allow Flutter web on any localhost port) ────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://localhost:\d+",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Seed on startup ───────────────────────────────────────────────────────────
@app.on_event("startup")
def on_startup():
    db = SessionLocal()
    try:
        seed_database(db)
    finally:
        db.close()


# ── Routers ───────────────────────────────────────────────────────────────────
app.include_router(auth_router.router,  prefix="/auth",      tags=["Auth"])
app.include_router(teachers.router,     prefix="/teachers",  tags=["Teachers"])
app.include_router(students.router,     prefix="/students",  tags=["Students"])
app.include_router(classes.router,      prefix="/classes",   tags=["Classes"])
app.include_router(subjects.router,     prefix="/subjects",  tags=["Subjects"])
app.include_router(marks.router,        prefix="/marks",     tags=["Marks"])
app.include_router(admin.router,        prefix="/admin",     tags=["Admin"])
app.include_router(reports.router,      prefix="/reports",   tags=["Reports"])


@app.get("/", tags=["Health"])
def root():
    return {"status": "ok", "message": "School Portal API is running"}
