#!/usr/bin/perl -w

#
# hosts2dns -- Convert /etc/hosts file to DNS 
#
#   Version 0.93
#   Copyright (C) 2006 Greg Ercolano
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation; either version 2 of
#   the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
#   02111-1307 USA
#
#   Please report bugs to erco@3dsite.com -- you /must/ include
#   the words 'hosts2dns bug report' in the Subject: of your message.
#
use Net::hostent;	# gethost()..
use Sys::Hostname;	# hostname()..
use Socket;		# inet_ntoa()..

# GLOBALS
$G::domain = undef;
$G::bindver = undef;
$G::network = undef;
$G::networkrev = undef;

# RETURN THE CURRENT MACHINE'S HOSTNAME
#    Returns only the hostname part.
#
sub GetHostname()
{
    my $hostname = hostname();
    $hostname =~ s/\..*//;
    return($hostname);
}

# RETURN IP ADDRESS FOR HOSTNAME
#   TBD: error checking
#
sub Hostname2IP($)
{
    my ($hostname) = @_;
    my $he = gethost($hostname);
    return(inet_ntoa($he->addr));
}

# RETURN THIS MACHINE'S NETWORK NUMBER
#    TBD: We currently don't handle bitwise subnets.
#         Assumes network number is first three digits.
#
sub GetNetworkIPFwd()
{
    my $hostname = GetHostname();
    my $ip = Hostname2IP($hostname);
    return($ip);
}

# RETURN OUR NETWORK NUMBER IN REVERSE DOT NOTATION
#    TBD: We currently don't handle bitwise subnets.
#         Assumes network number is first three digits.
#
sub GetNetworkIPRev()
{
    my $fwd = GetNetworkIPFwd();
    if ( $fwd =~ /(\d+).(\d+).(\d+)/ ) {
        return($3.".".$2.".".$1);
    } else {
        print STDERR \
	    "$0: GetNetworkIPRev(): can't parse network number from '$fwd'\n";
	exit(1);
    }
}

# SEE IF IP IS A VALID 4 DIGIT IP ADDRESS
#     Returns 1 if ok, 0 on error ($2 has reason)
#     $1 - ip address to check
#     $2 - REFERENCE: returned error message string, if any
#
sub ValidIP($$)
{
    my ($ip, $errmsg) = @_;
    # EXPECT FOUR INTEGERS
    if ( $ip =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/ ) {
        # RANGE CHECK ALL FOUR DIGITS
        foreach ($1,$2,$3,$4) {
	    if ( $_ < 0 || $_ > 255 ) {
		$$errmsg = "'$ip': field '$_' is out of range 0 - 255";
		return(0);
	    }
	}
	return(1);
    }
    $$errmsg = "'$ip' is not a valid IP4 IP address (expected eg. '111.222.333.444')";
    return(0);
}

# CHECK HOSTNAME FOR RFC 1035 2.3.1 COMPLIANCE
#     Returns 1 if ok, 0 on error ($2 has reason)
#     $1 - hostname to check
#     $2 - REFERENCE: returned error message string, if any
#
sub ValidHostname($$)
{
    my ($hostname, $errmsg) = @_;
    # VALID CHAR CHECK
    if ( $hostname !~ /^[A-Za-z0-9-]*$/ ) {	# only chars allowed in a hostname
        $$errmsg = "'$hostname': DNS hostnames /must/ only contain letters, digits and hyphens ".
	           "(A-Z, a-z, 0-9 and '-')";
	return(0);
    }
    # MUST START WITH ALPHA
    if ( $hostname !~ /^[A-Za-z]/ ) {		# hostname must start with alphas
        $$errmsg = "'$hostname': DNS hostnames /must/ start with a letter";
	return(0);
    }
    # MUST END WITH ALPHA/NUM
    if ( $hostname !~ /[A-Za-z0-9]$/ ) {	# hostname must end with alpha/num
        $$errmsg = "'$hostname': DNS hostnames /must/ end with a letter or digit";
	return(0);
    }
    return(1);
}

