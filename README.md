# CRUD PHP
Este repositorio contiene el codigo fuente de la aplicación CRUD, la cual esta desarrollada en PHP.

Al inicio de la pràctica, el codigo contenia errores muy graves. Estos hacian imposible la ejecución del còdigo y, por lo tanto, su uso (Todos los errores expuestos y corregidos en Errores_Markdown.md).

El projecto ha seguido los siguientres paso para resolverlo:
1. Creación y versionado en Git en un primer servidor.
2. Despliegue y configuración de los servicios (Apache, PHP y MariaDB) En ambos servidores.
3. Identificacón y correción de los errores de código.
4. Despliegue definitivo del programa en el 2nd servidor.

## Documentación técnica del despliegue en Isard:
- Nom: SRV-Projecte
- Hardware: 4 vCPUS
- Memoria: 8 GB
- SO: Ubuntu 13 Server
Es la misma configuración para ambos servidores.

## Proceso de Instalación y Configuración de los servicios:

Los servicios que se han tenido que instalar son los de web (Apache2), PHP y Base de datos (mysql). Esta es la lista de los servicios activos en el sistema.<br>

<img width="844" height="509" alt="Lista de servicios activos" src="https://github.com/user-attachments/assets/94c86345-9779-44d3-afba-4dbfb1599c02" /> <br>

La lista de servicios instalados son iguales en ambos servidores. <br>

Primero se ha actualizado el sistema (sudo apt update) y luego se ha instalado los servicios de la base de datos: <br>
`sudo apt install mariadb-server -y` <br>
`sudo mysql_secure_installation`<br>

Luego se ha creado la base de datos con los usuarios necesarios: <br>
<img width="855" height="618" alt="Creación BD" src="https://github.com/user-attachments/assets/a78e3406-2e39-45d7-96bd-6f33385ea876" /> <br>

A continuación se instala el Servidor Web:<br>
`sudo apt install apache2 php libapache2-mod-php php-mysql -y`<br>
Y creamos todos los archivos que conforman la pagina web con las correciones ya realizadas: <br>

<img width="883" height="592" alt="web" src="https://github.com/user-attachments/assets/0c04abe8-905f-4fe9-9629-ba52d34bf86b" /> <br>

La extructura que hemos seguido es la siguiente: <br>

crud-app/
 ├── db.php         (connexió a la BBDD)
 ├── index.php      (llista usuaris + formulari per afegir-ne)
 ├── add.php        (afegeix usuari)
 ├── delete.php     (elimina usuari)
 └── edit.php       (edita usuari)

El codigo de cada uno de los achivos se encuentra en AP ASIXc2 Projecte.php <br>

## Despliegue de la app

Una vez Instalados los servicios y corregido el código, llegó la hora del despliegue de la app. Abrimos la web donde se el código y comrpobamos que funciona correctamente y no aparecen errores. <br>

<img width="889" height="426" alt="Desplegue" src="https://github.com/user-attachments/assets/b027e3b3-0539-4ada-9955-08d45d048592" /> <br>

Se pueden eliminar a los usuarios:<br>
<img width="888" height="202" alt="Eliminado" src="https://github.com/user-attachments/assets/0d26c42d-0096-4712-a183-f6fc81a6416c" /><br>

Y editar los usuarios:<br>
<img width="878" height="274" alt="Edit" src="https://github.com/user-attachments/assets/3adb4e13-4b36-4c4d-9da3-d7bd82be4a86" /><br>





