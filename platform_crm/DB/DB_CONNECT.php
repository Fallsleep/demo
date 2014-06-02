<?php
$con = mysqli_connect("localhost","root","","crm");
if (mysqli_connect_errno()){ echo "Failed to connect to MySQL: " . mysqli_connect_error(); } // Check connection
mysqli_set_charset($con, "utf8");
?>