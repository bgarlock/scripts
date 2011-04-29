/*
this class will backup mysql database and export to .sql file
*/

<?PHP
/************************************************************************/
/* Backup My SQL Database with PHP                                      */
/* =============================================                        */
/*                                                                      */
/* Author: Noor Ahmad Feroozi                                           */
/* http://dreamincode.net                                               */
/*                                                                      */
/* Last Updated: 03-11-2009                                             */
/************************************************************************/

class backup{   
        // private variables which can be access after creating a new object of this class
        // and it is access able to objects of this class such as functions
        // Server or Host name
        private $host;  
        // Server Username
        private $user;  
        // Server Username's Password
        private $pass;  
        // Database name for backing up
        private $db;    
        // Backup string
        private $str;
        
        // constructor methods for classes when creating new object of this class
        function __construct($host,$user,$pass,$db){
                // check if variables are avilable and not empty, and add to private variables
                if((isset($host) && $host != "") || (isset($user) && $user != "") || (isset($pass) && $pass != "") || (isset($db) && $db != "")){
       $this->host = $host;
           $this->user = $user;
           $this->pass = $pass;
           $this->db   = $db;
           // Call function for connecting to server and to database
           $this->connection();
           }
   }
   
        // function for connection
        function connection(){
                // connect to mysql database using private variables
                $con = mysql_connect($this->host,$this->user,$this->pass)or die(mysql_error());
                // if connection faild than print error message
                if(!$con)
                        die("Error connecting to server: ".mysql_error());
                // select or connect to database
                $db  = mysql_select_db($this->db)or die(mysql_error());
                // if not connected to database than print error message
                if(!$db)
                        die(mysql_error());
                
                // return true if connected to server and database
                return true;
        } 
        
        // Get tables information such as Fields, Null Values, Default Values, Keys, Extra and etc...
        function get_table_info($tblname){
                // table name
                $tbl = $tblname;
                // String variable for storing table information
                $str = "";
                
                $str.="-- ---------------------------------\n\n--\n--Creating table `$tbl`\n--\n\n";
                
                // query for creating table
                $str .="CREATE TABLE IF NOT EXISTS $tbl (\n";
                // string query for getting fields from table
                $str_fields = "SHOW FIELDS FROM $tbl";
                // executing query
                $fields = mysql_query($str_fields)or die(mysql_error());
                // array for storing keys of fields
                $keys_str = array();
                // getting fields from table
                while($fetch = mysql_fetch_assoc($fields))
                {
                        // adding field name and field type
                        $str .="`".$fetch['Field']."` ".$fetch['Type']." ";
                        // if Null property is not yes or Null property is no
                        if($fetch['Null'] != "YES"){
                                // add NOT NULL
                                $str .= " NOT NULL ";
                        }
                        // if default value is assigned or default value is not empty then add default value
                        if((isset($fetch['Default']) && (!empty($fetch['Default'])) || ($fetch['Default'] == "0")))
                                $str .= "DEFAULT '".$fetch['Default']."' ";             
                        // if Extra property is not empty
                        if($fetch['Extra'] != ""){
                                // then change to upper case and add Extra property 
                                // You can remove strtoupper if you don't want to change it to upper case
                                $str .= " ".strtoupper($fetch['Extra']);
                        }
                        // check for keys
                        if($fetch['Key']=="PRI")
                                $keys_str[] .="PRIMARY KEY (`".$fetch['Field']."`)";
                        if($fetch['Key']=="UNI")
                                $keys_str[] .="UNIQUE KEY (`".$fetch['Field']."`)";
                        //add coma separator after each field
                        $str .=",\n";
                }
                        // run loop on keys (array) variable and add to str
                        for($i=0;$i<(count($keys_str));$i++){
                                $str.=$keys_str[$i];
                                // if it is not end of keys then add coma
                                if($i<(count($keys_str)-1)){
                                        $str .=",";
                                }
                                $str.="\n";
                        }
                        // end table creation query
                        $str .=")";
                        
                        // query for getting AUTO_INCREMENT nuber
                        $auto_query = mysql_query("SELECT COUNT(*)+1 AS `Auto` FROM $tbl")or die(mysql_error());
                        $auto_fetch = mysql_fetch_assoc($auto_query);
                        $auto = $auto_fetch['Auto'];
                        $str .="ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=$auto ;\n\n";
                        //create database
                        $str.="--\n-- Inserting data into table `$tbl`\n--\n\n";
                        $this->str .=$str;
        }
        
