-- db/sample_data.sql
USE sportverein;

INSERT INTO clubs (name, city) VALUES ('SC Rämibühl', 'Zürich');

INSERT INTO teams (club_id, name, category) VALUES (1, 'U18', 'U18'), (1, 'Elite', 'Elite');

INSERT INTO members (first_name, last_name, email, membership_type)
VALUES ('Alex','Meyer','alex@example.com','junior'),
       ('Lea','Keller','lea@example.com','active');

INSERT INTO trainers (first_name, last_name, email)
VALUES ('Kostas','Capkun','kostas@example.com');

INSERT INTO team_members (team_id, member_id) VALUES (1,1),(2,2);
INSERT INTO team_trainers (team_id, trainer_id) VALUES (1,1);

INSERT INTO courses (team_id, title, description, capacity, start_date, end_date)
VALUES (1,'Wintertechnik','Techniktraining',20,'2026-01-10','2026-03-15');

INSERT INTO training_sessions (team_id, starts_at, ends_at, location, content)
VALUES (1,'2026-01-12 18:00','2026-01-12 19:30','Halle A','Passübungen');

INSERT INTO competitions (name,date,location)
VALUES ('Stadtmeisterschaft','2026-02-01','Zürich');
