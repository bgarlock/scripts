/*
Basic PHP FIle Uploader
*/

<?php
$upload_directory = './';
$reserved = array('.', '..');
$errors = array();

//
// Upload
//
if (isset($_POST['upload']))
{
  $upload_directory .= (!ereg('/$', $upload_directory)) ? '/' : '';
  $filename = $_FILES['upload_file']['name'];
  $target_file = $upload_directory . $filename;

  if (!isset($_POST['upload_overwrite']))
  {
    if (!in_array($filename, $reserved))
    {
      if (!file_exists($target_file))
      {
        if (!move_uploaded_file($_FILES['upload_file']['tmp_name'], $target_file))
        {
          $errors[] = sprintf('Please try uploading %s again.', $filename);
        }
      }
      else
      {
        $errors[] = sprintf('%s already exists!', $filename);
      }
    }
    else
    {
      $errors[] = 'That filename is reserved.';
    }
  }
  else
  {
    if (!in_array($filename, $reserved))
    {
      if (!move_uploaded_file($_FILES['upload_file']['tmp_name'], $target_file))
      {
        $errors[] = 'Please try again.';
      }
    }
    else
    {
      $errors[] = 'That filename is reserved.';
    }
  }

  if (empty($errors))
  {
    echo 'File Uploaded Successfully!<br />';
  }
  else
  {
    foreach ($errors as $error)
    {
      echo "<b>$error</b><br />\n";
    }
  }
}
?>
<br /><form enctype="multipart/form-data" method="post">
<input type="file" name="upload_file" size="20">
<input type="submit" name="upload" value="Upload">
<br /><span style="font-size:12px">Overwrite? <input type="checkbox" name="upload_overwrite"></span>
</form>