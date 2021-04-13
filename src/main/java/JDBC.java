import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Vector;

public class JDBC {

	private String url, user, password;
	private Connection connexion;
	private static JDBC instance;

	private JDBC() {
	}
	
	public static JDBC getInstance() {
		if (instance == null)
			instance = new JDBC();
		return instance;
	}

	public void init(String url, String user, String password) {
		this.url = url;
		this.user = user;
		this.password = password;
		connexion = null;
	}
	
	public Connection getConnection() {
		try {
			this.connexion = DriverManager.getConnection(url, user, password);
		
		 System.out.println("la connexion avec le SGBD est bien établie....");
		
		return connexion;
		
		} catch (SQLException e) {	
			System.out.println("ERROR...");
			e.printStackTrace();
		}

		return null; 
	}

	public int getActorNbr() {
		
		try {
			Statement s = this.connexion.createStatement();
			
			ResultSet result = s.executeQuery("select count(actor_id) from actor");
			
			if(result.next()) return result.getInt(1);

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return -1;
		
	}

	public Vector<Vector> getActors(){
		
		Vector<Vector> vect = new Vector<Vector>(); 

		try {
			Statement stm = this.connexion.createStatement();

			ResultSet result = stm.executeQuery("select * from actor");
			
			ResultSetMetaData MM = result.getMetaData(); 
			
			Vector tmp = new Vector(); 
			
			for(int i=1; i<=MM.getColumnCount();i++) tmp.add(MM.getColumnName(i));
			
			vect.add((Vector) tmp.clone());
			
			while(result.next()) {				
				tmp.clear();
				for(int i=1; i<=MM.getColumnCount();i++) tmp.add(result.getString(i));
				vect.add((Vector) tmp.clone());				
			}

			return vect;
			
		} catch (SQLException e) {
			e.printStackTrace();
		} 

		return null;

	}

	public Vector<String> getFullName(int actor_id) {
		
		Vector<String> r = new Vector<String>();
		
		try {
			PreparedStatement p = this.connexion.prepareStatement("select first_name || ' '|| last_name full_name from actor where actor_id=?");
			p.setInt(1,actor_id);
			ResultSet result = p.executeQuery();	
			ResultSetMetaData mm = result.getMetaData(); 			
			if(result.next()) {
				r.add(mm.getColumnName(1));
				r.add(result.getString(1));
			}
			
			return r;				
		} catch (SQLException e) {
			e.printStackTrace();
		} 
		
		return null;
		
	}
	
	public Connection getConnexion() {
		return connexion;
	}

	public void setConnexion(Connection connexion) {
		this.connexion = connexion;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getUser() {
		return user;
	}

	public void setUser(String user) {
		this.user = user;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	} 

}
