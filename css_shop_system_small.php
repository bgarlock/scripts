<?php


//  NOTE:  B Garlock, 06-15-06: Changed the PRE/CODE CSS from Courier New to Courier, since most people do not have Courier New
//  installed, and if they did, the print was very light with that font.  Courier is much easier to read.

function css_site() {

    //determine font for this platform
    if (browser_is_windows() && browser_is_ie()) {

        //ie needs smaller fonts
        $font_size='xx-small';
        $font_smaller='xx-small';
        $font_smallest='8pt';

    } else if (browser_is_windows()) {

        //netscape on wintel
        $font_size='small';
        $font_smaller='x-small';
        $font_smallest='x-small';

    } else if (browser_is_mac()){

        //mac users need bigger fonts
        $font_size='medium';
        $font_smaller='small';
        $font_smallest='x-small';

    } else {

        //linux and other users
        $font_size='small';
        $font_smaller='x-small';
        $font_smallest='x-small';

    }

    $site_fonts='verdana, arial, helvetica, sans-serif';
}
?>