<?php
/* Hours Calculation
 *
 * 09 Feb 2010 - B. Garlock:  This takes the inputted times in the form, and converts them to Unix epoch (Number of seconds since 1/1/1970)
 *                            
 *                            


*/
$est_log_timeReceived = "$est_log_dateReceived $est_log_timeReceived";
$est_log_timeReceived = strtotime ("$est_log_timeReceived");

$est_log_timeCompleted = "$est_log_dateCompleted $est_log_timeCompleted";
$est_log_timeCompleted = strtotime ("$est_log_timeCompleted");

if($est_log_timeCompleted < $est_log_timeReceived){
	$est_log_timeCompleted = $est_log_timeCompleted + 86400;
}

$calc_hours = ($est_log_timeCompleted - $est_log_timeReceived)/3600;
$calc_hours = round($calc_hours,2);

?>