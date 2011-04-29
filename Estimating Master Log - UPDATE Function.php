
	// 2010-02-17 jimb saving posted variables for calculations
	$est_log_dateReceived = makeSafe($_POST['est_log_dateReceivedYear']) . '-' . makeSafe($_POST['est_log_dateReceivedMonth']) . '-' . makeSafe($_POST['est_log_dateReceivedDay']);
	$est_log_timeReceived = makeSafe($_POST['est_log_timeReceived']);
	$est_log_dateCompleted = makeSafe($_POST['est_log_dateCompletedYear']) . '-' . makeSafe($_POST['est_log_dateCompletedMonth']) . '-' . makeSafe($_POST['est_log_dateCompletedDay']);
	$est_log_timeCompleted = makeSafe($_POST['est_log_timeCompleted']);	

	///////////////////////////////////////////////////////////////////////////////////
	// this function gets the accumulated time 
	// not counting weekends and holidays
	// function needs start & end time sent in an array
	$est_log_timeReceived = "$est_log_dateReceived $est_log_timeReceived";
	$est_log_timeCompleted = "$est_log_dateCompleted $est_log_timeCompleted";
	// 2010-02-17 jimb now a function to accumulate work days non-holidays
	$SendData = array($est_log_timeReceived,$est_log_timeCompleted);
	$est_log_turnTime = AccumulateTime($SendData);
	///////////////////////////////////////////////////////////////////////////////////

