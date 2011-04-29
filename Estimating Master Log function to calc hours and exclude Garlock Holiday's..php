////////////////////////////////////////////////////////////////////
// 2010-02-17 jimb created to be used with quoting log 
// the purpose of this function to determine the accumulated
// hours between dates.  Accumulated time must not occur
// on weekends and holidays.
//
// holidays are determined from database.
//		server.database.table
// 		linux.holidays.garlock

function AccumulateTime($SentData){
	// the purpose of this function to determine the accumulated
	// hours between dates.  Accumulated time must not occur
	// on weekends and holidays.
	//
	// holidays are determined from database.
	//		server.database.table
	// 		linux.holidays.garlock
	
	$Start 	=	$SentData[0];
	$End 	=	$SentData[1];

	/* used for testing
	$Start 	= "2010-02-12 15:00:00";
	$End 	= "2010-02-16 15:30:00";
	*/
	// setting counters for loop

	if($Start and $End){
	
		$temp_start = strtotime ("$Start");
		$accum_date = $temp_start;
		$temp_end = strtotime ("$End");
		$calc_seconds = ($temp_end - $temp_start);

		/*   used for testing
		echo "$Start ($temp_start) 
		<BR>$End ($temp_end)
		<BR>$calc_seconds
		<P>";
		*/


		///   lets check to see if date is a garlock holiday
		$Holidays = array();
		$con1 = @mysql_connect("192.168.200.180", "nobody","nobody") or die("couldn't connect TO DATABASE.");
		$db1= mysql_select_db("holidays", $con1);
		$sql1 = (" SELECT  date_of_holiday    FROM garlock ORDER BY  date_of_holiday     ");
		$result1 = mysql_query($sql1,$con1) or die("couldn't connect TO DATABASE.");
		while ( $row1 = mysql_fetch_array($result1))
		{
			$date_of_holiday = $row1 ['date_of_holiday'];
			//echo "$date_of_holiday - ";
			$Holidays[] = "$date_of_holiday";
		}

		// used for testing $tmp = sizeof($Holidays);
		// echo "array: $tmp";

		// increment accumulator in seconds
		$IncrementQty = 60;

		// lets loop the date incrementally until reach the end date or end of counter
		while($accum_date <= $temp_end and $Count <= 150000)
		{
			// add to counter
			++$Count;

			// increment
			$accum_date = $accum_date + $IncrementQty;  
	
			// setting some values based on incremented date.
			// this is so can compare day of week and evaluate if date is a holiday
			$dow = date('w', $accum_date);
			$display = date('Y-m-d H:i', $accum_date);
			$check_date = date('Y-m-d', $accum_date);

			// if a weekend then increment until no longer a week end.
			// this way it doesn't accumulate during sat / Sunday.
			// lets account for sat & sun
			if($dow == 6 or $dow == 0){
				while($dow == 6 or $dow == 0){
				$accum_date	= $accum_date + $IncrementQty; // make Monday
				$dow = date('w', $accum_date);
				}
			}

			// check to see if a holiday.  if so then increment until not.
			// this way doesn't accumulate during holiday
			if(in_array("$check_date", $Holidays)){

				while(in_array("$check_date", $Holidays)){
					$accum_date	= $accum_date + $IncrementQty; 
					$check_date = date('Y-m-d', $accum_date);
				}
			}

			// used for testing  echo "<BR>$Count $accum_date - $display ($check_date)-  $dow";

	

		}
		// end main increment loop

		// now that we incremented accumulated counter we
		// can do the math out and then return
		$calc_hours = ($IncrementQty * $Count)/3600;
		$calc_hours = round($calc_hours,2); 
		
		// used for testing  echo "<hr>Final: $IncrementQty * $Count = $calc_hours;";

	}
	// end if start & end was sent


	return $calc_hours;
}
// end function
