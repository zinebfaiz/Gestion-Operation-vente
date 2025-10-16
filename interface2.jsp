<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" session="true" import="java.util.*,java.sql.*" %>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Règlement de la commande</title>
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
        // --- Récupération des données ---
        String idClient = request.getParameter("id_client");
        String total = request.getParameter("total_commande");
        String[] articles = request.getParameterValues("articles");
        String[] quantites = request.getParameterValues("quantites");
        String[] prixs = request.getParameterValues("prixs");

        // --- Vérification des données ---
        if (idClient == null || total == null || articles == null || quantites == null || prixs == null) {
    %>
        <p style="color:red;">❌ Données manquantes. Veuillez repasser par l'étape de création de commande.</p>
    <%
        } else {
            // --- Stockage dans la session ---
            session.setAttribute("id_client", idClient);
            session.setAttribute("total_commande", total);
            session.setAttribute("articles", articles);
            session.setAttribute("quantites", quantites);
            session.setAttribute("prixs", prixs);
    %>

    <form action="enregistrer.jsp" method="post">
        <div>
            <label for="total_commande">Total de la commande :</label><br>
            <input type="number" id="total_commande" name="total_commande"
                   value="<%= total %>" readonly>
        </div><br>

        <div>
            <label for="mode_paiement">Mode de paiement :</label><br>
            <select id="mode_paiement" name="mode_paiement" required>
                <option value="">-- Sélectionner --</option>
                <option value="Espèce">Espèce</option>
                <option value="Virement">Virement</option>
                <option value="Versement">Versement</option>
            </select>
        </div><br>

        <div>
            <label for="total_reglement">Montant réglé :</label><br>
            <input type="number" id="total_reglement" name="total_reglement"
                   step="0.01" oninput="calculerReste()" required>
        </div><br>

        <div>
            <label for="reste">Reste à payer :</label><br>
            <input type="number" id="reste" name="reste" readonly>
        </div><br>

        <button type="submit">✅ Valider et enregistrer</button>
    </form>

    <%
        } 
    %>
</body>
</html>