# CHECK IF THIS HOSTNAME IS ALREADY LISTED IN THE $$hosts{} HASH
#     Returns 1 if OK, 0 on error ($2 has reason)
#     $1 - hostname to check
#     $2 - ip address of hostname being checked
#     $3 - REFERENCE to $hosts hash
#     $4 - REFERENCE to returned error message string, if any
#
sub DuplicateHostCheck($$$$)
{
    my ($hostname, $ip, $hosts, $errmsg) = @_;
    $hostname = "\L$hostname";				# downcase

    # CHECK ALL ENTRIES IN $$hosts{}
    foreach my $checkip ( keys ( %{ $$hosts{host} } ) ) {

	# CHECK HOSTNAME AGAINST OFFICIAL NAME
        my $checkhostname = "\L$$hosts{host}{$checkip}{host}";	# downcase
	if ( $hostname eq $checkhostname ) {
	    my $checkline = $$hosts{host}{$checkip}{line};
	    $$errmsg = "hostname '$hostname' [$ip] already defined ".
	               "on Line $checkline: '$checkhostname' [$checkip]";
	    return(0);
	}

	# CHECK HOSTNAME AGAINST ALIASES
	foreach my $alias ( @{ $$hosts{host}{$checkip}{aliases} } ) {
	    $alias = "\L$alias";			# downcase
	    if ( $hostname eq $alias ) {
		my $checkline = $$hosts{host}{$checkip}{line};
		$$errmsg = "hostname '$hostname' [$ip] matches alias already defined ".
		           "on Line $checkline: '$checkhostname' [$checkip]";
		return(0);
	    }
	}
    }
    return(1);
}

# RETURN THE CURRENT DOMAIN NAME
#    On error, prints error to stderr and exits program.
#
sub GetDomain()
{
    if ( ! defined($G::domain) ) {
        print STDERR "$0: \$G::domain not defined!\n";
	exit(1);
    }
    return($G::domain);
}

# RETURN CURRENT MACHINE'S FQDN, BASED ON CURRENT DOMAIN
sub GetFQDNHostname()
{
    return(GetHostname().".".GetDomain());
}

