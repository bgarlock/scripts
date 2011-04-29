<?php
	// For help on using hooks, please refer to http://bigprof.com/appgini/help/working-with-generated-web-database-application/hooks

	function estimating_master_log_init(&$options, $memberInfo, &$args){
	
		return TRUE;
	}

	function estimating_master_log_header($contentType, $memberInfo, &$args){
		$header='';
	
		switch($contentType){
			case 'tableview':
				$header='';
				break;

			case 'detailview':
				$header='';
				break;

			case 'tableview+detailview':
				$header='';
				break;

			case 'print-tableview':
				$header='';
				break;

			case 'print-detailview':
				$header='';
				break;

			case 'filters':
				$header='';
				break;
		}

		return $header;
	}

	function estimating_master_log_footer($contentType, $memberInfo, &$args){
		$footer='';
	
		switch($contentType){
			case 'tableview':
				$footer='';
				break;

			case 'detailview':
				$footer='';
				break;

			case 'tableview+detailview':
				$footer='';
				break;

			case 'print-tableview':
				$footer='';
				break;

			case 'print-detailview':
				$footer='';
				break;

			case 'filters':
				$footer='';
				break;
		}

		return $footer;
	}

	function estimating_master_log_before_insert(&$data, $memberInfo, &$args){
		include("ProjectIncludes/IncludeCalculations.php");
		///////////////////////////////////////////////////////////////////////////////////
		// this function gets the accumulated time 
		// not counting weekends and holidays
		// function needs start & end date/time sent in an array
			$tmp_est_log_timeReceived = "$data[est_log_dateReceived] $data[est_log_timeReceived]";
			$tmp_est_log_timeCompleted = "$data[est_log_dateCompleted] $data[est_log_timeCompleted]";
			// 2010-02-17 jimb now a function to accumulate work days non-holidays
			$SendData = array($tmp_est_log_timeReceived,$tmp_est_log_timeCompleted);
			$tmp_est_log_turnTime = AccumulateTime($SendData);
			$data['est_log_turnTime'] = $tmp_est_log_turnTime;
		///////////////////////////////////////////////////////////////////////////////////
	
		return TRUE;
	}

	function estimating_master_log_after_insert($data, $memberInfo, &$args){
	
		return TRUE;
	}

	function estimating_master_log_before_update(&$data, $memberInfo, &$args){

		include("ProjectIncludes/IncludeCalculations.php");
		///////////////////////////////////////////////////////////////////////////////////
		// this function gets the accumulated time 
		// not counting weekends and holidays
		// function needs start & end date/time sent in an array
			$est_log_timeReceived = "$data[est_log_dateReceived] $data[est_log_timeReceived]";
			$est_log_timeCompleted = "$data[est_log_dateCompleted] $data[est_log_timeCompleted]";
			// 2010-02-17 jimb now a function to accumulate work days non-holidays
			$SendData = array($est_log_timeReceived,$est_log_timeCompleted);
			$est_log_turnTime = AccumulateTime($SendData);
			$data['est_log_turnTime'] = $est_log_turnTime;
		///////////////////////////////////////////////////////////////////////////////////

	
		return TRUE;
	}

	function estimating_master_log_after_update($data, $memberInfo, &$args){
	
		return TRUE;
	}

	function estimating_master_log_before_delete($selectedID, &$skipChecks, $memberInfo, &$args){
	
		return TRUE;
	}

	function estimating_master_log_after_delete($selectedID, $memberInfo, &$args){
	
	}

	function estimating_master_log_dv($selectedID, $memberInfo, &$html, &$args){
	
	}

	function estimating_master_log_csv($query, $memberInfo, $args){
	
		return $query;
	}