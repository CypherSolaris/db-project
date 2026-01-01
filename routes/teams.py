# routes/teams.py
from flask import Blueprint, render_template
from db import query
from auth import login_required

bp = Blueprint('teams', __name__, url_prefix='/teams')

@bp.route('/')
@login_required()
def list_teams():
    teams = query("""SELECT t.*, c.name AS club_name
                     FROM teams t JOIN clubs c ON c.id=t.club_id""")
    return render_template('teams_list.html', teams=teams)