# LOAD INFO FROM /etc/hosts FILE
#    On error, prints error to stderr and exits program.
#    $1 - pathname to /etc/hosts file
#    $2 - REFERENCE: $host hash
#
sub LoadHosts($$)
{
    my ($hostsfile, $hosts) = @_;
    unless ( open(HOSTS, "<$hostsfile") ) {
        print STDERR "$0: $hostsfile: $!\n";
	exit(1);
    }

    # DEFAULTS
    $$hosts{conf}    = "/etc/named.conf";
    $$hosts{zonedir} = "/var/named";

    my ($loadhosts,$line) = (0,0);
    while (<HOSTS>) {
        $line++;
        chomp($_);
	if ( /^#!DNS:DOMAIN[\s]*(\S+)/ ) {	# parse domain name
	    $$hosts{domain} = $1;
	    $G::domain = $1;
	    $$hosts{dnsserver}{host} = GetHostname();
	    $$hosts{dnsserver}{fqdn} = GetFQDNHostname();
	    next;
	} elsif ( /^#!DNS:CONF[\s]*(\S+)/ ) {	# parse conf filename
	    $$hosts{conf} = $1;
	    next;
	} elsif ( /^#!DNS:ZONEDIR[\s]*(\S+)/ ) {	# parse zonedir
	    $$hosts{zonedir} = $1;
	    next;
	} elsif ( /^#!DNS:START/ ) {		# start
	    $loadhosts = 1;
	    next;
	} elsif ( /^#!DNS:END/ ) {		# end
	    $loadhosts = 0;
	    next;
	} elsif ( /^#!DNS/ ) {			# fail on all unknown commands
	    print STDERR "$0: $hostsfile (Line $line): unknown command '$_'\n";
	    exit(1);
	} elsif ( /^#/ | /^[\s]$/ ) {		# ignore comments and empty lines
	    next;
	}
	if ( $loadhosts ) {			# parse hostnames
	    # PARSE HOST ENTRY FOR IP/HOST/ALIASES
	    my @fields   = split();
	    my $ip       = shift(@fields);
	    my $hostname = shift(@fields); $hostname =~ s/\..*//;	# host.foo.com -> host
	    my @aliases  = @fields;

	    # TRIM FQDN'S
	    #    Sometimes entries in /etc/hosts like to have FQDN aliases
	    #    to get daemons like apache to resolve on boot. Trim off
	    #    the domain part before putting the entries into DNS.
	    #
	    for ( my $i=0; $i <= $#aliases; $i++ ) {
	        $aliases[$i] =~ s/\..*//;			# host.foo.com -> host
	    }

	    # Sanity checks
	    my $errmsg;
	    if ( ! defined($ip) ) {
	        print STDERR \
		      "$0: $hostsfile (Line $line): NO IP ADDRESS SPECIFIED\n";
		exit(1);
	    } elsif ( ! defined($hostname) ) {
	        print STDERR \
		      "$0: $hostsfile (Line $line): NO HOSTNAME SPECIFIED\n";
		exit(1);
	    } elsif ( ! ValidIP($ip, \$errmsg) ) {
	        print STDERR "$0: $hostsfile (Line $line): $errmsg\n";
		exit(1);
	    } elsif ( ! ValidHostname($hostname, \$errmsg) ) {
	        print STDERR "$0: $hostsfile (Line $line): $errmsg\n";
		exit(1);
	    }
	    my $host;
	    foreach $host ( @aliases ) {
	        # CHECK EACH ALIAS FOR VALIDITY
		if ( ! ValidHostname($host, \$errmsg) ) {
		    print STDERR "$0: $hostsfile (Line $line): $errmsg\n";
		    exit(1);
		}
	        # CHECK EACH ALIAS FOR DUPES
		if ( ! DuplicateHostCheck($host, $ip, $hosts, \$errmsg) ) {
		    print STDERR "$0: $hostsfile (Line $line): $errmsg\n";
		    exit(1);
		}
	    }

	    # Is this entry a dupe?
	    if ( defined ( $$hosts{host}{$ip}{hostname} ) ) {
	        my $firstline = $$hosts{host}{$ip}{line};
		print STDERR "$0: $hostsfile (Line $line): ".
		             "DUPLICATE ENTRY FOR IP $ip (first definition ".
			     "at line $firstline)\n";
		exit(1);
	    }

	    # Check for duplicate hostnames or aliases
	    if ( ! DuplicateHostCheck($hostname, $ip, $hosts, \$errmsg) ) {
		print STDERR "$0: $hostsfile (Line $line): $errmsg\n";
		exit(1);
	    }

	    # Save valid entry
	    $$hosts{host}{$ip}{host} = $hostname;	# save official name
	    $$hosts{host}{$ip}{fqdn} = $hostname.".".$$hosts{domain};

	    # save aliases (if any)
	    @{$$hosts{host}{$ip}{aliases}} = @aliases;

	    # keep track of what line in hosts file entry came from
	    $$hosts{host}{$ip}{line} = $line;
	}
    }
    close(HOSTS);

    # CHECK FOR UNDEF'S
    my $error = 0;
    if ( ! defined($$hosts{domain}) ) {
        print STDERR "$0: $hostsfile: missing '#!DNS:DOMAIN <your.domain>'\n";
	$error++;
    }
    if ( ! defined($$hosts{conf}) ) {
        print STDERR \
	      "$0: $hostsfile: missing '#!DNS:CONF <path_to_named.conf>'\n";
	$error++;
    }
    if ( ! defined($$hosts{zonedir}) ) {
        print STDERR \
	      "$0: $hostsfile: missing '#!DNS:ZONEDIR <path_to_zone_dir>'\n";
	$error++;
    }
    if ( $error ) {
        exit(1);
    }

    # IS NAMED SETUP IN A chroot JAIL?
    #    Create symlinks to chroot subdir; this is how Fedora Core 3 wants it
    #
    if ( -d "/var/named/chroot/var/named" ) {
        foreach ( "named.ca", 
	          "fwd.$$hosts{domain}",
	          "rev.$$hosts{domain}",
	          "rev.localhost" ) {
	    if ( ! -l "$$hosts{zonedir}/$_" ) {
		unlink("$$hosts{zonedir}/$_");
		system("ln -s $$hosts{zonedir}/chroot/$$hosts{zonedir}/$_ $$hosts{zonedir}/$_");
	    }
	}
	if ( ! -l $$hosts{conf} ) {
	    unlink("$$hosts{conf}");
	    system("ln -s $$hosts{zonedir}/chroot/etc/named.conf $$hosts{conf}");
	}
    }
}

