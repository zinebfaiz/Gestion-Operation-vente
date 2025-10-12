<%@ page session="true" language="java" contentType="text/html; charset=UTF-8" import="java.sql.Connection, java.sql.DriverManager, java.sql.Statement, java.sql.ResultSet"
    pageEncoding="UTF-8" import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Création de Commande</title>

    <script>
        

        // Quand on choisit une catégorie
        function updateArticles() {
    const catSelect = document.getElementById("categorie");
    const articleSelect = document.getElementById("article");
    const idCat = catSelect.value;

    articleSelect.innerHTML = '<option value="">--Sélectionner un article--</option>';

    // Vérifier si la catégorie existe dans l’objet
    if (idCat && articlesData.hasOwnProperty(idCat)) {
        articlesData[idCat].forEach(article => {
            const opt = document.createElement("option");
            opt.value = article.id;
            opt.textContent = article.nom;
            articleSelect.appendChild(opt);
        });
    } else {
        console.log("Aucun article pour cette catégorie");
    }
}

        function ajouterChampCache(name, value) {
            const input = document.createElement("input");
            input.type = "hidden";
            input.name = name;
            input.value = value;
            document.getElementById("hiddenFields").appendChild(input);
        }

        function ajouterLigne() {
            const cat = document.getElementById("categorie");
            const art = document.getElementById("article");
            const qte = document.getElementById("qte");
            const prix = document.getElementById("prix");

            const quantite = parseInt(qte.value);
            const prixUnit = parseFloat(prix.value);

            if (!cat.value || !art.value || isNaN(quantite) || isNaN(prixUnit) || quantite <= 0 || prixUnit <= 0) {
                alert("Veuillez remplir tous les champs correctement.");
                return;
            }

            const table = document.getElementById("commandeTable");
            const categorieText = cat.options[cat.selectedIndex].text;
            const articleText = art.options[art.selectedIndex].text;
            const totalLigne = (quantite * prixUnit).toFixed(2);

            const newRow = table.insertRow(-1);
            newRow.insertCell(0).innerHTML = '<button type="button" onclick="supprimerLigne(this)">❌</button>';
            newRow.insertCell(1).textContent = categorieText;
            newRow.insertCell(2).textContent = articleText;
            newRow.insertCell(3).textContent = quantite;
            newRow.insertCell(4).textContent = prixUnit.toFixed(2);
            newRow.insertCell(5).textContent = totalLigne;

            // Ajouter les champs cachés
            ajouterChampCache("articles", art.value);
            ajouterChampCache("quantites", quantite);
            ajouterChampCache("prixs", prixUnit.toFixed(2));

            majTotal();

            // Mettre à jour le total caché
            document.getElementById("hiddenTotal").value = document.getElementById("total").value;
        }

        function majTotal() {
            const table = document.getElementById("commandeTable");
            const rows = table.querySelectorAll("tr:not(:first-child)");
            let totalGeneral = 0;

            rows.forEach(row => {
                if (row.cells.length >= 6) {
                    const totalLigne = parseFloat(row.cells[5].textContent);
                    if (!isNaN(totalLigne)) totalGeneral += totalLigne;
                }
            });

            document.getElementById("total").value = totalGeneral.toFixed(2);
        }

        function supprimerLigne(btn) {
            const row = btn.parentNode.parentNode;
            row.parentNode.removeChild(row);
            majTotal();
        }
        
        
    </script>
    
    <!-- Génération du JS dynamique -->
    <script>
	<%
	    Connection conn2 = null;
	    Statement stmt2 = null;
	    ResultSet rs2 = null;
	    try {
	        Class.forName("oracle.jdbc.driver.OracleDriver");
	        conn2 = DriverManager.getConnection("jdbc:oracle:thin:@//localhost:1521/orcl", "zineb", "zineb123");
	        stmt2 = conn2.createStatement();
	        rs2 = stmt2.executeQuery("SELECT id_article, nom_article, id_categorie FROM Article");
	
	        Map<Integer, List<Map<String, String>>> mapCat = new HashMap<>();
	
	        while (rs2.next()) {
	            int idA = rs2.getInt("id_article");
	            String nomA = rs2.getString("nom_article").replace("\"", "\\\""); // 🔹 échappe les guillemets
	            int idC = rs2.getInt("id_categorie");
	
	            mapCat.computeIfAbsent(idC, k -> new ArrayList<>());
	            Map<String, String> art = new HashMap<>();
	            art.put("id", String.valueOf(idA));
	            art.put("nom", nomA);
	            mapCat.get(idC).add(art);
	        }
	
	        // Génération JSON propre
	        out.println("let articlesData = {");
	        for (Map.Entry<Integer, List<Map<String, String>>> entry : mapCat.entrySet()) {
	            out.println("\"" + entry.getKey() + "\": [");
	            for (int i = 0; i < entry.getValue().size(); i++) {
	                Map<String, String> art = entry.getValue().get(i);
	                out.println("{ id: \"" + art.get("id") + "\", nom: \"" + art.get("nom") + "\" }" +
	                            (i < entry.getValue().size() - 1 ? "," : ""));
	            }
	            out.println("],");
	        }
	        out.println("};");
	        out.println("console.log('articlesData:', articlesData);"); // debug
	    } catch (Exception e) {
	        out.println("let articlesData = {}; console.error('Erreur chargement articles:', '" + e.getMessage() + "');");
	    } finally {
	        try { if(rs2!=null) rs2.close(); if(stmt2!=null) stmt2.close(); if(conn2!=null) conn2.close(); } catch (Exception ex) {}
	    }
	%>
	
	
	</script>
