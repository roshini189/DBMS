

--Task 5
-- Drop procedures if they exist
--Query 1
DROP PROCEDURE IF EXISTS AddNewTeam;
GO
CREATE PROCEDURE AddNewTeam
    @team_name VARCHAR(50),
    @team_type VARCHAR(50),
    @team_date DATE
AS
BEGIN
    -- Check if any team exists with the same team_name
    IF EXISTS (SELECT 1 FROM Teams 
               WHERE team_name = @team_name 
    )
    -- Insert team
    INSERT INTO Teams (team_name, team_type, team_date)
    VALUES (@team_name, @team_type, @team_date);
    
    PRINT 'Team successfully added.';
END;
SELECT * FROM Teams;-- for testing 
GO

--Query 2
DROP PROCEDURE IF EXISTS AddNewClientWithTeams;
GO
CREATE PROCEDURE AddNewClientWithTeams
    @SSN VARCHAR(20),
    @name VARCHAR(50),
    @gender CHAR(1),
    @profession VARCHAR(100),
    @mailing_address VARCHAR(200),
    @email_address VARCHAR(100),
    @phone_no VARCHAR(15),
    @mailing_list BIT,
    @doctor_name VARCHAR(50),
    @doctor_phone_no VARCHAR(15),
    @date_assigned DATE,
    @team_names NVARCHAR(MAX) ,-- Comma-separated list of team names
    @active_inactive BIT
AS
BEGIN
    -- PAN Table insertion
    BEGIN TRY
        INSERT INTO PAN (SSN, name, gender, profession, mailing_address, email_address, phone_no, mailing_list)
        VALUES (@SSN, @name, @gender, @profession, @mailing_address, @email_address, @phone_no, @mailing_list);
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting into PAN table';
        RETURN;
    END CATCH;
    -- Client Table Insertion
    BEGIN TRY
        INSERT INTO Client (SSN, doctor_name, doctor_phone_no, date_assigned)
        VALUES (@SSN, @doctor_name, @doctor_phone_no, @date_assigned);
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting into Client table';
        RETURN;
    END CATCH;
    -- Insert each team association into the Works table
    DECLARE @team_name VARCHAR(50);
    DECLARE @pos INT;

    SET @team_names = @team_names + ','; -- Add comma for easier parsing
    WHILE CHARINDEX(',', @team_names) > 0
    BEGIN
        SET @pos = CHARINDEX(',', @team_names);
        SET @team_name = LTRIM(RTRIM(SUBSTRING(@team_names, 1, @pos - 1)));
        SET @team_names = SUBSTRING(@team_names, @pos + 1, LEN(@team_names));

        -- Verify if the team exists before associating it with the client
        IF EXISTS (SELECT 1 FROM Teams WHERE team_name = @team_name)
        BEGIN
            BEGIN TRY
                INSERT INTO Works (team_name, Client_SSN, active_inactive)
                VALUES (@team_name, @SSN, @active_inactive);
            END TRY
            BEGIN CATCH
                PRINT 'Error inserting into Works table for team: ' + @team_name;
            END CATCH;
        END
        ELSE
        BEGIN
            PRINT 'Team not found: ' + @team_name;
        END
    END;
END;
--Testing
SELECT * from Client;
Select * from Works;
Select *from PAN;
Select *from Teams;
GO

--Query 3
DROP PROCEDURE IF EXISTS AddNewVolunteerWithTeams;
GO
CREATE PROCEDURE AddNewVolunteerWithTeams
    @SSN VARCHAR(20),
    @name VARCHAR(50),
    @gender CHAR(1),
    @profession VARCHAR(100),
    @mailing_address VARCHAR(200),
    @email_address VARCHAR(100),
    @phone_no VARCHAR(15),
    @mailing_list BIT,
    @date_joined DATE,
    @training_date DATE,
    @training_location VARCHAR(100),
    @team_names NVARCHAR(MAX),
    @active_inactive BIT -- Comma-separated list of team names