# PRINT ALL THE HOSTS IN THE $hosts{} HASH
#    $1 - REFERENCE: $hosts hash
#
sub PrintHosts($)
{
    my ($hosts) = @_;
    print <<"EOF";
-------------------------
 Domain: $$hosts{domain}
   Conf: $$hosts{conf}
Zonedir: $$hosts{zonedir}
-------------------------
EOF
    my $ip;
    foreach $ip ( sort( keys ( %{ $$hosts{host} } ) ) ) {
        print "Hostname: $$hosts{host}{$ip}{host}\n".
	      "    FQDN: $$hosts{host}{$ip}{fqdn}\n".
	      "      IP: $ip\n";
	if ( defined($$hosts{host}{$ip}{aliases} ) ) {
	    print " Aliases: ".join(",",@{ $$hosts{host}{$ip}{aliases} })."\n";
	}
	print "\n";
    }
}

# SAVE OUT THE ROOT CACHE
#    On error, prints error to stderr and exits program.
#    $1 - filename to write to
#
#    TODO: Currently only saves out a static file.
#          Assume local machine is able to access internet via IP addresses
#          (since DNS likely isn't working yet); call dig(1) with various
#          root server ips until successful, otherwise fallback to static file.
#
sub SaveRootCache($)
{
    my ($filename) = @_;
    unless( open(OUT, ">$filename") ) {
        print STDERR "$0: $filename: $!\n";
	exit(1);
    }
    print OUT <<"EOF";
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; named.ca -- root domain servers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; *** THIS FILE AUTOMATICALLY GENERATED BY $0
; *** Do not edit this file by hand; changes will be overwritten!
;
.                        3600000  IN  NS    A.ROOT-SERVERS.NET.
A.ROOT-SERVERS.NET.      3600000      A     198.41.0.4
.                        3600000      NS    B.ROOT-SERVERS.NET.
B.ROOT-SERVERS.NET.      3600000      A     128.9.0.107
.                        3600000      NS    C.ROOT-SERVERS.NET.
C.ROOT-SERVERS.NET.      3600000      A     192.33.4.12
.                        3600000      NS    D.ROOT-SERVERS.NET.
D.ROOT-SERVERS.NET.      3600000      A     128.8.10.90
.                        3600000      NS    E.ROOT-SERVERS.NET.
E.ROOT-SERVERS.NET.      3600000      A     192.203.230.10
.                        3600000      NS    F.ROOT-SERVERS.NET.
F.ROOT-SERVERS.NET.      3600000      A     192.5.5.241
.                        3600000      NS    G.ROOT-SERVERS.NET.
G.ROOT-SERVERS.NET.      3600000      A     192.112.36.4
.                        3600000      NS    H.ROOT-SERVERS.NET.
H.ROOT-SERVERS.NET.      3600000      A     128.63.2.53
.                        3600000      NS    I.ROOT-SERVERS.NET.
I.ROOT-SERVERS.NET.      3600000      A     192.36.148.17
.                        3600000      NS    J.ROOT-SERVERS.NET.
J.ROOT-SERVERS.NET.      3600000      A     192.58.128.30
.                        3600000      NS    K.ROOT-SERVERS.NET.
K.ROOT-SERVERS.NET.      3600000      A     193.0.14.129 
.                        3600000      NS    L.ROOT-SERVERS.NET.
L.ROOT-SERVERS.NET.      3600000      A     198.32.64.12
.                        3600000      NS    M.ROOT-SERVERS.NET.
M.ROOT-SERVERS.NET.      3600000      A     202.12.27.33
EOF
    close(OUT);
}

