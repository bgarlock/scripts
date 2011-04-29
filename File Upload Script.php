/*
File upload with PHP
This is a snippet for a simple file upload. It has limitations for the file types and file size (change these to fit your needs)
*/

<?php
    	//pick your valid file types
      $valid_extensions = array('.jpg','.gif','.bmp','.png');	//change to the file types you wish to allow
      
      //set the maximum file size
      $max_size = 1024000;	//change to the size you wish (currently set to 1MB)
      
      //get the size of the file
      $file_size = filesize($_FILES['UploadFile']['size']);
      
      //set the upload directory
      $directory = './images/';	//change to your upload directory
 
 	  //get the name of the file
	   $upload_file = $_FILES['UploadFile']['name'];
	   
	   //get the files extension
	   $file_extension = substr(strrchr($upload_file, '.'), 1);
	 
	   // make sure we have a valid file type
	   if(!in_array($file_extension, $valid_extensions))
	   {
	      die('Error uploading file: Invalid file type, valid types are: ' . strtoupper($valid_extensions));
	   }
	 
	   //make sure we arent over our pre-set file size
	   if($file_size > $max_size)
	   {
	      die('Error uploading file: File size too large, limit size to ' . round(abs($max_size / 1024) . 'MB');
	   }
	 
	   //make sure we have valid permissions to upload to this directory
	   if(!is_writable($directory))
	   {
	      die('Error uploading file: Invalid Permissions');
	   }
	 
	   //we passed all validation, now upload the file
	   if(move_uploaded_file($_FILES['UploadFile']['tmp_name'], $directory . $upload_file))
	   {
	      echo $upload_file . ' uploaded successfully';
	   }
     	else
     	{
      	  echo 'There was an error during the file upload: ' . $_FILES['UploadFile']['error']; 
     	}
?>

		