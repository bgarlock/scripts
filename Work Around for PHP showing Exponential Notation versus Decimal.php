// example: one of the "special" ones, prints in exponential notation, 
// "1.4E+6"

$num = 1400000.; 

if(strstr($num, 'E')) {
    echo "yep, exp notation<br>";
    list($significand, $exp) = explode('E', $num);
    list($void, $decimal) = explode('.', "$significand");
    $decimal_len = strlen("$decimal");
    $exp = str_replace('+', '', "$exp");
    $exp -= $decimal_len;
    $append = '';
    for($i = 1; $i <= $exp; $i++) {
        $append .= '0';
    }
    $tmp = str_replace('.', '', "$significand");
    $reconsctructed = "$tmp" . "$append";
    echo '<pre>reconstructed: ', "$reconsctructed", '</pre>';
}
