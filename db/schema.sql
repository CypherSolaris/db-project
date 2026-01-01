-- db/schema.sql
CREATE DATABASE IF NOT EXISTS sportverein CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sportverein;

-- Rollen für Auth
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','trainer','member') NOT NULL DEFAULT 'member',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Club (für spätere Erweiterungen; 1..* Teams)
CREATE TABLE clubs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  city VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Mitglieder (Spieler*innen)
CREATE TABLE members (
  id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  birth_date DATE,
  address VARCHAR(255),
  phone VARCHAR(50),
  email VARCHAR(255),
  membership_type ENUM('active','junior','passive') DEFAULT 'active',
  status ENUM('active','incomplete') DEFAULT 'active',
  user_id INT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Trainer*innen
CREATE TABLE trainers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255),
  phone VARCHAR(50),
  user_id INT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Teams
CREATE TABLE teams (
  id INT AUTO_INCREMENT PRIMARY KEY,
  club_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100), -- z.B. U18, Elite, etc.
  FOREIGN KEY (club_id) REFERENCES clubs(id) ON DELETE CASCADE
);

-- N-M: Mitglied gehört zu Team
CREATE TABLE team_members (
  team_id INT NOT NULL,
  member_id INT NOT NULL,
  role ENUM('player','captain') DEFAULT 'player',
  PRIMARY KEY (team_id, member_id),
  FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
);

-- N-M: Trainer coacht Team
CREATE TABLE team_trainers (
  team_id INT NOT NULL,
  trainer_id INT NOT NULL,
  PRIMARY KEY (team_id, trainer_id),
  FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
  FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE CASCADE
);

-- Kurse/Trainingsgruppen (buchbar)
CREATE TABLE courses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  team_id INT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  capacity INT NOT NULL,
  start_date DATE,
  end_date DATE,
  FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE SET NULL
);

-- N-M: Buchungen Mitglied–Kurs (inkl. Warteliste)
CREATE TABLE course_bookings (
  course_id INT NOT NULL,
  member_id INT NOT NULL,
  status ENUM('confirmed','waitlist','blocked') NOT NULL DEFAULT 'confirmed',
  booked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (course_id, member_id),
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
);

-- Trainingstermine (Teil des Trainingsplans)
CREATE TABLE training_sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  team_id INT NOT NULL,
  starts_at DATETIME NOT NULL,
  ends_at DATETIME NOT NULL,
  location VARCHAR(255),
  content TEXT,
  status ENUM('scheduled','cancelled') DEFAULT 'scheduled',
  FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
);

-- Optional: Zuordnung Trainer -> Termin
CREATE TABLE session_trainers (
  session_id INT NOT NULL,
  trainer_id INT NOT NULL,
  PRIMARY KEY (session_id, trainer_id),
  FOREIGN KEY (session_id) REFERENCES training_sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE CASCADE
);

-- Beiträge/Kontingente
CREATE TABLE membership_fees (
  id INT AUTO_INCREMENT PRIMARY KEY,
  member_id INT NOT NULL,
  period YEAR NOT NULL,
  category ENUM('active','junior','passive') NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  status ENUM('open','paid') DEFAULT 'open',
  UNIQUE KEY (member_id, period),
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
);

-- Zahlungen
CREATE TABLE payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  fee_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  paid_at DATETIME NOT NULL,
  method ENUM('cash','bank','card') DEFAULT 'bank',
  FOREIGN KEY (fee_id) REFERENCES membership_fees(id) ON DELETE CASCADE
);

-- Wettkämpfe
CREATE TABLE competitions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  date DATE NOT NULL,
  location VARCHAR(255),
  status ENUM('scheduled','completed','provisional') DEFAULT 'scheduled'
);

-- Teilnahme (Mitglied oder Team)
CREATE TABLE competition_entries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  competition_id INT NOT NULL,
  member_id INT NULL,
  team_id INT NULL,
  CHECK ((member_id IS NOT NULL) XOR (team_id IS NOT NULL)),
  FOREIGN KEY (competition_id) REFERENCES competitions(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE SET NULL,
  FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE SET NULL
);

-- Ergebnisse
CREATE TABLE competition_results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  entry_id INT NOT NULL,
  placement INT NULL,
  points DECIMAL(10,2) NULL,
  time_sec DECIMAL(10,2) NULL,
  status ENUM('final','provisional') DEFAULT 'final',
  FOREIGN KEY (entry_id) REFERENCES competition_entries(id) ON DELETE CASCADE
);