# SAVE THE REVERSE ZONE FILE FOR "LOCALHOST"
#    On error, prints error to stderr and exits program.
#    $1 - filename of zone file to write out
#    $2 - REFERENCE: $hosts hash
#
sub SaveLocalReverse($$)
{
    my ($filename, $hosts) = @_;
    my $serial = time();
    my $dnsfqdn = $$hosts{dnsserver}{fqdn};
    my $domain = $$hosts{domain};
    my $adminmail = "root.$$hosts{domain}";	# root.foo.com == root@foo.com
    unless( open(OUT, ">$filename") ) {
        print STDERR "$0: $filename: $!\n";
	exit(1);
    }
    printf(OUT 
        ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n".
        ";;; rev.localhost -- Reverse Zone File for localhost\n".
        ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n".
	";\n".
        "; *** THIS FILE AUTOMATICALLY GENERATED BY $0\n".
        "; *** Do not edit this file by hand; changes will be overwritten!\n".
	"\n".
        "\$TTL 86400\n".
	"\@ IN SOA ${dnsfqdn}. ${adminmail}. (\n".
	"                 %-16s  ; Serial\n".
	"                 %-16s  ; Refresh\n".
	"                 %-16s  ; Retry\n".
	"                 %-16s  ; Expire\n".
	"                 %-16s) ; Minimum TTL\n".
	"\n",
	          $serial,	# Serial
		  "8H",		# Refresh
		  "2H",		# Retry
		  "1W",		# Expire
		  "6H");	# Minimum TTL

    # NAMESERVER/LOCALHOST ENTRIES
    printf(OUT "%-16s NS\t%s\n", "", ${dnsfqdn});
    printf(OUT "%-16s PTR\tlocalhost.\n", "1");
    close(OUT);
}

# SAVE THE FORWARD ZONE FILE FOR THE DOMAIN
#    On error, prints error to stderr and exits program.
#    $1 - filename of zone file to write out
#    $2 - REFERENCE: $hosts hash
#
sub SaveDomainForward($$)
{
    my ($filename, $hosts) = @_;
    my $serial = time();
    my $dnsfqdn = $$hosts{dnsserver}{fqdn};
    my $domain = $$hosts{domain};
    my $adminmail = "root.$$hosts{domain}";	# root.foo.com == root@foo.com
    unless( open(OUT, ">$filename") ) {
        print STDERR "$0: $filename: $!\n";
	exit(1);
    }
    printf(OUT 
        ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n".
        ";;; fwd.$$hosts{domain} - Forward Zone File for $$hosts{domain}\n".
        ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n".
	";\n".
        "; *** THIS FILE AUTOMATICALLY GENERATED BY $0\n".
        "; *** Do not edit this file by hand; changes will be overwritten!\n".
	"\n".
        "\$TTL 86400\n".
	"\@ IN SOA ${dnsfqdn}. ${adminmail}. (\n".
	"                 %-16s  ; Serial\n".
	"                 %-16s  ; Refresh\n".
	"                 %-16s  ; Retry\n".
	"                 %-16s  ; Expire\n".
	"                 %-16s) ; Minimum TTL\n".
	"\n",
	      $serial,	# Serial
	      "8H",		# Refresh
	      "2H",		# Retry
	      "1W",		# Expire
	      "6H");	# Minimum TTL

    # NAMESERVER/LOCALHOST ENTRIES
    printf(OUT "%-16s NS\t%s\n", "", ${dnsfqdn});
    printf(OUT "%-16s A\t%s\n", "localhost", "127.0.0.1");
    printf(OUT "\n");

    # A/CNAME ENTRIES
    my $ip;
    foreach $ip ( sort ( keys ( %{ $$hosts{host} } ) ) ) {
	# print  OUT (";"x50)."\n";
	printf(OUT "%-16s A\t%s\n", $$hosts{host}{$ip}{host}, $ip);
	if ( defined($$hosts{host}{$ip}{aliases} ) ) {
	    foreach my $alias ( @{ $$hosts{host}{$ip}{aliases} } ) {
	        if ( $alias ne $$hosts{host}{$ip}{host} ) {
		    printf(OUT "%-16s CNAME\t%s\n", $alias,
		                                    $$hosts{host}{$ip}{host});
		}
	    }
	}
    }
    close(OUT);
}

