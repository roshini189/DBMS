import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.*;
import java.util.InputMismatchException;
import java.util.Scanner;

public class Individual_project{

    // Database credentials and connection URL for Azure SQL
    final static String HOSTNAME = "tall0042-sql-server.database.windows.net";
    final static String DBNAME = "cs-dsa-4513-sql-db";
    final static String USERNAME = "tall0042";
    final static String PASSWORD = "Rose.light@1605";
    final static String URL = String.format("jdbc:sqlserver://%s:1433;database=%s;user=%s;password=%s;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;", HOSTNAME, DBNAME, USERNAME, PASSWORD);

    public static void main(String[] args) throws SQLException {
        System.out.println("Welcome to the PAN Database Application!");
        final Scanner sc = new Scanner(System.in);
        String option = "";

        // Main loop to display menu and execute queries
        while (!option.equals("18")) {
            displayMenu();
            option = sc.next();

            switch (option) {
                case "1": addNewTeam(sc); break;
                case "2": addNewClientWithTeams(sc); break;
                case "3": addNewVolunteerWithTeams(sc); break;
                case "4": enterVolunteerHours(sc); break;
                case "5": addNewEmployeeWithTeams(sc); break;
                case "6": enterEmployeeExpense(sc); break;
                case "7": addNewDonorWithDonations(sc); break;
                case "8": getClientDoctorInfo(sc); break;
                case "9": getTotalExpensesByEmployee(sc); break;
                case "10": getVolunteersForClient(sc); break;
                case "11": getTeamsFoundedAfterDate(sc); break;
                case "12": getAllPeopleWithEmergencyContacts(); break;
                case "13": getEmployeeDonorTotalDonations(); break;
                case "14": increaseSalaryForMultiTeamEmployees(); break;
                case "15": deleteClientsWithoutHealthInsuranceAndLowTransportImportance(); break;
                case "16": importData(); break;
                case "17": exportData(); break;
                case "18": System.out.println("Exiting program."); break;
                default: System.out.println("Invalid option. Please try again."); break;
            }
        }
        sc.close();
    }
    private static void displayMenu() {
        System.out.println("\nSelect an option: ");
        System.out.println("1) Add new team");
        System.out.println("2) Add new client and associate with teams");
        System.out.println("3) Add new volunteer and associate with teams");
        System.out.println("4) Enter volunteer hours");
        System.out.println("5) Add new employee and associate with teams");
        System.out.println("6) Enter employee expense");
        System.out.println("7) Add new donor with donations");
        System.out.println("8) Get client doctor information");
        System.out.println("9) Get total expenses by employee");
        System.out.println("10) Get volunteers for client");
        System.out.println("11) Get teams founded after a date");
        System.out.println("12) Get all people with emergency contacts");
        System.out.println("13) Get employee donors total donations");
        System.out.println("14) Increase salary for multi-team employees");
        System.out.println("15) Delete clients without health insurance and low transport importance");
        System.out.println("16) Import data from file");
        System.out.println("17) Export data to file");
        System.out.println("18) Quit");
    }

