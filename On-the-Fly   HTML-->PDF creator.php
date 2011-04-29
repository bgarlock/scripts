<?php

/*  2010-03-18:  B. Garlock -- Finally a working on-the-fly PDF creator for any web page on our Intranet!
 *  
 *  This script will convert an HTML page to a PDF on-the-fly, simply by  placing a link on the resulting .PHP or .HTML file
 *  and passing that to the convertme.php script.
 *  HTMLDOC 'htmldoc' does all the heavy lifting.  See the manpage for more information
 *
 *
 *  Gottcha's:  Make sure your HTML is VALID HTML!  CSS Stylesheets not currently supported.
 *
 *  All the thanks in the world to http://www.easysw.com for their HTMLDOC software!!
 *
*/

// function will check the referer page, pass the url, and name the PDF as the referer page.  We flush(), so PHP doesn't
// complain about headers already being sent!
function topdf($filename, $options = "") { 
    global $referer; 
    // Write the content type to the client... 
    header("Content-Type: application/pdf"); 
    header("Content-Disposition: inline; filename=\"{$referer[3]}.pdf\""); 
    flush(); 

    // Run HTMLDOC to provide the PDF file to the user... 
    // Use the --no-localfiles option for enhanced security!
    // Currently NO HEADER OR FOOTER, but HTMLDOC certainly supports them! 
    passthru("htmldoc --no-localfiles --no-compression -t pdf --header ... --footer ... --quiet --jpeg --webpage $options $filename"); 
} 

if ( isset( $_SERVER['HTTP_REFERER'] ) ) { 
    $referer = explode( "/" , $_SERVER['HTTP_REFERER'] ); 

    if ( $referer[2] != $_SERVER['HTTP_HOST'] ) { 
        // Linked from another host 
        echo "I won't make a pdf for you because you linked from somewhere else."; 
        } else { 
            topdf( $_SERVER['HTTP_REFERER'] ); 
    } 

    } else { 

}    
header("Location: /"); 
?> 