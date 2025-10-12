<%@ page language="java" contentType="text/html; charset=UTF-8" import="java.sql.Connection, java.sql.DriverManager, java.sql.Statement, java.sql.ResultSet"
    pageEncoding="UTF-8" import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Selection Client</title>
    <script>
        let articlesData = {}; // rempli depuis le script JSP plus bas

        function updateArticles() {
            const categorySelect = document.getElementById("categorie");
            const articleSelect = document.getElementById("article");
            const selectedCat = categorySelect.value;

            // Réinitialiser la liste des articles
            articleSelect.innerHTML = '<option value="">--Sélectionner un article--</option>';

            if (articlesData[selectedCat]) {
                articlesData[selectedCat].forEach(article => {
                    const option = document.createElement("option");
                    option.value = article.id;
                    option.text = article.libelle;
                    option.setAttribute("data-prix", article.prix);
                    articleSelect.appendChild(option);
                });
            }

            document.getElementById("prix").value = "";
        }

        function updatePrix() {
            const articleSelect = document.getElementById("article");
            const selectedOption = articleSelect.options[articleSelect.selectedIndex];
            const prix = selectedOption.getAttribute("data-prix");
            document.getElementById("prix").value = prix || "";
        }

        function ajouterCommande() {
            const categorie = document.getElementById("categorie");
            const articleSelect = document.getElementById("article");
            const prixField = document.getElementById("prix");
            const qteField = document.getElementById("qte");
            const totalField = document.getElementById("total");
            const table = document.getElementById("commandeTable");

            const catText = categorie.options[categorie.selectedIndex].text;
            const articleText = articleSelect.options[articleSelect.selectedIndex].text;
            const articleId = articleSelect.value;
            const prix = parseFloat(prixField.value);
            const qte = parseInt(qteField.value);

            if (!articleId || isNaN(prix) || isNaN(qte) || qte <= 0) {
                alert("Veuillez remplir tous les champs correctement.");
                return;
            }

            const totalLigne = prix * qte;

            // Création d'une nouvelle ligne
            const row = table.insertRow();
            row.innerHTML = `
                <td><button type="button" onclick="supprimerLigne(this)">🗑️</button></td>
                <td>${catText}</td>
                <td><input type="hidden" name="articles[]" value="${articleId}">${articleText}</td>
                <td><input type="hidden" name="prixs[]" value="${prix}">${prix.toFixed(2)}</td>
                <td><input type="hidden" name="qtes[]" value="${qte}">${qte}</td>
                <td class="ligneTotal">${totalLigne.toFixed(2)}</td>
            `;

            // Réinitialiser les champs
            qteField.value = "";
            prixField.value = "";

            // Mise à jour du total général
            majTotal();
        }

        function supprimerLigne(btn) {
            const row = btn.parentNode.parentNode;
            row.remove();
            majTotal();
        }

        function majTotal() {
            const lignes = document.querySelectorAll("#commandeTable .ligneTotal");
            let total = 0;
            lignes.forEach(ligne => {
                total += parseFloat(ligne.textContent) || 0;
            });
            document.getElementById("total").value = total.toFixed(2);
        }
    </script>
</head>

<body>
<h2>Choisir un client</h2>

<form action="creationCommande.jsp" method="post">

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
    <h3>Ajouter des articles à la commande</h3>

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
    <select id="article" onchange="updatePrix()">
        <option value="">--Sélectionner un article--</option>
    </select>

    <!-- Prix et quantité -->
    <label for="prix">Prix unitaire :</label>
    <input type="number" id="prix" readonly>

    <label for="qte">Quantité :</label>
    <input type="number" id="qte" min="1">

    <button type="button" onclick="ajouterCommande()">Ajouter</button>

    <!-- Liste des articles ajoutés -->
    <h4>Articles ajoutés :</h4>
    <table border="1" id="commandeTable">
        <tr>
            <th>Suppression</th>
            <th>Catégorie</th>
            <th>Article</th>
            <th>Prix unitaire</th>
            <th>Quantité</th>
            <th>Total Ligne</th>
        </tr>
    </table>

    <label for="total">Total Commande :</label>
    <input type="number" id="total" readonly>

    <br><br>
    <button type="submit">Suivant</button>
</form>

<!-- Génération de l'objet JavaScript avec les articles par catégorie -->
<script>
<%
    try {
        conn = DriverManager.getConnection("jdbc:oracle:thin:@//localhost:1521/orcl", "zineb", "zineb123");
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT id_article, nom_article, id_categorie, prix_unitaire FROM Article");

        Map<Integer, List<Map<String, String>>> catArticles = new HashMap<>();

        while (rs.next()) {
            int id = rs.getInt("id_article");
            String nomArticle = rs.getString("nom_article");
            float prix = rs.getFloat("prix_unitaire");
            int idCat = rs.getInt("id_categorie");

            catArticles.computeIfAbsent(idCat, k -> new ArrayList<>());

            Map<String, String> art = new HashMap<>();
            art.put("id", String.valueOf(id));
            art.put("libelle", nomArticle);
            art.put("prix", String.valueOf(prix));
            catArticles.get(idCat).add(art);
        }

        out.println("articlesData = {");
        for (Map.Entry<Integer, List<Map<String, String>>> entry : catArticles.entrySet()) {
            out.println("\"" + entry.getKey() + "\": [");
            for (Map<String, String> art : entry.getValue()) {
                out.println("{id: \"" + art.get("id") + "\", libelle: \"" + art.get("libelle") + "\", prix: \"" + art.get("prix") + "\"},");
            }
            out.println("],");
        }
        out.println("};");
    } catch (Exception e) {
        out.println("<pre>");
        e.printStackTrace(new java.io.PrintWriter(out));
        out.println("</pre>");
    } finally {
        try { if(rs!=null) rs.close(); if(stmt!=null) stmt.close(); if(conn!=null) conn.close(); } catch (Exception ex) {}
    }
%>
</script>
</body>
</html>