 // 1. Add a new team
    private static void addNewTeam(Scanner sc) throws SQLException {
        System.out.print("Enter team name: ");
        String teamName = sc.next();
        System.out.print("Enter team type: ");
        String teamType = sc.next();
        System.out.print("Enter team date (yyyy-mm-dd): ");
        String teamDate = sc.next();

        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call AddNewTeam(?, ?, ?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setString(1, teamName);
                stmt.setString(2, teamType);
                stmt.setDate(3, java.sql.Date.valueOf(teamDate));
                stmt.execute();
                System.out.println("New team added.");
            }
        }
    }

    // 2. Add a new client and associate with teams
    private static void addNewClientWithTeams(Scanner sc) throws SQLException {
        System.out.print("Enter client SSN: ");
        String ssn = sc.next();
        sc.nextLine();
        System.out.print("Enter client name: ");
        String name = sc.nextLine();
        System.out.print("Enter gender (M/F): ");
        String gender = sc.next();
        sc.nextLine();
        System.out.print("Enter profession: ");
        String profession = sc.nextLine();
        System.out.print("Enter mailing address: ");
        String address = sc.nextLine();
        System.out.print("Enter email: ");
        String email = sc.nextLine();
        System.out.print("Enter phone number: ");
        String phone = sc.nextLine();
        System.out.print("Is the client subscribed to the mailing list? (true/false): ");
        boolean mailingList = sc.nextBoolean();
        sc.nextLine();
        System.out.print("Enter doctor name: ");
        String doctorName = sc.nextLine();
        System.out.print("Enter doctor phone number: ");
        String doctorPhone = sc.nextLine();
        System.out.print("Enter date assigned (yyyy-mm-dd): ");
        String dateAssigned = sc.next();
        sc.nextLine();
        System.out.print("Enter team names (comma-separated): ");
        String teamNames = sc.nextLine();
        System.out.print("Is the client active? (true/false): ");
        boolean activeStatus = sc.nextBoolean();
        sc.nextLine();
        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call AddNewClientWithTeams(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setString(1, ssn);
                stmt.setString(2, name);
                stmt.setString(3, gender);
                stmt.setString(4, profession);
                stmt.setString(5, address);
                stmt.setString(6, email);
                stmt.setString(7, phone);
                stmt.setBoolean(8, mailingList);
                stmt.setString(9, doctorName);
                stmt.setString(10, doctorPhone);
                stmt.setDate(11, java.sql.Date.valueOf(dateAssigned));
                stmt.setString(12, teamNames);
                stmt.setBoolean(13, activeStatus);  // Set the active/inactive status
                
                stmt.execute();
                System.out.println("New client and team associations added.");
            }
        }
    }

    // 3. Add a new volunteer and associate with teams
    private static void addNewVolunteerWithTeams(Scanner sc) throws SQLException {
        System.out.print("Enter volunteer SSN: ");
        String ssn = sc.next();
        sc.nextLine();
        System.out.print("Enter volunteer name: ");
        String name = sc.next();
        sc.nextLine();
        System.out.print("Enter gender (M/F): ");
        String gender = sc.next();
        sc.nextLine();
        System.out.print("Enter profession: ");
        String profession = sc.next();
        sc.nextLine();
        System.out.print("Enter mailing address: ");
        String address = sc.next();
        sc.nextLine();
        System.out.print("Enter email: ");
        String email = sc.next();
        sc.nextLine();
        System.out.print("Enter phone number: ");
        String phone = sc.next();
        sc.nextLine();
        System.out.print("Is the volunteer subscribed to the mailing list? (true/false): ");
        boolean mailingList = sc.nextBoolean();
        System.out.print("Enter date joined (yyyy-mm-dd): ");
        sc.nextLine();
        String dateJoined = sc.next();
        System.out.print("Enter training date (yyyy-mm-dd): ");
        sc.nextLine();
        String trainingDate = sc.next();
        System.out.print("Enter training location: ");
        sc.nextLine();
        String trainingLocation = sc.next();
        sc.nextLine();
        System.out.print("Enter team names (comma-separated): ");
        String teamNames = sc.next();
        System.out.print("Is the volunteer active? (true/false): ");
        boolean activeStatus = sc.nextBoolean();
       
        try (Connection conn = DriverManager.getConnection(URL)) {
            
            String sql = "{call AddNewVolunteerWithTeams(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setString(1, ssn);
                stmt.setString(2, name);
                stmt.setString(3, gender);
                stmt.setString(4, profession);
                stmt.setString(5, address);
                stmt.setString(6, email);
                stmt.setString(7, phone);
                stmt.setBoolean(8, mailingList);
                stmt.setDate(9, java.sql.Date.valueOf(dateJoined));
                stmt.setDate(10, java.sql.Date.valueOf(trainingDate));
                stmt.setString(11, trainingLocation);
                stmt.setString(12, teamNames);
                stmt.setBoolean(13, activeStatus);  // Set the active/inactive status
                stmt.execute();
                System.out.println("New volunteer and team associations added.");
            }
        }
    }

    // 4. Enter volunteer hours
    private static void enterVolunteerHours(Scanner sc) throws SQLException {
        System.out.print("Enter team name: ");
        String teamName = sc.next();
        System.out.print("Enter volunteer SSN: ");
        String volunteerSSN = sc.next();
        System.out.print("Enter hours worked: ");
        int hours = sc.nextInt();
        System.out.print("Enter month (Jan, Feb, etc.): ");
        String month = sc.next();

        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call EnterVolunteerHours(?, ?, ?, ?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setString(1, teamName);
                stmt.setString(2, volunteerSSN);
                stmt.setInt(3, hours);
                stmt.setString(4, month);
                stmt.execute();
                System.out.println("Volunteer hours recorded.");
            }
        }
    }

    // 5. Add new employee and associate with teams
    private static void addNewEmployeeWithTeams(Scanner sc) throws SQLException {
    	System.out.print("Enter Employee SSN: ");
        String ssn = sc.next();
        sc.nextLine();
        System.out.print("Enter employee name: ");
        String name = sc.next();
        sc.nextLine();
        System.out.print("Enter gender (M/F): ");
        String gender = sc.next();
        sc.nextLine();
        System.out.print("Enter profession: ");
        String profession = sc.next();
        sc.nextLine();
        System.out.print("Enter mailing address: ");
        String address = sc.next();
        sc.nextLine();
        System.out.print("Enter email: ");
        String email = sc.next();
        sc.nextLine();
        System.out.print("Enter phone number: ");
        String phone = sc.next();
        sc.nextLine();
        System.out.print("Is the Employee subscribed to the mailing list? (true/false): ");
        boolean mailingList = sc.nextBoolean();
        sc.nextLine();
        System.out.print("Enter employee salary: ");
        double salary = sc.nextDouble();
        sc.nextLine();
        System.out.print("Enter marital status: ");
        String maritalStatus = sc.next();
        sc.nextLine();
        System.out.print("Enter hire date (yyyy-mm-dd): ");
        String hireDate = sc.next();
        sc.nextLine();
        System.out.print("Enter team names (comma-separated): ");
        String teamNames = sc.next();
        sc.nextLine();
        System.out.print("Enter report date (yyyy-mm-dd):");
        String report_date = sc.next();
        sc.nextLine();
        System.out.print("Enter description");
        String description = sc.next();

        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call AddNewEmployeeWithTeams(?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setString(1, ssn);
                stmt.setString(2, name);
                stmt.setString(3, gender);
                stmt.setString(4, profession);
                stmt.setString(5, address);
                stmt.setString(6, email);
                stmt.setString(7, phone);
                stmt.setBoolean(8, mailingList);
                stmt.setDouble(9, salary);
                stmt.setString(10, maritalStatus);
                stmt.setDate(11, java.sql.Date.valueOf(hireDate));
                stmt.setString(12, teamNames);
                stmt.setString(13, report_date);
                stmt.setString(14, description);
                stmt.execute();
                System.out.println("New employee and team associations added.");
            }
        }
    }

    // 6. Enter employee expense
    private static void enterEmployeeExpense(Scanner sc) throws SQLException {
    	System.out.print("Enter Employee SSN: ");
        String ssn = sc.next();
        System.out.print("Enter expense description: ");
        String description = sc.next();
        System.out.print("Enter expense date (yyyy-mm-dd): ");
        String expenseDate = sc.next();
        System.out.print("Enter expense amount: ");
        double amount = sc.nextDouble();

        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call EnterEmployeeExpense(?, ?, ?, ?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
            	 stmt.setString(1, ssn);
                stmt.setString(2, description);
                stmt.setDate(3, java.sql.Date.valueOf(expenseDate));
                stmt.setDouble(4, amount);
                stmt.execute();
                System.out.println("Employee expense recorded.");
            }
        }
    }

    // 7. Add new donor with donations
    private static void addNewDonorWithDonations(Scanner sc) throws SQLException {
        System.out.print("Enter Donor SSN: ");
        String ssn = sc.next();
        sc.nextLine();  // Clear buffer
        System.out.print("Enter donor name: ");
        String name = sc.nextLine();
        System.out.print("Enter gender (M/F): ");
        String gender = sc.next();
        sc.nextLine();  // Clear buffer after single-word input
        System.out.print("Enter profession: ");
        String profession = sc.nextLine();
        System.out.print("Enter mailing address: ");
        String address = sc.nextLine();
        System.out.print("Enter email: ");
        String email = sc.nextLine();
        System.out.print("Enter phone number: ");
        String phone = sc.nextLine();
        System.out.print("Is the donor subscribed to the mailing list? (true/false): ");
        boolean mailingList = sc.nextBoolean();
        System.out.print("Is the donor anonymous (1 for yes, 0 for no): ");
        int anonymous = sc.nextInt();
        sc.nextLine(); // Clear buffer after integer input
        
        StringBuilder donationDetails = new StringBuilder();
        boolean addMore = true;

        while (addMore) {
            System.out.print("Enter donation type (cheque/credit): ");
            String donationType = sc.nextLine().trim();

            double donationAmount = 0;
            boolean validAmount = false;
            
            while (!validAmount) {
                System.out.print("Enter donation amount: ");
                String amountInput = sc.nextLine().trim(); // Read the entire line
                try {
                    donationAmount = Double.parseDouble(amountInput); // Try parsing the amount as double
                    validAmount = true; // Set flag if parsing succeeds
                } catch (NumberFormatException e) {
                    System.out.println("Invalid amount. Please enter a valid numeric value.");
                }
            }

            System.out.print("Enter donation date (yyyy-mm-dd): ");
            String donationDate = sc.nextLine();
            System.out.print("Enter campaign name: ");
            String campaignName = sc.nextLine();

            if ("cheque".equalsIgnoreCase(donationType)) {
                System.out.print("Enter cheque number: ");
                int chequeNumber = sc.nextInt();
                sc.nextLine(); // Clear buffer
                donationDetails.append(donationDate).append(",").append(donationAmount).append(",")
                               .append("cheque,").append(campaignName).append(",").append(chequeNumber).append(";");
            } else if ("credit".equalsIgnoreCase(donationType)) {
                System.out.print("Enter card number: ");
                String cardNumber = sc.next();
                System.out.print("Enter card type: ");
                String cardType = sc.next();
                System.out.print("Enter expiry date (yyyy-mm-dd): ");
                String expiryDate = sc.next();
                sc.nextLine(); // Clear buffer after credit card details
                donationDetails.append(donationDate).append(",").append(donationAmount).append(",")
                               .append("credit,").append(campaignName).append(",").append(cardNumber)
                               .append(",").append(cardType).append(",").append(expiryDate).append(";");
            } else {
                System.out.println("Invalid donation type entered: " + donationType + ". Only 'Cheque'"
                		+ " and 'Credit Card' are allowed.");
                continue;
            }

            System.out.print("Do you want to add another donation? (yes/no): ");
            addMore = sc.nextLine().trim().equalsIgnoreCase("yes");
        }

        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call AddNewDonorWithDonations(?, ?, ?, ?, ?, ?, ?, ?, ?,?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setString(1, ssn);
                stmt.setString(2, name);
                stmt.setString(3, gender);
                stmt.setString(4, profession);
                stmt.setString(5, address);
                stmt.setString(6, email);
                stmt.setString(7, phone);
                stmt.setBoolean(8, mailingList);
                stmt.setInt(9, anonymous);
                stmt.setString(10, donationDetails.toString());
                stmt.execute();
                System.out.println("New donor with donations recorded.");
            }
        }
    }

 // 8. Get client doctor information
    private static void getClientDoctorInfo(Scanner sc) throws SQLException {
    	System.out.print("Enter Client SSN: ");
        String clientSSN = sc.next();
        
        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call GetClientDoctorInfo(?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setString(1, clientSSN);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("Doctor Name: " + rs.getString("doctor_name"));
                        System.out.println("Doctor Phone: " + rs.getString("doctor_phone_no"));
                    } else {
                        System.out.println("No doctor information found for the provided client SSN.");
                    }
                }
            }
        }
    }

    // 9. Get total expenses by employee within a specific period
    private static void getTotalExpensesByEmployee(Scanner sc) throws SQLException {
        System.out.print("Enter start date (yyyy-mm-dd): ");
        String startDate = sc.next();
        System.out.print("Enter end date (yyyy-mm-dd): ");
        String endDate = sc.next();

        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call GetTotalExpensesByEmployee(?, ?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setDate(1, java.sql.Date.valueOf(startDate));
                stmt.setDate(2, java.sql.Date.valueOf(endDate));
                try (ResultSet rs = stmt.executeQuery()) {
                    System.out.println("Employee SSN | Total Expenses");
                    while (rs.next()) {
                        System.out.printf("%s | %.2f%n", rs.getString("Employee_SSN"), rs.getDouble("total_expenses"));
                    }
                }
            }
        }
    }


    // 10. Get volunteers for a specific client
    private static void getVolunteersForClient(Scanner sc) throws SQLException {
        System.out.print("Enter Client SSN: ");
        String clientSSN = sc.next();

        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call GetVolunteersForClient(?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setString(1, clientSSN);
                try (ResultSet rs = stmt.executeQuery()) {
                    System.out.println("Volunteer SSN | Training Location");
                    while (rs.next()) {
                        System.out.printf("%s | %s%n", rs.getString("SSN"), rs.getString("training_location"));
                    }
                }
            }
        }
    }

    // 11. Get teams founded after a specific date
    private static void getTeamsFoundedAfterDate(Scanner sc) throws SQLException {
        System.out.print("Enter date (yyyy-mm-dd): ");
        String date = sc.next();

        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call GetTeamsFoundedAfterDate(?)}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setDate(1, java.sql.Date.valueOf(date));
                try (ResultSet rs = stmt.executeQuery()) {
                    System.out.println("Teams founded after " + date + ":");
                    while (rs.next()) {
                        System.out.println("Team Name: " + rs.getString("team_name"));
                    }
                }
            }
        }
    }

    // 12. Get all people with their emergency contacts
    private static void getAllPeopleWithEmergencyContacts() throws SQLException {
        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call GetAllPeopleWithEmergencyContacts}";
            try (CallableStatement stmt = conn.prepareCall(sql); ResultSet rs = stmt.executeQuery()) {
                System.out.println("SSN | Name | Main Phone | Email | Emergency Phone | Emergency Contact Name | Relation");
                while (rs.next()) {
                    System.out.printf("%s | %s | %s | %s | %s | %s | %s%n",
                            rs.getString("SSN"),
                            rs.getString("name"),
                            rs.getString("main_phone"),
                            rs.getString("email_address"),
                            rs.getString("emergency_phone"),
                            rs.getString("emergency_contact_name"),
                            rs.getString("emergency_relation"));
                }
            }
        }
    }

    // 13. Get total donations from employee donors
    private static void getEmployeeDonorTotalDonations() throws SQLException {
        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call GetEmployeeDonorTotalDonations}";
            try (CallableStatement stmt = conn.prepareCall(sql);
                 ResultSet rs = stmt.executeQuery()) {
                System.out.println("Name | SSN | Total Donations | Anonymous Donor");
                while (rs.next()) {
                    System.out.printf("%s | %s | %.2f | %s%n",
                            rs.getString("name"), rs.getString("SSN"), rs.getDouble("total_donations"),
                            rs.getBoolean("anonymous_donor") ? "Yes" : "No");
                }
            }
        }
    }


    // 14. Increase salary for employees associated with multiple teams
    private static void increaseSalaryForMultiTeamEmployees() throws SQLException {
        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call IncreaseSalaryForMultiTeamEmployees}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.execute();
                System.out.println("Salary increased by 10% for eligible employees.");
            }
        }
    }

    // 15. Delete clients without health insurance and low transport importance
    private static void deleteClientsWithoutHealthInsuranceAndLowTransportImportance() throws SQLException {
        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "{call DeleteClientsWithoutHealthInsuranceAndLowTransportImportance}";
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.execute();
                System.out.println("Clients without health insurance and low transportation importance deleted.");
            }
        }
    }
 //16 import
    private static void importData() throws SQLException {
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter the input file name: ");
        String fileName = sc.nextLine();

        try (BufferedReader br = new BufferedReader(new FileReader(fileName))) {
            String line;
            Connection conn = DriverManager.getConnection(URL);

            while ((line = br.readLine()) != null) {
                String[] teamData = line.split(",");
                if (teamData.length == 3) {
                    String teamName = teamData[0].trim();
                    String teamType = teamData[1].trim();
                    Date teamDate = Date.valueOf(teamData[2].trim());

                    // Insert each team into the Teams table
                    String sql = "{call AddNewTeam(?, ?, ?)}";
                    try (CallableStatement stmt = conn.prepareCall(sql)) {
                        stmt.setString(1, teamName);
                        stmt.setString(2, teamType);
                        stmt.setDate(3, teamDate);
                        stmt.execute();
                        System.out.println("Team added: " + teamName);
                    } catch (SQLException e) {
                        System.err.println("Failed to add team: " + teamName + ". Error: " + e.getMessage());
                    }
                } else {
                    System.err.println("Invalid line format: " + line);
                }
            }
            conn.close();
            System.out.println("Import completed.");

        } catch (IOException e) {
            System.err.println("Error reading file: " + e.getMessage());
        }
    }


    //17 Sample implementation for exporting data to CSV (for `exportData`)
    private static void exportData() throws SQLException {
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter the output file name: ");
        String fileName = sc.nextLine();

        try (Connection conn = DriverManager.getConnection(URL)) {
            String sql = "SELECT name, mailing_address FROM PAN WHERE mailing_list = 1";
            try (PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {

                try (BufferedWriter writer = new BufferedWriter(new FileWriter(fileName))) {
                    writer.write("Name, Mailing Address\n"); // Header for CSV
                    while (rs.next()) {
                        String name = rs.getString("name");
                        String mailingAddress = rs.getString("mailing_address");
                        writer.write(name + ", " + mailingAddress + "\n");
                    }
                    System.out.println("Mailing list exported to " + fileName);
                } catch (IOException e) {
                    System.err.println("Error writing to file: " + e.getMessage());
                }
            }
        }
    }
}


