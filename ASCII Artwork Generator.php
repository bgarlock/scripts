<?php
     $filename = $_POST['file'];

     $image = file_get_contents($filename);

     $image = imagecreatefromstring($image);

     $width = imagesx($image);
     $height = imagesy($image);

     $m_aspect = 164.0 / 48.0;
     $i_aspect = $width / $height;

     if($i_aspect < $m_aspect)
     {
          $percent = 48.0 / $height;
          $new_height = $height * $percent;
          $new_width = 11.875 * $new_height / 6.0 * $width / $height;
     }
     else
     {
          $percent = 164.0 / $width;
          $new_width = $width * $percent;
          $new_height = 6.0 * $new_width / 11.875 * $height / $width;
     }

     $image_p = imagecreatetruecolor($new_width, $new_height);
     imagecopyresampled($image_p, $image, 0, 0, 0, 0, $new_width, $new_height, $width, $height);

     for($i = 0; $i < $new_height; $i++)
     {
          $rgb = ImageColorAt($image_p, 0, $i);                              // OPTIMIZED
          $r = dechex(($rgb >> 16) & 0xFF);                              // OPTIMIZED
          $g = dechex(($rgb >> 8) & 0xFF);                              // OPTIMIZED
          $b = dechex($rgb & 0xFF);                                   // OPTIMIZED
          echo '<font color="#' . $r . $g . $b . '">' . strtoupper(dechex(rand(0, 15)));     // OPTIMIZED
          for($j = 1; $j < $new_width; $j++)
          {
               $rgb = ImageColorAt($image_p, $j, $i);
               $r = dechex(($rgb >> 16) & 0xFF);
               $g = dechex(($rgb >> 8) & 0xFF);
               $b = dechex($rgb & 0xFF);
               if(strlen($r) < 2)
               {
                    $r = '0' . $r;
               }
               if(strlen($g) < 2)
               {
                    $g = '0' . $g;
               }
               if(strlen($b) < 2)
               {
                    $b = '0' . $b;
               }
// NO OPTIMIZATION     echo '<font color="#' . $r . $g . $b . '">' . strtoupper(dechex(rand(0, 15))) . '</font>';
               if($rgb != ImageColorAt($image_p, $j - 1, $i))                    // OPTIMIZED
               {                                             // OPTIMIZED
                    echo '</font><font color="#' . $r . $g . $b . '">';          // OPTIMIZED
               }                                             // OPTIMIZED
               echo strtoupper(dechex(rand(0, 15)));                         // OPTIMIZED
          }                                                  // OPTIMIZED
          echo '</font>';                                             // OPTIMIZED
          echo '<br>' . "\n\n";
     }

     imagedestroy($image);
     imagedestroy($image_p);
?>