</head>

<body>
    <h2>Créer une commande</h2>
    
    

    <form action="interface2.jsp" method="post">
    
    <!-- Champs cachés pour stocker les données dynamiquement -->
	<div id="hiddenFields"></div>
	<input type="hidden" name="total_commande" id="hiddenTotal">
	
        <!-- Sélection du client -->
        <label for="id_client">Client :</label>
        <select name="id_client" id="id_client" required>
            <option value="">--Sélectionner un client--</option>
            <%
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                try {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    conn = DriverManager.getConnection("jdbc:oracle:thin:@//localhost:1521/orcl", "zineb", "zineb123");
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery("SELECT id_client, nom, prenom FROM Client");
                    while (rs.next()) {
                        int id = rs.getInt("id_client");
                        String nom = rs.getString("nom");
                        String prenom = rs.getString("prenom");
            %>
                        <option value="<%=id%>"><%=nom + " " + prenom%></option>
            <%
                    }
                } catch (Exception e) {
                    out.println("<pre>");
                    e.printStackTrace(new java.io.PrintWriter(out));
                    out.println("</pre>");
                } finally {
                    try { if(rs!=null) rs.close(); if(stmt!=null) stmt.close(); if(conn!=null) conn.close(); } catch (Exception ex) {}
                }
            %>
        </select>

        <hr>
        <h3>Ajouter des articles</h3>

        <!-- Catégorie -->
        <label for="categorie">Catégorie :</label>
        <select id="categorie" onchange="updateArticles()">
            <option value="">--Sélectionner une catégorie--</option>
            <%
                try {
                    conn = DriverManager.getConnection("jdbc:oracle:thin:@//localhost:1521/orcl", "zineb", "zineb123");
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery("SELECT id_categorie, libelle FROM CategorieArticle");
                    while (rs.next()) {
                        int id = rs.getInt("id_categorie");
                        String libelle = rs.getString("libelle");
            %>
                        <option value="<%=id%>"><%=libelle%></option>
            <%
                    }
                } catch (Exception e) {
                    out.println("<pre>");
                    e.printStackTrace(new java.io.PrintWriter(out));
                    out.println("</pre>");
                } finally {
                    try { if(rs!=null) rs.close(); if(stmt!=null) stmt.close(); if(conn!=null) conn.close(); } catch (Exception ex) {}
                }
            %>
        </select>

        <!-- Article -->
        <label for="article">Article :</label>
        <select id="article">
            <option value="">--Sélectionner un article--</option>
        </select>
        
        <!-- Prix Unitaire -->
        <label for="prix">Prix-unitaire :</label>
        <input type="number" id="prix">

        <!-- Quantité -->
        <label for="qte">Quantité :</label>
        <input type="number" id="qte" min="1">

        <button type="button" onclick="ajouterLigne()">Ajouter</button>

        <!-- Tableau des lignes -->
        <h4>Articles ajoutés :</h4>
        <table border="1" id="commandeTable">
            <tr>
                <th>Suppression</th>
                <th>Catégorie</th>
                <th>Article</th>
                <th>Quantité</th>
                <th>Prix Unitaire</th>
                <th>TotalLigne</th>
            </tr>
        </table>

        <!-- Total -->
        <label for="total">Total commande :</label>
        <input type="number" id="total" readonly>

        <br><br>
        <button type="submit">Suivant</button> //suivant vers un autre interface2.jsp de reglement
    </form>
    
    <script>
document.querySelector("form").addEventListener("submit", function() {
    const allInputs = document.querySelectorAll("input[type=hidden]");
    allInputs.forEach(i => console.log(i.name, "=", i.value));
});
</script>
    
   
<%// Stockage dans la session côté serveur
    session.setAttribute("id_client", request.getParameter("id_client"));
    session.setAttribute("total_commande", request.getParameter("total"));
    session.setAttribute("articles", request.getParameterValues("articles"));   // CORRECT
    session.setAttribute("quantites", request.getParameterValues("quantites")); // CORRECT
    session.setAttribute("prixs", request.getParameterValues("prixs"));         // CORRECT
%>




    
</body>
</html>