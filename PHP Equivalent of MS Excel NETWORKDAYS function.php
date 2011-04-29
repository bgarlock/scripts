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