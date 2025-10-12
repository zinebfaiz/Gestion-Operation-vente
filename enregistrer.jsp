<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*,java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // ==== Données de session ====
    String idClient = (String) session.getAttribute("id_client");
    String totalCommande = (String) session.getAttribute("total_commande");
    String[] articles = (String[]) session.getAttribute("articles");
    String[] quantites = (String[]) session.getAttribute("quantites");
    String[] prixs = (String[]) session.getAttribute("prixs");

    // ==== Données du formulaire ====
    String modePaiement = request.getParameter("mode_paiement");
    String totalReglement = request.getParameter("total_reglement");

    /* 
    ======== DEBUG (désactivé) ========
    Décommenter ce bloc si tu veux afficher les valeurs reçues
    ----------------------------------
    out.println("<h2>✅ Debug des paramètres reçus</h2>");
    out.println("<strong>id_client:</strong> " + idClient + "<br>");
    out.println("<strong>total_commande:</strong> " + totalCommande + "<br>");
    out.println("<strong>mode_paiement:</strong> " + modePaiement + "<br>");
    out.println("<strong>total_reglement:</strong> " + totalReglement + "<br>");
    out.println("<hr>");
    */

    Connection conn = null;
    PreparedStatement psCommande = null;
    PreparedStatement psFormer = null;
    PreparedStatement psReglement = null;
    ResultSet rs = null;

    try {
        // Connexion à Oracle
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "zineb", "zineb123");
        conn.setAutoCommit(false); // Démarre une transaction

        // 1️⃣ Insertion dans COMMANDE
        String sqlCommande = "INSERT INTO Commande (id_client, total_commande) VALUES (?, ?)";
        psCommande = conn.prepareStatement(sqlCommande, new String[] {"id_commande"});
        psCommande.setInt(1, Integer.parseInt(idClient));
        psCommande.setDouble(2, Double.parseDouble(totalCommande));
        psCommande.executeUpdate();

        rs = psCommande.getGeneratedKeys();
        int idCommande = 0;
        if (rs.next()) {
            idCommande = rs.getInt(1);
        } else {
            throw new Exception("ID de commande non généré.");
        }

        // 2️⃣ Insertion dans FORMER
        String sqlFormer = "INSERT INTO Former (id_commande, id_article, quantite, prix_unit) VALUES (?, ?, ?, ?)";
        psFormer = conn.prepareStatement(sqlFormer);
        for (int i = 0; i < articles.length; i++) {
            psFormer.setInt(1, idCommande);
            psFormer.setInt(2, Integer.parseInt(articles[i]));
            psFormer.setInt(3, Integer.parseInt(quantites[i]));
            psFormer.setDouble(4, Double.parseDouble(prixs[i]));
            psFormer.executeUpdate();
        }

        // 3️⃣ Insertion dans REGLEMENT
        String sqlReglement = "INSERT INTO Reglement (id_commande, mode_reglement, montant) VALUES (?, ?, ?)";
        psReglement = conn.prepareStatement(sqlReglement);
        psReglement.setInt(1, idCommande);
        psReglement.setString(2, modePaiement);
        psReglement.setDouble(3, Double.parseDouble(totalReglement));
        psReglement.executeUpdate();

        // ✅ Validation
        conn.commit();
%>
        <h3 style="color:green;">✅ Commande enregistrée avec succès !<br>ID commande : <%= idCommande %></h3>
<%
    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (Exception ignore) {}
        }
%>
        <h3 style="color:red;">❌ Erreur : <%= e.getMessage() %></h3>
<%
    } finally {
        try {
            if (rs != null) rs.close();
            if (psCommande != null) psCommande.close();
            if (psFormer != null) psFormer.close();
            if (psReglement != null) psReglement.close();
            if (conn != null) conn.close();
        } catch (Exception ignore) {}
    }
%>
