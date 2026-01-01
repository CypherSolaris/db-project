# routes/members.py 
from flask import Blueprint, render_template, request, redirect, url_for, flash
from db import query, execute
from auth import login_required

bp = Blueprint('members', __name__, url_prefix='/members')

@bp.route('/')
@login_required()
def list_members():
    members = query("SELECT * FROM members ORDER BY last_name")
    return render_template('members_list.html', members=members)

@bp.route('/new', methods=['GET','POST'])
@login_required()
def new_member():
    if request.method == 'POST':
        data = {
            'first_name': request.form['first_name'].strip(),
            'last_name': request.form['last_name'].strip(),
            'email': request.form.get('email') or None,
            'membership_type': request.form.get('membership_type','active'),
            'status': 'active'
        }
        exists = query("SELECT id FROM members WHERE first_name=%s AND last_name=%s AND email<=>%s",
                       (data['first_name'], data['last_name'], data['email']))
        if exists:
            flash('Mitglied existiert bereits')
            return redirect(url_for('members.list_members'))
        execute("""INSERT INTO members (first_name,last_name,email,membership_type,status)
                   VALUES (%s,%s,%s,%s,%s)""",
                (data['first_name'], data['last_name'], data['email'], data['membership_type'], data['status']))
        flash('Mitglied erfasst')
        return redirect(url_for('members.list_members'))
    return render_template('member_form.html')

@bp.route('/fees/<int:member_id>', methods=['GET','POST'])
@login_required()
def manage_fees(member_id):
    if request.method == 'POST':
        period = int(request.form['period'])
        category = request.form['category']
        amount = float(request.form['amount'])
        # Anlegen oder aktualisieren
        existing = query("SELECT id FROM membership_fees WHERE member_id=%s AND period=%s", (member_id, period))
        if existing:
            execute("UPDATE membership_fees SET category=%s, amount=%s WHERE id=%s",
                    (category, amount, existing[0]['id']))
        else:
            execute("INSERT INTO membership_fees (member_id, period, category, amount) VALUES (%s,%s,%s,%s)",
                    (member_id, period, category, amount))
    fees = query("SELECT * FROM membership_fees WHERE member_id=%s", (member_id,))
    return render_template('payments_list.html', fees=fees, member_id=member_id)

@bp.route('/fees/pay/<int:fee_id>', methods=['POST'])
@login_required()
def pay_fee(fee_id):
    amount = float(request.form['amount'])
    execute("INSERT INTO payments (fee_id, amount, paid_at, method) VALUES (%s,%s,NOW(),%s)",
            (fee_id, amount, request.form.get('method','bank')))
    # Status auf paid setzen, falls Summe erreicht
    total = query("SELECT SUM(amount) AS s FROM payments WHERE fee_id=%s", (fee_id,))[0]['s'] or 0
    fee = query("SELECT amount FROM membership_fees WHERE id=%s", (fee_id,))[0]['amount']
    if total >= fee:
        execute("UPDATE membership_fees SET status='paid' WHERE id=%s", (fee_id,))
    return redirect(request.referrer or url_for('index'))