# SAVE THE REVERSE ZONE FILE FOR THE DOMAIN
#    On error, prints error to stderr and exits program.
#    $1 - filename of zone file to write out
#    $2 - REFERENCE: $hosts hash
#
sub SaveDomainReverse($$)
{
    my ($filename, $hosts) = @_;
    my $serial = time();
    my $dnsfqdn = $$hosts{dnsserver}{fqdn};
    my $domain = $$hosts{domain};
    my $adminmail = "root.$$hosts{domain}";	# root.foo.com == root@foo.com
    unless( open(OUT, ">$filename") ) {
        print STDERR "$0: $filename: $!\n";
	exit(1);
    }
    printf(OUT 
        ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n".
        ";;; rev.$$hosts{domain} -- Reverse Zone File for $$hosts{domain}\n".
        ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n".
	";\n".
        "; *** THIS FILE AUTOMATICALLY GENERATED BY $0\n".
        "; *** Do not edit this file by hand; changes will be overwritten!\n".
	"\n".
        "\$TTL 86400\n".
	"\@ IN SOA ${dnsfqdn}. ${adminmail}. (\n".
	"         %-16s  ; Serial\n".
	"         %-16s  ; Refresh\n".
	"         %-16s  ; Retry\n".
	"         %-16s  ; Expire\n".
	"         %-16s) ; Minimum TTL\n".
	"\n",
	          $serial,	# Serial
		  "8H",		# Refresh
		  "2H",		# Retry
		  "1W",		# Expire
		  "6H");	# Minimum TTL

    # NAMESERVER/LOCALHOST ENTRIES
    printf(OUT "%-8s NS\t%s\n", "", ${dnsfqdn});
    printf(OUT "\n");

    # EXAMPLE:
    # 1           PTR     router.erco.x.
    #
    my $ip;
    foreach $ip ( sort( keys ( %{ $$hosts{host} } ) ) ) {
	my $hostnum = $ip; $hostnum =~ s/^\d+\.\d+\.\d+\.//g;
	printf(OUT "%d\t PTR\t%s.\n", $hostnum, $$hosts{host}{$ip}{fqdn});
    }
    close(OUT);
}

# SAVE THE NAMED.CONF FILE
#    On error, prints error to stderr and exits program.
#    $1 - filename of zone file to write out
#    $2 - REFERENCE: $hosts hash
#
sub SaveConf($$)
{
    my ($filename, $hosts) = @_;
    unless( open(OUT, ">$filename") ) {
        print STDERR "$0: $filename: $!\n";
	exit(1);
    }
    print OUT <<"EOF";
//////////////////////////////////
// $$hosts{zonedir}/named.conf
//////////////////////////////////
//
//       *** THIS FILE AUTOMATICALLY GENERATED BY $0
//       *** Do not edit this file by hand; your changes will be overwritten!
//
options {
	directory "$$hosts{zonedir}";
};

// ROOT ZONE
zone "." {
	type hint;
	file "named.ca";
};

// FORWARD: $$hosts{domain}
zone "$$hosts{domain}"{
	type master;
	file "fwd.$$hosts{domain}";
	notify yes;
};

// REVERSE: $$hosts{domain} (NETWORK $G::network)
zone "${G::networkrev}.in-addr.arpa"{
	type master;
	file "rev.$$hosts{domain}";
};

// REVERSE: LOCALHOST
zone "0.0.127.in-addr.arpa"{
	type master;
	file "rev.localhost";
};

EOF
    close(OUT);
}

