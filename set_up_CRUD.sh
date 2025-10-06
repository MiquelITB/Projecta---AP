#!/bin/bash
# ======================================================
# Script instalación CRUD PHP + MariaDB (Ubuntu)
# Autor: Steven Zapata
# Versión: 1.1 (corrección errores PHP)
# ======================================================

# ==== VARIABLES DE CONFIGURACIÓN (MODIFICAR AQUÍ) ====
DB_NAME="crud_db"
DB_USER="cruduser"
DB_PASS="crud1234"
APP_DIR="/var/www/html/app"
# ======================================================

echo "=== [1/8] Actualizando sistema ==="
sudo apt update && sudo apt upgrade -y

echo "=== [2/8] Instalando Apache, PHP y extensiones ==="
sudo apt install -y apache2 php php-mysql libapache2-mod-php php-mbstring php-xml php-zip php-gd php-curl unzip

echo "=== [3/8] Instalando y configurando MariaDB ==="
sudo apt install -y mariadb-server mariadb-client

# --- Crear script SQL para endurecimiento y creación de BD ---
echo "Creando base de datos y usuario..."
cat <<EOF > /tmp/crud_setup.sql
-- Limpieza de configuración por defecto
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;

-- Crear base de datos y usuario CRUD
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;

-- Crear tabla de usuarios
USE \`${DB_NAME}\`;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);
EOF

sudo mysql < /tmp/crud_setup.sql

echo "=== [4/8] Configurando aplicación PHP ==="
sudo rm -rf "$APP_DIR"
sudo mkdir -p "$APP_DIR"

# db.php
cat <<EOF | sudo tee ${APP_DIR}/db.php > /dev/null
<?php
\$servername = "localhost";
\$username   = "${DB_USER}";
\$password   = "${DB_PASS}";
\$dbname     = "${DB_NAME}";
\$conn = new mysqli(\$servername, \$username, \$password, \$dbname);
if (\$conn->connect_error) {
    die("Connexió fallida: " . \$conn->connect_error);
}
\$conn->set_charset("utf8mb4");
?>
EOF

# index.php
cat <<'EOF' | sudo tee ${APP_DIR}/index.php > /dev/null
<?php include 'db.php'; ?>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <title>CRUD mínim</title>
</head>
<body>
    <h1>Llista d’usuaris</h1>

    <table border="1">
        <tr><th>ID</th><th>Nom</th><th>Email</th><th>Accions</th></tr>
        <?php
        $result = $conn->query("SELECT * FROM users");
        if ($result && $result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                $id = (int)$row['id'];
                $name = htmlspecialchars($row['name'], ENT_QUOTES);
                $email = htmlspecialchars($row['email'], ENT_QUOTES);
                echo "<tr>
                        <td>{$id}</td>
                        <td>{$name}</td>
                        <td>{$email}</td>
                        <td>
                            <a href='edit.php?id={$id}'>Editar</a> | 
                            <a href='delete.php?id={$id}' onclick=\"return confirm('Eliminar usuari #{$id}?')\">Eliminar</a>
                        </td>
                     </tr>";
            }
        } else {
            echo "<tr><td colspan='4'>No hi ha usuaris</td></tr>";
        }
        ?>
    </table>

    <h2>Afegir usuari</h2>
    <form action="add.php" method="post">
        Nom: <input type="text" name="name" required>
        Email: <input type="email" name="email" required>
        <button type="submit">Afegir</button>
    </form>
</body>
</html>
EOF

# add.php
cat <<'EOF' | sudo tee ${APP_DIR}/add.php > /dev/null
<?php
include 'db.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header("Location: index.php");
    exit;
}
$name  = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
if ($name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    die("Dades invàlides. Torna enrere i comprova el nom i l'email.");
}
$stmt = $conn->prepare("INSERT INTO users (name, email) VALUES (?, ?)");
$stmt->bind_param("ss", $name, $email);
$stmt->execute();
$stmt->close();
header("Location: index.php");
exit;
?>
EOF

# edit.php
cat <<'EOF' | sudo tee ${APP_DIR}/edit.php > /dev/null
<?php
include 'db.php';
$user = null;
if (isset($_GET['id'])) {
    $id = (int)$_GET['id'];
    $stmt = $conn->prepare("SELECT id, name, email FROM users WHERE id = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $res = $stmt->get_result();
    $user = $res->fetch_assoc();
    $stmt->close();
}
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id    = (int)($_POST['id'] ?? 0);
    $name  = trim($_POST['name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    if ($id <= 0 || $name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        die("Dades invàlides.");
    }
    $stmt = $conn->prepare("UPDATE users SET name = ?, email = ? WHERE id = ?");
    $stmt->bind_param("ssi", $name, $email, $id);
    $stmt->execute();
    $stmt->close();
    header("Location: index.php");
    exit;
}
?>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <title>Editar usuari</title>
</head>
<body>
    <h1>Editar usuari</h1>
    <?php if (!$user): ?>
        <p>Usuari no trobat.</p>
        <p><a href="index.php">Tornar</a></p>
    <?php else: ?>
    <form method="post">
        <input type="hidden" name="id" value="<?= (int)$user['id'] ?>">
        Nom: <input type="text" name="name" value="<?= htmlspecialchars($user['name'], ENT_QUOTES) ?>" required>
        Email: <input type="email" name="email" value="<?= htmlspecialchars($user['email'], ENT_QUOTES) ?>" required>
        <button type="submit">Desar</button>
    </form>
    <?php endif; ?>
</body>
</html>
EOF

# delete.php
cat <<'EOF' | sudo tee ${APP_DIR}/delete.php > /dev/null
<?php
include 'db.php';
if (!isset($_GET['id'])) {
    header("Location: index.php");
    exit;
}
$id = (int)$_GET['id'];
if ($id <= 0) {
    header("Location: index.php");
    exit;
}
$stmt = $conn->prepare("DELETE FROM users WHERE id = ?");
$stmt->bind_param("i", $id);
$stmt->execute();
$stmt->close();
header("Location: index.php");
exit;
?>
EOF

# Permisos
sudo chown -R www-data:www-data $APP_DIR
sudo chmod -R 755 $APP_DIR

echo "=== [5/8] Configurando Apache ==="
sudo tee /etc/apache2/sites-available/crud_app.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot ${APP_DIR}
    <Directory ${APP_DIR}>
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/crud_error.log
    CustomLog \${APACHE_LOG_DIR}/crud_access.log combined
</VirtualHost>
EOF

sudo a2ensite crud_app.conf
sudo systemctl reload apache2

echo "=== [6/8] Limpiando temporales ==="
sudo rm -f /tmp/crud_setup.sql

echo "=== [7/8] Reiniciando servicios ==="
sudo systemctl restart apache2
sudo systemctl restart mariadb

echo "=== [8/8] Instalación completada ==="
echo
echo "✅ Aplicación desplegada en: http://localhost/app"
echo "✅ Base de datos creada: ${DB_NAME}"
echo "✅ Usuario BBDD: ${DB_USER}"
echo "✅ Password: ${DB_PASS}"
echo
echo "Puedes acceder desde tu navegador y empezar a usar el CRUD."
