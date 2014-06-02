<?php
    include("../DB/DB_CONNECT.php");

    $sql = mysql_query("SELECT trade_item FROM crm_accounts WHERE id=" . $_POST['aid']);
	if($result = mysqli_query($con, $sql)){
		$row = mysqli_fetch_assoc($result);
		echo json_encode("trade_item" => $row['trade_item']);
		mysqli_free_result($result);
	}
	
	include("../DB/DB_DISCONNECT.php");
?>