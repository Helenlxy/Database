import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try{
            connection = DriverManager.getConnection(url, username, password);
        } catch(SQLException se){
            System.err.println("SQL Exception." +
                    "<Message>: " + se.getMessage());
            return false;
        }
        return true;
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        if(connection != null) {
            try {
                connection.close();
            } catch (SQLException se) {
                System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
                return false;
            }
        }
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        List<Integer> elections = new ArrayList<>();
        List<Integer> cabinets = new ArrayList<>();

        try {
            String queryString = "select election.id as election_id, cabinet.id as cabinet_id " +
                "    from election join country on election.country_id = country.id join cabinet on election.id = cabinet.election_id " +
                "    where country.name = ? " +
                "    order by election.e_date desc;";
            
            PreparedStatement ps = connection.prepareStatement(queryString);
            ps.setString(1, countryName);
            
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                elections.add(rs.getInt("election_id"));
                cabinets.add(rs.getInt("cabinet_id"));
            }
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
        }

        return new ElectionCabinetResult(elections, cabinets);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        List<Integer> ids = new ArrayList<>();

        try{
            String description = new String("");
            String comment = new String("");
            String queryString = "SELECT description, comment FROM politician_president WHERE politician_president.id = ?";
            PreparedStatement ps = connection.prepareStatement(queryString);
            ps.setInt(1, politicianName);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                description = rs.getString("description");
                comment = rs.getString("comment");
            }

            String queryString1 = "SELECT id, description, comment FROM politician_president";
            PreparedStatement ps1 = connection.prepareStatement(queryString1);
            ResultSet rs1 = ps1.executeQuery();
            while (rs1.next()) {
                if(similarity(rs1.getString("description"), description) >= threshold || similarity(rs1.getString("comment"), comment) >= threshold) {
                    int id = rs1.getInt("id");
                    if(id != politicianName){
                        ids.add(id);
                    }
                }
            }
        }catch (SQLException se)
        {
            System.err.println("SQL Exception." +
                    "<Message>: " + se.getMessage());
        }

        return ids;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
        try{
            Assignment2 test = new Assignment2();
            test.connectDB("jdbc:postgresql://localhost:5432/csc343h-lihaoda?currentSchema=parlgov","lihaoda", "");
            ElectionCabinetResult result = test.electionSequence("Japan");
            System.out.println(result);
        } catch (ClassNotFoundException e) {
            System.err.println(e);
        }

    }

}
