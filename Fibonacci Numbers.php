<?php
$first = 0;
$second = 1;
$n =20;
print $first.'<br>';
for($i=1;$i<=$n-1;$i++)
   {
   $final = $first + $second;
   $first = $second;
   $second = $final;
   print $final.'<br>';
   }
?>