# RESTART/RELOAD THE LOCAL DNS SERVER
sub RestartDNS()
{
    # IS THIS A MAC?
    if ( -x "/usr/bin/sw_vers" ) {
	if ( `sw_vers` =~ /ProductVersion:\s+10.3/ ) {
	    ### OSX 10.3 ###
	    # Try telling named to 'reload'
	    if ( system("killall -HUP named 2> /dev/null") != 0 ) {
		system("named");
	    }
	    # Make sure DNS configured to start on boot
	    if ( `grep DNSSERVER /etc/hostconfig` !~ /DNSSERVER=-YES-/ ) {
		print STDERR 
		    "WARNING: Make sure you have DNSSERVER=-YES- in /etc/hostconfig\n".
		    "         otherwise DNS won't start itself after a reboot.\n";
	    }
	} elsif ( `sw_vers` =~ /ProductVersion:\s+10.4/ ) {	# OSX 10.4?
	    ### OSX 10.4 ###
	    if ( system("killall -HUP named") != 0 ) {
		system("service org.isc.named stop");		# restart DNS
		system("service org.isc.named start");
	    }
	}
	return;
    } elsif ( -x "/etc/init.d/named") {
	### LINUX/IRIX ###
	system("chkconfig named on");
	if ( system("killall -HUP named") != 0 ) {
	    # RESTART DNS
	    system("/etc/init.d/named stop");	# restart
	    system("/etc/init.d/named start");
	}
    } else {
        # PLATFORM UNKNOWN -- JUST START NAMED, HOPE FOR BEST
	system("named");
    }
}

# UPDATE DNS WITH HOSTS FILE
sub UpdateDNS($)
{
    my ($viewonly) = @_;
    my %hosts;
    LoadHosts("/etc/hosts", \%hosts);

    my $conffile  = "$hosts{conf}";
    my $rootfile  = "$hosts{zonedir}/named.ca";
    my $domainfwd = "$hosts{zonedir}/fwd.$hosts{domain}";
    my $domainrev = "$hosts{zonedir}/rev.$hosts{domain}";
    my $localrev  = "$hosts{zonedir}/rev.localhost";

    if ( $viewonly ) {
	SaveRootCache("&STDOUT");
	print "\n";
	SaveConf("&STDOUT", \%hosts);
	print "\n";
	SaveLocalReverse("&STDOUT", \%hosts);
	print "\n";
	SaveDomainForward("&STDOUT", \%hosts);
	print "\n";
	SaveDomainReverse("&STDOUT", \%hosts);
    } else {
	SaveRootCache($rootfile);
	SaveConf($conffile, \%hosts);
	SaveLocalReverse($localrev, \%hosts);
	SaveDomainForward($domainfwd, \%hosts);
	SaveDomainReverse($domainrev, \%hosts);
	RestartDNS();
    }
    return(0);
}

# SHOW HELP AND EXIT
sub HelpAndExit()
{
    print STDERR <<"EOF";
hosts2dns -- Converts /etc/hosts file into DNS server config
Version 0.93, Copyright (C) 2006 Greg Ercolano.

    Your /etc/hosts file is used for all input information
    to control this program. (See -showexample)
    
OPTIONS
    -update        -- update DNS with current /etc/hosts
    -view          -- view files to be generated (no update)
    -viewzone      -- view files to be generated (no update)
    -showexample   -- show an example hosts file

USING "-update"
    -update will update the named.conf and all zone files with 
    new serial numbers, and handles telling DNS to reload.
    
    If DNS isn't running, hosts2dns starts it, and enables
    it to start on boot (if possible).

    After doing an -update, tail your syslog to check
    for error messages from "named" (the DNS daemon).

    WARNING: "hosts2dns -update" does NOT try to save
    your previous DNS configuration. Any previous 
    named.conf and zone files will be *overwritten*!

EXAMPLES
    Whenever you create or modify your /etc/hosts file,
    run this command to update those changes to DNS:

	 hosts2dns -update

    If you are DNS savvy, and want to see the zonefiles host2dns
    would create, without it actually saving them out, use:

	 hosts2dns -viewzone

    If you're just starting out, and want to see an example /etc/hosts
    file configured for hosts2dns, use:

	 hosts2dns -showexample

BUGS
    Before reporting bugs, take the latest release from:
    http://seriss.com/people/erco/unixtools/hosts2dns/
    Please report bugs to erco\@3dsite.com -- you /must/ include
    the words 'hosts2dns bug report' in the Subject: of your message.

AUTHOR/LICENSE
    hosts2dns Version 0.93, Copyright (C) 2006 Greg Ercolano
    hosts2dns comes with ABSOLUTELY NO WARRANTY. This is free
    software, and you are welcome to redistribute it under
    certain conditions; see the LICENSE.txt file that came
    with this software for details.
EOF
    exit(1);
}

