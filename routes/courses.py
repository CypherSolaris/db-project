# routes/courses.py
from flask import Blueprint, render_template, request, redirect, url_for, flash
from db import query, execute
from auth import login_required

bp = Blueprint('courses', __name__, url_prefix='/courses')

@bp.route('/')
@login_required()
def list_courses():
    courses = query("SELECT c.*, (SELECT COUNT(*) FROM course_bookings b WHERE b.course_id=c.id AND b.status='confirmed') AS booked FROM courses c")
    return render_template('course_booking.html', courses=courses)

@bp.route('/book/<int:course_id>/<int:member_id>', methods=['POST'])
@login_required()
def book(course_id, member_id):
    cap = query("SELECT capacity FROM courses WHERE id=%s", (course_id,))
    if not cap:
        flash('Kurs existiert nicht'); return redirect(url_for('courses.list_courses'))
    capacity = cap[0]['capacity']
    count = query("SELECT COUNT(*) AS c FROM course_bookings WHERE course_id=%s AND status='confirmed'", (course_id,))[0]['c']
    # Blockierung falls Beitrag offen
    fees_open = query("""SELECT COUNT(*) AS c FROM membership_fees f
                         WHERE f.member_id=%s AND f.status='open'""", (member_id,))[0]['c']
    status = 'confirmed'
    if fees_open > 0:
        status = 'blocked'
    elif count >= capacity:
        status = 'waitlist'
    execute("INSERT INTO course_bookings (course_id, member_id, status) VALUES (%s,%s,%s)",
            (course_id, member_id, status))
    flash(f'Buchung {status}')
    return redirect(url_for('courses.list_courses'))
