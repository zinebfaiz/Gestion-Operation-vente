<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");

    // ✅ Données de session
    String idClient = (String) session.getAttribute("id_client");
    String totalCommande = (String) session.getAttribute("total_commande");
    String[] articles = (String[]) session.getAttribute("articles");
    String[] quantites = (String[]) session.getAttribute("quantites");
    String[] prixs = (String[]) session.getAttribute("prixs");

    // ✅ Données du formulaire
    String modePaiement = request.getParameter("mode_paiement");
    String totalReglement = request.getParameter("total_reglement");

    out.println("<h2>✅ Debug des paramètres reçus</h2>");

    // Champs simples
    out.println("<strong>id_client:</strong> " + (idClient != null ? idClient : "<span style='color:red;'>null</span>") + "<br>");
    out.println("<strong>total_commande:</strong> " + (totalCommande != null ? totalCommande : "<span style='color:red;'>null</span>") + "<br>");
    out.println("<strong>mode_paiement:</strong> " + (modePaiement != null ? modePaiement : "<span style='color:red;'>null</span>") + "<br>");
    out.println("<strong>total_reglement:</strong> " + (totalReglement != null ? totalReglement : "<span style='color:red;'>null</span>") + "<br>");

    // Tableaux
    out.println("<hr>");
    if (articles == null) {
        out.println("<strong style='color:red;'>articles = null</strong><br>");
    } else {
        out.println("<strong>Articles reçus (" + articles.length + ") :</strong><br>");
        for (int i = 0; i < articles.length; i++) {
            out.println("Article[" + i + "] = " + articles[i] + "<br>");
        }
    }

    if (quantites == null) {
        out.println("<strong style='color:red;'>quantites = null</strong><br>");
    } else {
        out.println("<strong>Quantités reçues (" + quantites.length + ") :</strong><br>");
        for (int i = 0; i < quantites.length; i++) {
            out.println("Quantité[" + i + "] = " + quantites[i] + "<br>");
        }
    }

    if (prixs == null) {
        out.println("<strong style='color:red;'>prixs = null</strong><br>");
    } else {
        out.println("<strong>Prix unitaires reçus (" + prixs.length + ") :</strong><br>");
        for (int i = 0; i < prixs.length; i++) {
            out.println("Prix[" + i + "] = " + prixs[i] + "<br>");
        }
    }

    out.println("<hr>");
%>
<%@ page import="java.sql.*" %>
<%
Connection conn = null;
PreparedStatement psCommande = null;
PreparedStatement psFormer = null;
PreparedStatement psReglement = null;
ResultSet rs = null;

try {
    // Charger le driver Oracle
    Class.forName("oracle.jdbc.driver.OracleDriver");

    // Connexion
    conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "zineb", "zineb123");
    conn.setAutoCommit(false); // Démarre une transaction

    // ✅ 1. Insertion dans COMMANDE
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
        throw new Exception("❌ ID de commande non généré.");
    }

    // ✅ 2. Insertion dans FORMER
    String sqlFormer = "INSERT INTO Former (id_commande, id_article, quantite, prix_unit) VALUES (?, ?, ?, ?)";
    psFormer = conn.prepareStatement(sqlFormer);
    for (int i = 0; i < articles.length; i++) {
        int idArticle = Integer.parseInt(articles[i]);
        int qte = Integer.parseInt(quantites[i]);
        double prix = Double.parseDouble(prixs[i]);

        psFormer.setInt(1, idCommande);
        psFormer.setInt(2, idArticle);
        psFormer.setInt(3, qte);
        psFormer.setDouble(4, prix);
        psFormer.executeUpdate();
    }

    // ✅ 3. Insertion dans REGLEMENT
    String sqlReglement = "INSERT INTO Reglement (id_commande, mode_reglement, montant) VALUES (?, ?, ?)";
    psReglement = conn.prepareStatement(sqlReglement);
    psReglement.setInt(1, idCommande);
    psReglement.setString(2, modePaiement);
    psReglement.setDouble(3, Double.parseDouble(totalReglement));
    psReglement.executeUpdate();

    // ✅ Si tout va bien
    conn.commit();
    out.println("<h3 style='color:green;'>✅ Commande enregistrée avec succès ! ID commande : " + idCommande + "</h3>");
} catch (Exception e) {
    if (conn != null) {
        try { conn.rollback(); } catch (Exception ex) {}
    }
    out.println("<h3 style='color:red;'>❌ Erreur : " + e.getMessage() + "</h3>");
    e.printStackTrace(new java.io.PrintWriter(out));
} finally {
    try {
        if (rs != null) rs.close();
        if (psCommande != null) psCommande.close();
        if (psFormer != null) psFormer.close();
        if (psReglement != null) psReglement.close();
        if (conn != null) conn.close();
    } catch (Exception ex) {}
}
%>
