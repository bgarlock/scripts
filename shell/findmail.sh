#!/usr/bin/perl

# USAGE: findmail [regexp] < mailfile
#     Searches From/To/Subject/Date for [regexp]
# 1.00 erco@3dsite.com

$search = $ARGV[0];

# READ ALL LINES FROM MAIL FILE ON STDIN
while ( <STDIN> )
{
    # PARSING A MAIL HEADER?
    if ( $header )
    {
	if ( /^Date: / ) 		{ $date   = $_; }
	if ( /^To: /  ) 		{ $to     = $_; }
	if ( /^From: /  ) 		{ $from2  = $_; }
	if ( /^Date:/ ) 		{ $date   = $_; }
	if ( /^Subject:/ ) 		{ $subject= $_; }

	# END OF MAIL HEADER?
	if ( /^$/ )                    
	{
	    $header = 0;

	    # HANDLE SEARCH MATCHING
	    #     On match, print the (abbreviated) buffered email header info
	    #
	    if ( $from    =~ m/$search/ ||
		 $from2   =~ m/$search/ ||
		 $date    =~ m/$search/ ||
		 $to      =~ m/$search/ ||
		 $subject =~ m/$search/ ) 
		 { $flag = 1; printf("\n%s%s%s%s%s",$from,$from2,$to,$date,$subject); }
	}
    }
    else
	# START OF NEW MAIL HEADER?
        { if ( /^From / ) { $from = $_; $header = 1; $flag = 0; } }

    # PRINT REST OF MESSAGE IF THERE WAS A MATCH
    if ( $flag ) { print $_; }
}