AS
BEGIN
    -- Insertion PAN table
    BEGIN TRY
        INSERT INTO PAN (SSN, name, gender, profession, mailing_address, email_address, phone_no,mailing_list)
        VALUES (@SSN, @name, @gender, @profession, @mailing_address, @email_address, @phone_no,@mailing_list);
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting into PAN table';
        RETURN;
    END CATCH;

    -- Insertion Volunteer table
    BEGIN TRY
        INSERT INTO Volunteer (SSN, date_joined, training_date, training_location)
        VALUES (@SSN, @date_joined, @training_date, @training_location);
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting into Volunteer table';
        RETURN;
    END CATCH;

    -- Insert each team association into the Contain table
    DECLARE @team_name VARCHAR(50);
    DECLARE @pos INT;

    SET @team_names = @team_names + ','; -- Add comma for easier parsing
    WHILE CHARINDEX(',', @team_names) > 0
    BEGIN
        SET @pos = CHARINDEX(',', @team_names);
        SET @team_name = LTRIM(RTRIM(SUBSTRING(@team_names, 1, @pos - 1)));
        SET @team_names = SUBSTRING(@team_names, @pos + 1, LEN(@team_names));

        -- Verify if the team exists before associating it with the volunteer
        IF EXISTS (SELECT 1 FROM Teams WHERE team_name = @team_name)
        BEGIN
            BEGIN TRY
                INSERT INTO Contain (team_name, Volunteer_SSN, active_inactive)
                VALUES (@team_name, @SSN, @active_inactive);
            END TRY
            BEGIN CATCH
                PRINT 'Error inserting into Contain table for team: ' + @team_name;
            END CATCH;
        END
        ELSE
        BEGIN
            PRINT 'Team not found: ' + @team_name;
        END
    END;
END;
SELECT * from Volunteer;
Select * from Contain;
Select *from PAN;
Select *from Teams;
GO

--Query 4
DROP PROCEDURE IF EXISTS EnterVolunteerHours;
GO
CREATE PROCEDURE EnterVolunteerHours
    @team_name VARCHAR(50),
    @Volunteer_SSN VARCHAR(20),
    @hours INT,
    @month VARCHAR(3) -- e.g., 'Jan', 'Feb', etc.
AS
-- Check if the volunteer is associated with the specified team
    IF NOT EXISTS (SELECT 1 
                   FROM Contain 
                   WHERE team_name = @team_name 
                     AND Volunteer_SSN = @Volunteer_SSN)
    BEGIN
        RAISERROR('Volunteer with SSN %s is not associated with team %s.', 16, 1, @Volunteer_SSN, @team_name);
        RETURN;
    END
BEGIN
    -- Check if a record with the same hours already exists for this volunteer and team
    IF EXISTS (SELECT 1 
               FROM Hour_month 
               WHERE team_name = @team_name 
                 AND Volunteer_SSN = @Volunteer_SSN 
                 AND hours = @hours)
    BEGIN
        RAISERROR('This volunteer already logged %d hours for the team %s in a previous month. Please enter a different number of hours.', 
        16, 1, @hours, @team_name);
        RETURN;
    END

    -- Insert the hours worked for the volunteer in the specified month if all checks pass
    BEGIN TRY
        INSERT INTO Hour_month (team_name, Volunteer_SSN, hours, months)
        VALUES (@team_name, @Volunteer_SSN, @hours, @month);
        
        PRINT 'Hours successfully added for the volunteer.';
    END TRY
    BEGIN CATCH
        RAISERROR('Error inserting hours for Volunteer SSN: %s in team: %s', 16, 1, @Volunteer_SSN, @team_name);
    END CATCH;
END;
GO
SELECT * FROM Contain;
select *from Volunteer;
select * from Hour_month;
GO

--Query 5
DROP PROCEDURE IF EXISTS AddNewEmployeeWithTeams;
GO

