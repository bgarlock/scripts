/*
A simple function to go through a file and replace text.
*/

<?php
/****************************
*   PHP Replace Function    *
*    Written By Moonbat     *
*       July 24, 2008       *
****************************/

function Replace($file, $char, $replace)
{
	$stuff = file_get_contents($file); // Get the file's contents
	$stuff = str_replace($char, $replace, $stuff); // Make the change
	unlink($file); // Delete the file
	$text = fopen($file, "a+"); // Since file doesn't exist, it will be recreated
	fwrite($text, $stuff); // Put the old contents in the new file
	fclose($text); // Close the file
}

?>