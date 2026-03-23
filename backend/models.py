# MongoDB document structures (for reference — no ORM needed)
#
# users        : {_id, name, role, hashed_password, linked_id}
# teachers     : {_id, name, subject_ids[], class_ids[]}
# subjects     : {_id, name, teacher_id}
# students     : {_id, name, class_id}
# classes      : {_id, name, student_ids[], teacher_ids[]}
# marks        : {student_id, subject_id, class_id, test_mark, exam_mark}
# submissions  : {_id (=teacher_id), submitted_at}
# headmaster_report : {_id:"singleton", comment, signature}