CREATE PROCEDURE AddNewEmployeeWithTeams
    @SSN VARCHAR(20),
    @name VARCHAR(50),
    @gender CHAR(1),
    @profession VARCHAR(100),
    @mailing_address VARCHAR(200),
    @email_address VARCHAR(100),
    @phone_no VARCHAR(15),
    @mailing_list BIT,
    @emp_sal DECIMAL(10, 2),
    @marital_status VARCHAR(10),
    @hire_date DATE,
    @team_names NVARCHAR(MAX),
    @report_date DATE,
    @description VARCHAR(255)
AS
BEGIN
    -- PAN table
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM PAN WHERE SSN = @SSN)
        BEGIN
            INSERT INTO PAN (SSN, name, gender, profession, mailing_address, email_address, phone_no, mailing_list)
            VALUES (@SSN, @name, @gender, @profession, @mailing_address, @email_address, @phone_no, @mailing_list);
        END
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting into PAN table';
        RETURN;
    END CATCH;

    -- Employee table
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Employee WHERE SSN = @SSN)
        BEGIN
            INSERT INTO Employee (SSN, emp_sal, marital_status, hire_date)
            VALUES (@SSN, @emp_sal, @marital_status, @hire_date);
        END
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting into Employee table';
        RETURN;
    END CATCH;

    -- Insert each team association into the Reports table
    DECLARE @team_name VARCHAR(50);
    DECLARE @pos INT;

    SET @team_names = @team_names + ','; -- Add comma for easier parsing
    WHILE CHARINDEX(',', @team_names) > 0
    BEGIN
        SET @pos = CHARINDEX(',', @team_names);
        SET @team_name = LTRIM(RTRIM(SUBSTRING(@team_names, 1, @pos - 1)));
        SET @team_names = SUBSTRING(@team_names, @pos + 1, LEN(@team_names));

        -- Verify if the team exists before associating it with the employee
        IF EXISTS (SELECT 1 FROM Teams WHERE team_name = @team_name)
        BEGIN
            BEGIN TRY
                -- Insert the team association in the Reports table only if not already present
                IF NOT EXISTS (SELECT 1 FROM Reports WHERE team_name = @team_name AND Employee_SSN = @SSN)
                BEGIN
                    INSERT INTO Reports (team_name, Employee_SSN, report_date, description)
                    VALUES (@team_name, @SSN, @report_date, @description);
                END
            END TRY
            BEGIN CATCH
                PRINT 'Error inserting into Reports table for team: ' + @team_name;
            END CATCH;
        END
        ELSE
        BEGIN
            PRINT 'Team not found: ' + @team_name;
        END
    END;
END;


SELECT * FROM PAN;
SELECT * FROM Teams;
SELECT * FROM Reports;
GO
-- Query 6
DROP PROCEDURE IF EXISTS EnterEmployeeExpense;
GO
CREATE PROCEDURE EnterEmployeeExpense
    @Employee_SSN VARCHAR(20),
    @description VARCHAR(255),
    @expense_date DATE,
    @amount DECIMAL(10, 2)
AS
BEGIN
    -- Check if the employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE SSN = @Employee_SSN)
    BEGIN
        RAISERROR ('Employee not found with SSN: %s', 16, 1, @Employee_SSN);
        RETURN;
    END
    -- Insert the expense charged by the employee
    BEGIN TRY
        INSERT INTO Expenses (Employee_SSN, description, expense_date, amount)
        VALUES (@Employee_SSN, @description, @expense_date, @amount);
        PRINT 'Expense successfully added for Employee SSN: ' + @Employee_SSN;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR ('Error inserting expense for Employee SSN %s: %s', 16, 1, @Employee_SSN, @ErrorMessage);
    END CATCH;
END;
GO

Select *from Employee;
select *from Expenses;
GO
--Query 7
DROP PROCEDURE IF EXISTS AddNewDonorWithDonations;
GO
CREATE PROCEDURE AddNewDonorWithDonations
    @SSN VARCHAR(20),
    @name VARCHAR(50),
    @gender CHAR(1),
    @profession VARCHAR(100),
    @mailing_address VARCHAR(200),
    @email_address VARCHAR(100),
    @phone_no VARCHAR(15),
    @mailing_list BIT,
    @anonymous_donor BIT,
    @donation_details NVARCHAR(MAX) -- Comma-separated list of donation details
