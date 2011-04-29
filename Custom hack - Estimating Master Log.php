/* Hours Calculation
 *
 * 09 Feb 2010 - B. Garlock:  This takes the inputted times in the form, and converts them to Unix   epoch (Number of seconds since 1/1/1970)
 *                            
 *                            
*/

function networkdays($startdate, $enddate)
  {
     $start_array = getdate(strtotime($startdate));
     $end_array = getdate(strtotime($enddate));

     // Make appropriate Sundays
     $start_sunday = mktime(0, 0, 0, $start_array[mon], $start_array[mday]+(7-$start_array[wday]),$start_array[year]);
     $end_sunday = mktime(0, 0, 0, $end_array[mon], $end_array[mday]- $end_array[wday],$end_array[year]);

     // Calculate days in the whole weeks
     $week_diff = $end_sunday - $start_sunday;
     $number_of_weeks = round($week_diff /604800); // 60 seconds * 60 minutes * 24 hours * 7 days = 1 week in seconds
     $days_in_whole_weeks = $number_of_weeks * 5;

     //Calculate extra days at start and end
     //[wday] is 0 (Sunday) to 7 (Saturday)
     $days_at_start = 6 - $start_array[wday];
     $days_at_end = $end_array[wday];

     $total_days = $days_in_whole_weeks + $days_at_start + $days_at_end;

     return $total_days;
}



	$est_log_timeReceived = "$est_log_dateReceived $est_log_timeReceived";
	$est_log_timeReceived = strtotime ("$est_log_timeReceived");

	$est_log_timeCompleted = "$est_log_dateCompleted $est_log_timeCompleted";
	$est_log_timeCompleted = strtotime ("$est_log_timeCompleted");

	if($est_log_timeCompleted < $est_log_timeReceived){
		$est_log_timeCompleted = $est_log_timeCompleted + 86400;
	}

    $calc_seconds = ($est_log_timeCompleted - $est_log_timeReceived);

    // Calculate The Days portion, taking into account the weekend and company holiday's 
    //   
    // TODO: Leave out Garlock Vacation days of the calculation
    // 
    // Function Used:  networkdays($est_log_dateReceived, $est_log_dateCompleted)
    //                 returns variable:  $total_days

    networkdays($est_log_dateReceived, $est_log_dateCompleted);
    $total_turnTime_hours = $total_days * 24;
    $total_turnTime_minutes = $total_turnTime_hours * 60;
    $total_turnTime_seconds = $total_turnTime_minutes * 60;

    //  Add together all the seconds
	
    $calc_hours = $total_turnTime_seconds + $calc_seconds;

    //  Final step:  This will take the seconds, and convert to hours.tenths of an hour
	$calc_hours = $calc_hours/3600;
	$est_log_turnTime = round($calc_hours,2);
	
	// Comment out the default (or make it READ ONLY in the AppGini App) since we want to store the calculation based
	// on what we calculate it to be, not what the form data says
	
	//$data['est_log_turnTime'] = makeSafe($_POST['est_log_turnTime']);
