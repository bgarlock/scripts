/*  lets get the layer description   */

function GetLayerDescription($layer){
	global $host, $user, $pw;

	if($layer){
	      /* make a connection to oedb.laminates to get the laminate description */
	    $con_lam1 = @mysql_connect("$host", "$user", "$pw") or 
	        die("couldn't connect TO $host as user: $user (wrong user/pass?)." . mysql_error() . "");
	    $db_lam1= mysql_select_db("oedb", $con_lam1);
	    $sql_lam1 = (" SELECT ll_id, ll_description
	                   FROM   laminates
	                   WHERE  ll_id = $layer
	                 ");
	    $result_lam1 = mysql_query($sql_lam1,$con_lam1);
	    while ( $row_lam1 = mysql_fetch_array($result_lam1)){
	        $description = $row_lam1 ['ll_description'];
	    }
	    if($con_lam1){     
	        mysql_close($con_lam1); 
	    }
	}

	return $description;
}






/* Now we assign a variable to this image, to be called in the html table below */
$image_width 	= 325;
$image_height 	= 256;
$PASS1_IMAGE = "<img border=0 width=$image_width height=$image_height src=\"$PASS1_IMAGE.jpg\">";


			<tr>
			   <td class=\"dkbg\"><b>Laminator Layers:</b></td>
			   <td valign=top colspan=2>$PASS1_IMAGE</td>
			   <td valign=top colspan=2>$PASS2_IMAGE</td>
			</tr>
