```php
// db.php
// Original:
$servername = "locahost"; // mal escrito

// Corregido:
$servername = "localhost"; // hostname correcto

// ------------------------------

// Script SQL - Crear base de datos
// Original:
CREATE DATABASE crud_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci Where false; // WHERE false no existe en SQL; además se añade IF NOT EXISTS para evitar error si la BD ya existe

// Corregido:
CREATE DATABASE IF NOT EXISTS crud_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

// ------------------------------

// add.php - INSERT
// Original:
$stmt = $conn->prepare("INSERT INTO users (name, email) VALUES (*, ?)"); // * no se puede usar en VALUES

// Corregido:
$stmt = $conn->prepare("INSERT INTO users (name, email) VALUES (?, ?)");

// ------------------------------

// index.php - formulario
// Original:
<form action="add.php" method="posts"> <!-- posts no es un metodo válido -->

// Corregido:
<form action="add.php" method="post">

// ------------------------------

// index.php - tabla duplicada
// Original:
<table>
<table border="1"> <!-- table duplicado causa errores -->

// Corregido:
<table border="1">

// ------------------------------

// edit.php - UPDATE
// Original:
$stmt = $conn->prepare("UPDATE users where name=?, email=? WHERE id=?");

// Corregido:
$stmt = $conn->prepare("UPDATE users SET name = ?, email = ? WHERE id = ?"); 
// SET es obligatorio para indicar columnas a actualizar.

// ------------------------------

// delete.php - DELETE
// Original:
$conn->query("DELETE * FROM users WHERE id=$id"); // DELETE * no es válido en SQL

// Corregido:
$conn->query("DELETE FROM users WHERE id=$id");

// ------------------------------

// Escapado de datos en PHP
// Original:
echo "<td>{$row['name']}</td>";

// Corregido:
echo "<td>" . htmlspecialchars($row['name'], ENT_QUOTES) . "</td>";
// Explicación: Evita inyección de HTML/JS mostrando caracteres especiales correctamente.
