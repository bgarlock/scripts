//------------------------------------------------------------------------------
// Function Name:  builddropboxLamLayer1
//------------------------------------------------------------------------------
	function builddropboxLamLayer1($ThisField, $SelectValue, $TabIndex, $ONCHANGE_PERFORM) 
	{
		$show_input = null;
		$build_options = null;
	

	  // Reference Database and errormsg global variables
	  //----------------------------------------------------------------------
			$get_just_variables = "YES";
			include("../includes/include_common_globals.php");
			include("../includes/include_globals.php");

	//		global $SelectValue, $ThisField, $TabIndex;


	 	// loop through options
	        $con = @mysql_connect("$HostOedb", "$UserOedb", "$PwOedb")
	            or die("couldn't connect TO  DATABASE $db_oedb
	                            <P>" .mysql_error()."");
			$db= mysql_select_db("$db_oedb", $con);
			$sql = ("SELECT  ll_id, ll_description
			         FROM   laminates
			         ");
			$result = mysql_query($sql,$con);
			while ( $row = mysql_fetch_array($result))
			{
			    $ll_id = $row [ll_id];
			    $ll_description = $row [ll_description];
				$sel = null;
				if($SelectValue == $ll_id)
				{ 
					$sel = "SELECTED";
				}

	             $build_options = "$build_options
					<option class=white value=\"$ll_id\" $sel>$ll_description</option>";
			}
			// end loop options
		
		// start select
			$show_input = "<select tabindex=$TabIndex name=\"$ThisField\"
					 	$ONCHANGE_PERFORM	>
				<option value=\"\"></option>
				$build_options
				</select>";

		return $show_input;
	}