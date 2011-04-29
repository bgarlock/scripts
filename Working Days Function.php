function workingDays($days=5,$start=null,$skipToday=null,$returnFormat=null){ 
    // populate this with an array of work dates 
    $holidays = array('2007-01-08','2007-12-25','2007-12-31'); 
    // valid work days, 0 = sunday, 6 = saturday 
    $workDays = array('1', '2', '3', '4', '5');   
    $start = (isset($start))? date("Y-m-d",strtotime($start)) : date("Y-m-d"); 
    $daysGoal = (isset($days) && intval($days)==$days)? $days : 5; 
    $dayCounter = 0; 
    if(isset($skipToday) && $skipToday===true){ 
        $dayCounter = 1; 
    } 
    $daysSoFar = 0; 
    while( $daysSoFar < $daysGoal ){ 
        $workingDate = strtotime("+$dayCounter days", strtotime("$start 12:00:00")); 
        if( in_array(date("w",$workingDate),$workDays) ){ 
            if(!(in_array(date("Y-m-d", $workingDate), $holidays))){ 
                $daysSoFar++; 
            } 
        } 
    $dayCounter++; 
    } 
    if(isset($returnFormat)){ 
    return date($returnFormat,$workingDate); 
    } else { 
        return $workingDate; 
    } 
}