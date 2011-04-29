<?php
/* Number of comments to display for each employee */

                                        $con_rows = mysql_connect("$host_linux", "$user_linux", "$pw_linux") or die("couldn't connect TO  DATABASE $db_shop for $tb_employee." .mysql_error()."");
	                                    $db_rows= mysql_select_db("$db_shop", $con_rows);
	                                    $sql_rows = ("SELECT  *
	                                             FROM   $tb_employee, $tb_comments
	                                             WHERE  comments.cmts_emp_id = $emp_id
	                                               AND  employee.emp_id = comments.cmts_emp_id         
	                                          ORDER BY  cmts_date  DESC 
	                                           ");
	                                    $result_rows = mysql_query($sql_rows,$con_rows);
	                                    $rows = mysql_num_rows($result_rows);
	                                   
	                                   ?>