AS
BEGIN
    -- Insert into PAN if donor doesn't exist
    IF NOT EXISTS (SELECT 1 FROM PAN WHERE SSN = @SSN)
    BEGIN
        INSERT INTO PAN (SSN, name, gender, profession, mailing_address, email_address, phone_no, mailing_list)
        VALUES (@SSN, @name, @gender, @profession, @mailing_address, @email_address, @phone_no, @mailing_list);
    END

    -- Insert into Donor if not already present
    IF NOT EXISTS (SELECT 1 FROM Donor WHERE SSN = @SSN)
    BEGIN
        INSERT INTO Donor (SSN, anonymous_donor)
        VALUES (@SSN, @anonymous_donor);
    END
    -- Parse and process donations
    DECLARE @donation_date DATE;
    DECLARE @donation_amount DECIMAL(10, 2);
    DECLARE @donation_type VARCHAR(50);
    DECLARE @campaign_name VARCHAR(100);
    DECLARE @cheque_number INT;
    DECLARE @card_no VARCHAR(20);
    DECLARE @card_type VARCHAR(20);
    DECLARE @expiry_date DATE;

    DECLARE @donation NVARCHAR(255);
    DECLARE @pos INT;

    WHILE CHARINDEX(';', @donation_details) > 0
    BEGIN
        SET @pos = CHARINDEX(';', @donation_details);
        SET @donation = LTRIM(RTRIM(SUBSTRING(@donation_details, 1, @pos - 1)));
        SET @donation_details = SUBSTRING(@donation_details, @pos + 1, LEN(@donation_details));

        -- Parse each field from the donation details string based on commas
        SET @donation_date = CAST(SUBSTRING(@donation, 1, CHARINDEX(',', @donation) - 1) AS DATE);
        SET @donation = SUBSTRING(@donation, CHARINDEX(',', @donation) + 1, LEN(@donation));
        
        SET @donation_amount = CAST(SUBSTRING(@donation, 1, CHARINDEX(',', @donation) - 1) AS DECIMAL(10, 2));
        SET @donation = SUBSTRING(@donation, CHARINDEX(',', @donation) + 1, LEN(@donation));
        
        SET @donation_type = LTRIM(RTRIM(SUBSTRING(@donation, 1, CHARINDEX(',', @donation) - 1)));
        SET @donation = SUBSTRING(@donation, CHARINDEX(',', @donation) + 1, LEN(@donation));

        SET @campaign_name = LTRIM(RTRIM(SUBSTRING(@donation, 1, CHARINDEX(',', @donation) - 1)));
        SET @donation = SUBSTRING(@donation, CHARINDEX(',', @donation) + 1, LEN(@donation));
        IF LOWER(@donation_type) = 'cheque'
        BEGIN
            SET @cheque_number = CAST(@donation AS INT);

            IF NOT EXISTS (SELECT 1 FROM Cheque WHERE cheque_number = @cheque_number)
            BEGIN
                INSERT INTO Cheque (Donor_SSN, donation_date, donation_amount, donation_type, campaign_name, cheque_number)
                VALUES (@SSN, @donation_date, @donation_amount, @donation_type, @campaign_name, @cheque_number);
            END
        END
        ELSE IF LOWER(@donation_type) = 'credit'
        BEGIN
            SET @card_no = LTRIM(RTRIM(SUBSTRING(@donation, 1, CHARINDEX(',', @donation) - 1)));
            SET @donation = SUBSTRING(@donation, CHARINDEX(',', @donation) + 1, LEN(@donation));

            SET @card_type = LTRIM(RTRIM(SUBSTRING(@donation, 1, CHARINDEX(',', @donation) - 1)));
            SET @donation = SUBSTRING(@donation, CHARINDEX(',', @donation) + 1, LEN(@donation));

            SET @expiry_date = CAST(@donation AS DATE);

            IF NOT EXISTS (SELECT 1 FROM Credit_card WHERE card_no = @card_no)
            BEGIN
                INSERT INTO Credit_card (Donor_SSN, donation_date, donation_amount, donation_type, campaign_name, card_no, card_type, expiry_date)
                VALUES (@SSN, @donation_date, @donation_amount, @donation_type, @campaign_name, @card_no, @card_type, @expiry_date);
            END
        END
        ELSE
        BEGIN
            PRINT 'Invalid donation type: ' + @donation_type + '. Only "cheque" and "credit" are allowed.';
            RETURN;
        END
    END;