        // get table contents
        function get_table_content($table){
                // array variable for storing fields name
                $field = array();
                // string variable for storing table content
                $str = "";
                //execute query
                $con_query = mysql_query("SELECT * FROM $table")or die(mysql_error());
                // get row numbers of table
                $rows = mysql_num_rows($con_query);
                // inisalize a variable and assing 0 value;
                $r=0;
                // if records found in table then get all data
                if($rows>0){
                        // get fields from query
                        while($fields = mysql_fetch_field($con_query)){
                                // add field name to field variable
                                $field[] .= $fields->name;
                        }
                        // insert query for table
                        $str .="INSERT INTO `$table` (";
                        // append table fields into string query
                        for($i=0;$i<=(count($field)-1);$i++){
                                $str .= "`".$field[$i]."`";
                                // if current is not last field then add coma
                                if($i<(count($field)-1)){
                                        $str .=",";
                                }
                        }
                        // add values
                        $str .=") VALUES \n";
                        // get result from query
                        while($fetch = mysql_fetch_assoc($con_query)){
                                $str .= "(";
                                // run loop on fields variable, get data and add to $str
                                for($i=0;$i<=(count($field)-1);$i++){
                                        // add escap caracher "\" for sql injection
                                        $str .= "'".addslashes($fetch[$field[$i]])."'";
                                        if($i<(count($field)-1)){
                                                $str .=",";
                                        }
                                }
                                $str .=")";
                                if($r<$rows -1){
                                        $str .=",";
                                }else{
                                        $str .=";";
                                }
                                $r++;
                                $str .="\n";
                        }
                                $str .="\n\n";
                        
                        $this->str .=$str;
                }
        }
        
        // function for getting tables from database and table information from get_table_info function
        function get_tables(){
                // get all tables from database
                $tables = mysql_query("SHOW TABLES FROM ".$this->db)or die(mysql_error());
                // checking for table(s) in database if found then execute the code
                if(mysql_num_rows($tables)>0){
                        //if table(s) found then get tables name from database
                        while($tables_fetch = mysql_fetch_assoc($tables)){
                                $table = $tables_fetch["Tables_in_".$this->db];
                                // and then get table information
                                $this->get_table_info($table);
                                $this->get_table_content($table);
                        }
                }else{
                        // print error message if no table(s) found
                        die("No table found in database: ".$this->db);
                }
        }
        
        // function for executing executing backup
        function DoBackup(){
                // for slow connection or  for larg My SQL injection
                ini_set("max_execution_time","1000");
                $this->str .= $this->Extra()."\n\n";
                // get tables informtaion from tables
                $this->get_tables();
                echo $this->str;
                // create .sql file for backup
                $this->create_file();
        }
        
        // function for creating and downloading file from we page (every thing will print from page)
        function create_file(){
                header("Content-disposition: filename=".$this->db.".sql");
                header("Content-type: application/octetstream");
                header("Pragma: no-cache");
                header("Expires: 0");
        }
        
        function Extra(){
                $str = "";
                $str = "-- Author:  Noor Ahmad Feroozi\n";
                $str.= "-- Last Updated: 03-Nov-2009\n\n\n";
                $str.= "-- Host: ".$_SERVER['HTTP_HOST']."\n";          
                $str.= "-- PHP Version".phpversion()."\n";
                $str.= "-- Database: ".$this->db."\n";
                $str.= "-- Creation Time: ".date('Y-M-d')." at ".date('H:i:s')."\n\n";  
                $str.='SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";'."\n\n";
                $str.= "--\n--Database: `".$this->db."`\n--\n\n";
                $str.="CREATE DATABASE IF NOT EXISTS `".$this->db."`;\n";
                return $str;
        }
}
// Using of backup class
// create new obje of backup class
$obj = new backup("localhost","root","","mydb");
// run backup query
$str = $obj->DoBackup();
?>