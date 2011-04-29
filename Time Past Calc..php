<?php 
function calculate_time_past($start_time, $end_time, $format = "s") { 
    $time_span = strtotime($end_time) - strtotime($start_time); 
    if ($format == "s") { // is default format so dynamically calculate date format 
        if ($time_span > 60) { $format = "i:s"; } 
        if ($time_span > 3600) { $format = "H:i:s"; } 
    } 
    return gmdate($format, $time_span); 
} 

$start_time = "2007-03-28 00:50:14"; // 00:50:14 will work on its own 
$end_time = "2007-03-28 00:52:59"; // 00:52:59 will also work instead 

echo calculate_time_past($start_time, $end_time) . "<br />"; // will output 02:45 
echo calculate_time_past($start_time, $end_time, "H:i:s"); // will output 00:02:45 when format is overridden 
?> 