END;
GO
select *from PAN;
select *from Donor;
select *from Cheque;
select *from Credit_card;
GO


--Query 8
DROP PROCEDURE IF EXISTS GetClientDoctorInfo;
GO
CREATE PROCEDURE GetClientDoctorInfo
    @Client_SSN VARCHAR(10)
AS
BEGIN
    -- Retrieve the doctor's name and phone number for the specified client
    SELECT doctor_name, doctor_phone_no
    FROM Client
    WHERE SSN = @Client_SSN;
END;
select * from Client;
GO

--Query 9
select *from Employee;
select *from Expenses;
DROP PROCEDURE IF EXISTS GetTotalExpensesByEmployee;
GO

CREATE PROCEDURE GetTotalExpensesByEmployee
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    -- Retrieve the total amount of expenses charged by each employee within the specified period
    SELECT 
        Employee_SSN, 
        SUM(amount) AS total_expenses
    FROM 
        Expenses
    WHERE 
        expense_date BETWEEN @start_date AND @end_date
    GROUP BY 
        Employee_SSN
    ORDER BY 
        total_expenses DESC;
END;
GO

--Query 10
DROP PROCEDURE IF EXISTS GetVolunteersForClient;
GO

CREATE PROCEDURE GetVolunteersForClient
    @Client_SSN VARCHAR(10)
AS
BEGIN
    SELECT Volunteer.SSN, Volunteer.training_location
    FROM Volunteer
    INNER JOIN Contain ON Volunteer.SSN = Contain.Volunteer_SSN
    INNER JOIN Works ON Contain.team_name = Works.team_name
    WHERE Works.Client_SSN = @Client_SSN;
END;
GO
select *from Client;
select *from Volunteer;
select *from Contain;
select *from Works;
GO
--Query 11
DROP PROCEDURE IF EXISTS GetTeamsFoundedAfterDate;
GO
CREATE PROCEDURE GetTeamsFoundedAfterDate
    @date DATE
AS
BEGIN
    -- Retrieve the names of all teams that were founded after the specified date
    SELECT team_name
    FROM Teams
    WHERE team_date > @date;
END;
select *FROM Teams;
GO

--Query 12
DROP PROCEDURE IF EXISTS GetAllPeopleWithEmergencyContacts;
GO
CREATE PROCEDURE GetAllPeopleWithEmergencyContacts
AS
BEGIN
    -- Retrieve names, SSNs, and contact information along with emergency contact information
    SELECT 
        PAN.SSN,
        PAN.name,
        PAN.phone_no AS main_phone,
        PAN.email_address,
        Emergency_contact.phone_no AS emergency_phone,
        Emergency_contact.name AS emergency_contact_name,
        Emergency_contact.relation AS emergency_relation
    FROM PAN
    LEFT JOIN Emergency_contact ON PAN.SSN = Emergency_contact.SSN;
END;
select *from PAN;
INSERT INTO Emergency_contact (SSN, phone_no, name, relation) VALUES
('1234567890', '1234567890', 'Alice', 'Friend'),
('2345678901', '2345678901', 'Bob', 'Parent'),
('3456789012', '3456789012', 'Charlie', 'Sibling'),
('4567890123', '4567890123', 'Diana', 'Spouse'),
('5678901234', '5678901234', 'Eva', 'Friend'),
('5678901347', '5678901347', 'Frank', 'Parent'),
('6011002344', '6011002344', 'Grace', 'Sibling'),
('6011002409', '6011002409', 'Henry', 'Parent'),
('6011002456', '6011002456', 'Isabella', 'Friend'),
('6011003102', '6011003102', 'John', 'Spouse'),
('6011003203', '6011003203', 'Kathy', 'Friend'),
('6011014562', '6011014562', 'Leo', 'Sibling'),
('6119390246', '6119390246', 'Mia', 'Parent'),
('6124363754', '6124363754', 'Nina', 'Friend'),
('6281392353', '6281392353', 'Olivia', 'Spouse'),
('6281392467', '6281392467', 'Paul', 'Parent'),
('6281456789', '6281456789', 'Quinn', 'Sibling'),
('6381557890', '6381557890', 'Rachel', 'Friend'),
('6437882899', '6437882899', 'Steve', 'Parent'),
('6583938838', '6583938838', 'Tina', 'Sibling');

