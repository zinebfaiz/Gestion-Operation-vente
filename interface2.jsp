<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.util.*,java.sql.*" %>




<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Règlement</title>
    <script>
        function calculerReste() {
            const totalCmd = parseFloat(document.getElementById("total_commande").value) || 0;
            const totalReglement = parseFloat(document.getElementById("total_reglement").value) || 0;
            const reste = totalCmd - totalReglement;
            document.getElementById("reste").value = reste.toFixed(2);
        }
    </script>
</head>
<body>

<h2>Règlement de la commande</h2>

<%
    String idClient = request.getParameter("id_client");
    String total = request.getParameter("total_commande");
    String[] articles = request.getParameterValues("articles");
    String[] quantites = request.getParameterValues("quantites");
    String[] prixs = request.getParameterValues("prixs");

    if (idClient == null || total == null || articles == null || quantites == null || prixs == null) {
%>
    <p style="color:red;">❌ Données manquantes. Veuillez repasser par l'étape de création de commande.</p>
<%
    } else {
        session.setAttribute("id_client", idClient);
        session.setAttribute("total_commande", total);
        session.setAttribute("articles", articles);
        session.setAttribute("quantites", quantites);
        session.setAttribute("prixs", prixs);
%>

    <!-- ✅ Affichage des infos client + articles -->
    <p>Client : <%= idClient %></p>
    <p>Total : <%= total %></p>

<%
        for (int i = 0; i < articles.length; i++) {
%>
    <p>Article <%= i+1 %>: <%= articles[i] %>, Qte: <%= quantites[i] %>, Prix: <%= prixs[i] %></p>
<%
        }
%>

    <!-- ✅ Formulaire de règlement -->
    <form action="enregistrer.jsp" method="post">
        <label for="total_commande">Total de la commande :</label>
        <input type="number" id="total_commande" name="total_commande" value="<%= total %>" readonly><br><br>

        <label for="mode_paiement">Mode de paiement :</label>
        <select id="mode_paiement" name="mode_paiement" required>
            <option value="">-- Sélectionner --</option>
            <option value="Espèce">Espèce</option>
            <option value="Virement">Virement</option>
            <option value="Versement">Versement</option>
        </select><br><br>

        <label for="total_reglement">Montant réglé :</label>
        <input type="number" id="total_reglement" name="total_reglement" oninput="calculerReste()" required><br><br>

        <label for="reste">Reste :</label>
        <input type="number" id="reste" name="reste" readonly><br><br>

        <button type="submit">Valider et enregistrer</button>
    </form>

<%
    } // fin du else
%>

<%
    System.out.println("articles: " + Arrays.toString(articles));
    System.out.println("quantites: " + Arrays.toString(quantites));
    System.out.println("prixs: " + Arrays.toString(prixs));
%>


</body>
</html>
