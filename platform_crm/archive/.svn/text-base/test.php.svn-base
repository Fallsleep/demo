<?php
if(isset($_POST['submit'])) 
{
	$cf_arr = array();
	$i=0; 
	while(!empty($_POST['cf'.$i.'_key']) && !empty($_POST['cf'.$i.'_value'])){
		$cf_arr[$_POST['cf'.$i.'_key']] = $_POST['cf'.$i.'_value'];
		$i++;
	}
	$cf_arr = json_encode($cf_arr);
	
    $con=mysqli_connect("localhost","root","","crm");
	// Check connection
	if (mysqli_connect_errno()){ echo "Failed to connect to MySQL: " . mysqli_connect_error(); }

	$sql="INSERT INTO crm_test (CUSTOM_FIELD) VALUES ('$cf_arr')";
	if (!mysqli_query($con,$sql)){ die('Error: ' . mysqli_error());	}
	echo "Record: " . $cf_arr . " is inserted. ";

	mysqli_close($con);
}
?>
<form method="post" action="<?php echo htmlentities($_SERVER['PHP_SELF']); ?>">
   Custom Field 1 Name: <input type="text" name="cf0_key"> Custom Field 1 Content: <input type="text" name="cf0_value"><br>
   Custom Field 2 Name: <input type="text" name="cf1_key"> Custom Field 2 Content: <input type="text" name="cf1_value"><br>
   Custom Field 3 Name: <input type="text" name="cf2_key"> Custom Field 3 Content: <input type="text" name="cf2_value"><br>
   Custom Field 4 Name: <input type="text" name="cf3_key"> Custom Field 4 Content: <input type="text" name="cf3_value"><br>
   Custom Field 5 Name: <input type="text" name="cf4_key"> Custom Field 5 Content: <input type="text" name="cf4_value"><br>
   <input type="submit" name="submit" value="Submit Form"><br>
</form>