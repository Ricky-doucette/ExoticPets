<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %> 
<%@ include file="jdbc.jsp"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%> 
<!DOCTYPE html>
<html>
<head>
<title>YOUR NAME Grocery</title>
</head>
<body
            
style = "background-color: lightblue;"
></body>

<h1>Search for the products you want to buy:</h1>

<form method="get" action="listprod.jsp"> 
<select size=1 name ="categoryName"> 
	<option value="All">All</option>
	<option value="Fish">Fish</option> 
	<option value="Mammals">Mammals</option> 
	<option value="Birds">Birds</option> 
	<option value="Reptiles">Reptiles</option> 
	<option value="Amphibians">Amphibians</option> 
	<option value="Dragons">Dragons</option> 
	<option value="Fairies">Fairies</option> 
	<option value="Dinosaurs">Dinosaurs</option>
</select>
<input type="text" name="productName" size="50">
<input type="submit" value="Submit"><input type="reset" value="Reset"> (Leave blank for all products)
</form> 

<% // Get product name and categoryName to search for
String name = request.getParameter("productName"); 
String catName = request.getParameter("categoryName"); 
// Set header 
String prodHeader;  
if ((name == null | name == "") && catName == null)
	prodHeader = "All Products";
else if((name == null | name == "") && catName != null)
	prodHeader = "All Products in category: \"" + catName + "\""; 
else if(catName == null) 
	prodHeader = "All Products containing: \"" + name + "\"";
else 
	prodHeader = "All Products containing: \"" + name + "\" in category: \"" + catName + "\"";   

out.print("<h2>" + prodHeader + "</h2>");
		
//Note: Forces loading of SQL Server driver
try
{	// Load driver class
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}
catch (java.lang.ClassNotFoundException e)
{
	out.println("ClassNotFoundException: " +e);
}

if (catName == null | catName == "All") 
	catName = "%";

// Variable name now contains the search string the user entered
// Use it to build a query and print out the resultset.  Make sure to use PreparedStatement!  

NumberFormat currFormat = NumberFormat.getCurrencyInstance(); 
String query = "SELECT productId, productName, categoryName, productPrice FROM product p, category c WHERE p.categoryId = c.categoryId AND productName LIKE ? AND categoryName LIKE ?"; 

// Make the connection
	try {
		getConnection(); 
		Statement stmt = con.createStatement(); 
		stmt.execute("USE orders"); 
		PreparedStatement pstmt = con.prepareStatement(query);  

		if ((name == null | name == ""))   
			pstmt.setString(1, "%"); 
		else 
			pstmt.setString(1, "%" + name + "%");  

		pstmt.setString(2, catName); 
		ResultSet rst = pstmt.executeQuery();  
		out.println("<table border=\"1\"><tr><th></th><th>Product Name</th><th>Category</th><th>Price</th></tr>");
		while(rst.next()) {   
			// Print out the ResultSet
			int id = rst.getInt(1);
			String pname = rst.getString(2);  
			String cname = rst.getString(3); 
			double pprice = rst.getDouble(4);  
			// For each product create a link of the form: addcart.jsp?id=productId&name=productName&price=productPrice
			out.print("<tr><td><a href = \"addcart.jsp?id=" + id + "&name=" + pname + "&price=" + pprice + "\">Add to Cart</a></td>");
			out.print("<td><a href = \"product.jsp?id=" + id + "&name=" + pname + "&price=" + pprice + "\">" + pname + "</a></td>");  
			out.print("<td>" + cname + "</td>");  
			out.print("<td>" + currFormat.format(pprice) + "</td></tr>"); 
		} 
		out.print("</table>"); 

	} catch (SQLException e) {
		out.println("SQLException: " + e);  
	} finally { // Close connection
		closeConnection(); 
	}

// Useful code for formatting currency values:
// NumberFormat currFormat = NumberFormat.getCurrencyInstance();
// out.println(currFormat.format(5.0);	// Prints $5.00
%>

</body>
</html>