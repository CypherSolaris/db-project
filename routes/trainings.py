# routes/trainings.py
from flask import Blueprint, render_template, request, redirect, url_for, flash
from db import query, execute
from auth import login_required

bp = Blueprint('trainings', __name__, url_prefix='/trainings')

@bp.route('/plan/<int:team_id>', methods=['GET','POST'])
@login_required('trainer')
def plan(team_id):
    if request.method == 'POST':
        execute("""INSERT INTO training_sessions (team_id, starts_at, ends_at, location, content)
                   VALUES (%s,%s,%s,%s,%s)""",
                (team_id, request.form['starts_at'], request.form['ends_at'],
                 request.form.get('location'), request.form.get('content')))
        flash('Trainingstermin erstellt')
    sessions = query("SELECT * FROM training_sessions WHERE team_id=%s ORDER BY starts_at", (team_id,))
    return render_template('training_plan.html', sessions=sessions, team_id=team_id)

@bp.route('/cancel/<int:session_id>', methods=['POST'])
@login_required('trainer')
def cancel(session_id):
    execute("UPDATE training_sessions SET status='cancelled' WHERE id=%s", (session_id,))
    flash('Training abgesagt')
    return redirect(request.referrer or url_for('index'))