GO
--Query 13
DROP PROCEDURE IF EXISTS GetEmployeeDonorTotalDonations;
GO
CREATE PROCEDURE GetEmployeeDonorTotalDonations
AS
BEGIN
    -- Retrieve the name, total donation amount, and anonymous status for donors who are also employees
    SELECT 
        PAN.name,
        Donor.SSN,
        SUM(COALESCE(Cheque.donation_amount, 0) + COALESCE(Credit_card.donation_amount, 0)) AS total_donations,
        Donor.anonymous_donor
    FROM Donor
    INNER JOIN Employee ON Donor.SSN = Employee.SSN
    INNER JOIN PAN ON Donor.SSN = PAN.SSN
    LEFT JOIN Cheque ON Donor.SSN = Cheque.Donor_SSN
    LEFT JOIN Credit_card ON Donor.SSN = Credit_card.Donor_SSN
    GROUP BY PAN.name, Donor.SSN, Donor.anonymous_donor
    ORDER BY total_donations DESC;
END;
select * from Employee;
GO

--Query 14
DROP PROCEDURE IF EXISTS IncreaseSalaryForMultiTeamEmployees;
GO
CREATE PROCEDURE IncreaseSalaryForMultiTeamEmployees
AS
BEGIN
    -- Update salaries for employees who are associated with more than one team
    UPDATE Employee
    SET emp_sal = emp_sal * 1.10
    WHERE SSN IN (
        SELECT Employee_SSN
        FROM Reports
        GROUP BY Employee_SSN
        HAVING COUNT(DISTINCT team_name) > 1
    );
END;

select *from Employee;
select *from Reports;
GO
--Query 15

DROP PROCEDURE IF EXISTS DeleteClientsWithoutHealthInsuranceAndLowTransportImportance;
GO
CREATE PROCEDURE DeleteClientsWithoutHealthInsuranceAndLowTransportImportance
AS
BEGIN
    -- Temporary table to store the SSNs of clients to delete
    DECLARE @clientsToDelete TABLE (SSN VARCHAR(20));
    -- Populate the temporary table with clients who meet the deletion criteria
    INSERT INTO @clientsToDelete (SSN)
    SELECT c.SSN
    FROM Client AS c
    LEFT JOIN Insurance_policy AS i ON c.SSN = i.Client_SSN AND i.type = 'health'
    LEFT JOIN Needs AS n ON c.SSN = n.Client_SSN AND n.needs_type = 'transportation'
    WHERE i.Client_SSN IS NULL  -- No health insurance
      AND (n.importance_value IS NULL OR n.importance_value < 5);  -- Low or missing transportation importance
    -- Delete from dependent tables to avoid foreign key constraints
    DELETE FROM Works WHERE Client_SSN IN (SELECT SSN FROM @clientsToDelete);
    DELETE FROM Needs WHERE Client_SSN IN (SELECT SSN FROM @clientsToDelete);
    DELETE FROM Insurance_policy WHERE Client_SSN IN (SELECT SSN FROM @clientsToDelete);
    -- Finally, delete the clients from the Client table
    DELETE FROM Client WHERE SSN IN (SELECT SSN FROM @clientsToDelete);
    PRINT 'Clients deleted successfully based on the specified criteria.';
END;
select * from Client;
select *from Insurance_policy;
select *from Needs;
select *from Works;
GO
select*from Volunteer;