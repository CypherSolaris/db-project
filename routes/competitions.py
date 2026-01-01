# routes/competitions.py
from flask import Blueprint, render_template, request, redirect, url_for, flash
from db import query, execute
from auth import login_required

bp = Blueprint('competitions', __name__, url_prefix='/competitions')

@bp.route('/')
@login_required()
def list_competitions():
    comps = query("SELECT * FROM competitions ORDER BY date DESC")
    return render_template('competitions_list.html', competitions=comps)

@bp.route('/result/new', methods=['POST'])
@login_required()
def add_result():
    entry_id = int(request.form['entry_id'])
    placement = request.form.get('placement')
    points = request.form.get('points')
    time_sec = request.form.get('time_sec')
    status = request.form.get('status','final')
    execute("""INSERT INTO competition_results (entry_id, placement, points, time_sec, status)
               VALUES (%s,%s,%s,%s,%s)""",
            (entry_id, placement, points, time_sec, status))
    flash('Ergebnis erfasst')
    return redirect(url_for('competitions.list_competitions'))