# SHOW AN EXAMPLE /ETC/HOSTS FILE AND EXIT
sub ShowExampleAndExit()
{
    print STDERR <<"EOF";

$0 -- Convert /etc/hosts file into DNS

    Your /etc/hosts file must contain "#!DNS" comments
    that tell this program how to configure your domain.
    
    Here's an example /etc/hosts file that creates an internal domain 
    called 'foo.x', with 6 machines that will be added to DNS.

    NOTE: Hosts intended to be included in DNS must appear between
          the START and END markers.
	  
	  Hostname aliases will be turned into "CNAME" records.

------------------------------------------------------ snip: /etc/hosts
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost 

# THESE ENTRIES ARE USED BY hosts2dns
#     After you make changes to this file, run 'hosts2dns -update'
#     to make your changes appear in DNS.
#

#!DNS:DOMAIN foo.x
#!DNS:START
192.168.0.1    router   ro
192.168.0.2    howland  ho how
192.168.0.3    tahoe    ta
192.168.0.4    meade    me
192.168.0.5    superior su sup
192.168.0.6    ontario  on
192.168.0.8    powell   po pow
192.168.0.9    texoma   te tex
192.168.0.10   george   ge geo
192.168.0.11   michigan mi mich
192.168.0.12   havasu   ha
#!DNS:END

------------------------------------------------------ snip: /etc/hosts

EOF
    exit(1);
}

# SEE IF WE'RE RUNNING AS ROOT
#    If not, fail.
#
sub MustBeRoot()
{
    if ( ! -w "/" ) {
	print STDERR "$0: you must be running as root\n";
	exit(1);
    }
}

# MAIN
{
    ### INIT

    # Determine which version of bind is running
    if ( `named -v` =~ /BIND ([^\n]*)/ ) {
	$G::bindver = $1;
    } else {
        print STDERR "$0: unable to determine version of named(8). ".
	             "(Is 'named' in your PATH? Is named installed?)\n";
	exit(1);
    }

    # Determine our network number
    $G::network    = GetNetworkIPFwd();		# eg. 192.168.0
    $G::networkrev = GetNetworkIPRev();		# eg. 0.168.192

    ### PARSE COMMAND LINE ARGUMENTS
    foreach $arg ( @ARGV ) {
        if ( $arg eq "-update" ) {
	    MustBeRoot();
	    exit( (UpdateDNS(0) < 0) ? 1 : 0 );
	}
        if ( $arg eq "-view" ) {
	    my %hosts;
	    if ( LoadHosts("/etc/hosts", \%hosts) < 0 ) { exit(1); }
	    if ( PrintHosts(\%hosts) < 0 ) { exit(1); }
	    exit(0);
	}
        if ( $arg eq "-viewzone" ) {
	    exit( (UpdateDNS(1) < 0) ? 1 : 0 );
	}
        if ( $arg eq "-showexample" ) {
	    ShowExampleAndExit();
	}
        if ( $arg =~ /-h/ ) {
	    HelpAndExit();
	}
	print STDERR "$0: '$arg': unknown argument (try -help)\n";
    }
    HelpAndExit();
}

__END__

