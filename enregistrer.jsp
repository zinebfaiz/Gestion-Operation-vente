<%@ page import="java.sql.*, java.util.*"  language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
request.setCharacterEncoding("UTF-8");

Connection conn = null;
PreparedStatement psCommande = null;
PreparedStatement psFormer = null;
PreparedStatement psReglement = null;
ResultSet rs = null;

try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "zineb", "zineb123");
    conn.setAutoCommit(false);

    // 🔹 Récupérer les données
    int idClient = Integer.parseInt(request.getParameter("id_client"));
    double totalCommande = Double.parseDouble(request.getParameter("total_commande"));
    String mode = request.getParameter("mode_paiement");
    double montantRegle = Double.parseDouble(request.getParameter("total_reglement"));

    String[] articles = request.getParameterValues("articles");
    String[] quantites = request.getParameterValues("quantites");
    String[] prixs = request.getParameterValues("prixs");

    if (articles == null || quantites == null || prixs == null) {
        throw new Exception("Articles ou quantités manquants");
    }

    // 🔹 1. Insertion COMMANDE
    String sqlCommande = "INSERT INTO Commande (id_client, total_commande) VALUES (?, ?)";
    psCommande = conn.prepareStatement(sqlCommande, new String[] {"id_commande"});
    psCommande.setInt(1, idClient);
    psCommande.setDouble(2, totalCommande);
    psCommande.executeUpdate();

    rs = psCommande.getGeneratedKeys();
    int idCommande = 0;
    if (rs.next()) {
        idCommande = rs.getInt(1);
    } else {
        throw new Exception("Échec de la récupération de l’ID de commande.");
    }

    // 🔹 2. Insertion FORMER
    String sqlFormer = "INSERT INTO Former (id_commande, id_article, quantite, prix_unit) VALUES (?, ?, ?, ?)";
    psFormer = conn.prepareStatement(sqlFormer);

    for (int i = 0; i < articles.length; i++) {
        psFormer.setInt(1, idCommande);
        psFormer.setInt(2, Integer.parseInt(articles[i]));
        psFormer.setInt(3, Integer.parseInt(quantites[i]));
        psFormer.setDouble(4, Double.parseDouble(prixs[i]));
        psFormer.executeUpdate();
    }

    // 🔹 3. Insertion REGLEMENT
    String sqlReglement = "INSERT INTO Reglement (id_commande, mode_reglement, montant) VALUES (?, ?, ?)";
    psReglement = conn.prepareStatement(sqlReglement);
    psReglement.setInt(1, idCommande);
    psReglement.setString(2, mode);
    psReglement.setDouble(3, montantRegle);
    psReglement.executeUpdate();

    // ✅ Tout s'est bien passé
    conn.commit();
%>
    <h2 style="color:green;">✅ Commande enregistrée avec succès !</h2>
    <p>ID Commande : <%= idCommande %></p>
<%
} catch (Exception e) {
    if (conn != null) conn.rollback();
%>
    <h2 style="color:red;">❌ Erreur : <%= e.getMessage() %></h2>
<%
} finally {
    if (rs != null) rs.close();
    if (psCommande != null) psCommande.close();
    if (psFormer != null) psFormer.close();
    if (psReglement != null) psReglement.close();
    if (conn != null) conn.close();
}
%>
