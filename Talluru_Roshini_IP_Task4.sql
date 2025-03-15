--Task 4

-- Drop tables in the correct order to handle dependencies
DROP TABLE IF EXISTS Credit_card;
DROP TABLE IF EXISTS Cheque;
DROP TABLE IF EXISTS Donor;
DROP TABLE IF EXISTS Expenses;
DROP TABLE IF EXISTS Reports;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Works;
DROP TABLE IF EXISTS Serves_Team_leader;
DROP TABLE IF EXISTS Hour_month;
DROP TABLE IF EXISTS Contain;
DROP TABLE IF EXISTS Teams;
DROP TABLE IF EXISTS Volunteer;
DROP TABLE IF EXISTS Insurance_policy;
DROP TABLE IF EXISTS Needs;
DROP TABLE IF EXISTS Client;
DROP TABLE IF EXISTS Emergency_contact;
DROP TABLE IF EXISTS PAN;


---PAN Table
CREATE TABLE PAN (
    SSN VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50),
    gender CHAR(1) CHECK (gender IN ('M', 'F')),
    profession VARCHAR(100),
    mailing_address VARCHAR(200),
    email_address VARCHAR(100),
    phone_no VARCHAR(15),
    mailing_list BIT
);

--Emergency Contact
CREATE TABLE Emergency_contact (
    SSN VARCHAR(20),
    phone_no VARCHAR(15),
    name VARCHAR(50),
    relation VARCHAR(50),
    PRIMARY KEY (SSN, phone_no),
    FOREIGN KEY (SSN) REFERENCES PAN(SSN)
);

--Client
CREATE TABLE Client (
    SSN VARCHAR(20) PRIMARY KEY,
    doctor_name VARCHAR(50),
    doctor_phone_no VARCHAR(15),
    date_assigned DATE,
    FOREIGN KEY (SSN) REFERENCES PAN(SSN)
);

--Needs
CREATE TABLE Needs (
    Client_SSN VARCHAR(20),
    needs_type VARCHAR(50),
    importance_value TINYINT CHECK (importance_value BETWEEN 1 AND 10),
    PRIMARY KEY (Client_SSN, needs_type, importance_value),
    FOREIGN KEY (Client_SSN) REFERENCES Client(SSN)
);

--Insurance_policy
CREATE TABLE Insurance_policy (
    policy_id INT PRIMARY KEY, -- Clustered index on policy_id
    Client_SSN VARCHAR(20),
    name VARCHAR(50),
    address VARCHAR(200),
    type VARCHAR(50) CHECK (type IN ('life', 'health', 'home','auto')),
    FOREIGN KEY (Client_SSN) REFERENCES Client(SSN)
);

CREATE NONCLUSTERED INDEX idx_type ON Insurance_policy(type); -- Non-clustered index on type

--Volunteer
CREATE TABLE Volunteer (
    SSN VARCHAR(20) PRIMARY KEY,
    date_joined DATE,
    training_date DATE,
    training_location VARCHAR(100),
    FOREIGN KEY (SSN) REFERENCES PAN(SSN)
);

--Team
CREATE TABLE Teams (
    team_name VARCHAR(50) PRIMARY KEY, -- Clustered index on team_name
    team_type VARCHAR(50),
    team_date DATE
);

CREATE NONCLUSTERED INDEX idx_team_date ON Teams(team_date); -- Non-clustered index on team_date

--Contain
CREATE TABLE Contain (
    team_name VARCHAR(50),
    Volunteer_SSN VARCHAR(20),
    active_inactive VARCHAR(10) Default 1, -- 1for active, 0 for inactive 
    PRIMARY KEY (team_name, Volunteer_SSN),
    FOREIGN KEY (team_name) REFERENCES Teams(team_name),
    FOREIGN KEY (Volunteer_SSN) REFERENCES Volunteer(SSN)
);

--Hour/Month
CREATE TABLE Hour_month (
    team_name VARCHAR(50),
    Volunteer_SSN VARCHAR(20),
    hours INT CHECK (hours > 0), -- Ensure hours is greater than 0
    months VARCHAR(3) CHECK (months IN ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')), -- Constrain months to valid values
    PRIMARY KEY (team_name, Volunteer_SSN,hours,months),
    FOREIGN KEY (team_name,Volunteer_SSN) REFERENCES Contain(team_name,Volunteer_SSN),
   
);

-- Team Leader
CREATE TABLE Serves_Team_leader (
    team_name VARCHAR(50),
    Volunteer_SSN VARCHAR(10),
    PRIMARY KEY (team_name),
    FOREIGN KEY (team_name) REFERENCES Teams(team_name)
);

--Works
CREATE TABLE Works (
    team_name VARCHAR(50),
    Client_SSN VARCHAR(20),
    active_inactive VARCHAR(10) DEFAULT 1,-- 1 for active, 0 -inactive 
    PRIMARY KEY (team_name, Client_SSN),
    FOREIGN KEY (team_name) REFERENCES Teams(team_name),
    FOREIGN KEY (Client_SSN) REFERENCES Client(SSN)
);
--Employee
CREATE TABLE Employee (
    SSN VARCHAR(20) PRIMARY KEY,
    emp_sal DECIMAL(10, 2),
    marital_status VARCHAR(10),
    hire_date DATE,
    FOREIGN KEY (SSN) REFERENCES PAN(SSN)
);

--Reports
CREATE TABLE Reports (
    team_name VARCHAR(50) PRIMARY KEY,
    Employee_SSN VARCHAR(20),
    report_date DATE,
    description VARCHAR(255),
    FOREIGN KEY (team_name) REFERENCES Teams(team_name),
    FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN)
);

--Expenses
CREATE TABLE Expenses (
    Employee_SSN VARCHAR(20),
    description VARCHAR(255),
    expense_date DATE,
    amount DECIMAL(10, 2),
    PRIMARY KEY (Employee_SSN, description), 
    FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN)
);

CREATE NONCLUSTERED INDEX idx_expense_date ON Expenses(expense_date); -- Non-clustered index on expense_date

--Donor
CREATE TABLE Donor (
    SSN VARCHAR(20) PRIMARY KEY,
    anonymous_donor BIT,
    FOREIGN KEY (SSN) REFERENCES PAN(SSN)
);

--Cheque
CREATE TABLE Cheque (
    Donor_SSN VARCHAR(20),
    donation_date DATE,
    donation_amount DECIMAL(10, 2),
    donation_type VARCHAR(50),
    campaign_name VARCHAR(100),
    cheque_number INT,
    PRIMARY KEY (Donor_SSN, donation_date, cheque_number),
    FOREIGN KEY (Donor_SSN) REFERENCES Donor(SSN)
);

--Credit Card Table
CREATE TABLE Credit_card (
    Donor_SSN VARCHAR(20),
    donation_date DATE,
    donation_amount DECIMAL(10, 2),
    donation_type VARCHAR(50),
    campaign_name VARCHAR(100),
    card_no VARCHAR(20),
    card_type VARCHAR(20),
    expiry_date DATE,
    PRIMARY KEY (Donor_SSN, donation_date, card_no),
    FOREIGN KEY (Donor_SSN) REFERENCES Donor(SSN)
);