from flask import Flask, render_template, request, redirect
from flask_sqlalchemy import SQLAlchemy
import os
import time

app = Flask(__name__)

# Database Configuration
DB_USER = os.getenv("DB_USER", "laravel")
DB_PASSWORD = os.getenv("DB_PASSWORD", "securepassword")
DB_HOST = os.getenv("DB_HOST", "db")
DB_NAME = os.getenv("DB_NAME", "issue_tracker")

# Database Connection String
app.config["SQLALCHEMY_DATABASE_URI"] = f"mysql+mysqlconnector://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

# Issue Model
class Issue(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    description = db.Column(db.String(255), nullable=False)
    resolved = db.Column(db.Boolean, default=False)

# ✅ Create database tables when the app starts
@app.before_first_request
def create_tables():
    db.create_all()
    
# Ensure database tables are created
def wait_for_mysql():
    """Waits for MySQL to be ready before starting Flask"""
    retries = 5
    while retries > 0:
        try:
            db.create_all()
            print("✅ Database and tables created successfully!")
            return
        except Exception as e:
            print(f"Waiting for MySQL... ({retries} retries left)")
            time.sleep(5)
            retries -= 1
    print("❌ MySQL not ready. Exiting.")
    exit(1)

with app.app_context():
    wait_for_mysql()

@app.route('/')
def home():
    issues = Issue.query.all()
    return render_template('index.html', issues=issues)

@app.route('/submit', methods=['POST'])
def submit():
    issue_desc = request.form.get('issue')
    new_issue = Issue(description=issue_desc)
    db.session.add(new_issue)
    db.session.commit()
    return redirect('/')

@app.route('/resolve/<int:issue_id>')
def resolve(issue_id):
    issue = Issue.query.get(issue_id)
    if issue:
        issue.resolved = True
        db.session.commit()
    return redirect('/')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)