#!/usr/bin/awk -f

# piss - process information sorted sanely
#
# http://www.seriss.com/people/erco/unixtools/piss
# Hierarchical ps(1) report.
#
# Put this in the global user's path, so all users can easily 
# see process parenting, and/or 'grep' for certain processes by name.
# 
# See some sample reports from piss. AIX/IRIX/Linux/BSDI/MacOSX 
# Recently added better Jaguar/OSX support and FreeBSD. 
#
#
#       This software is Public Domain. Please maintain version history.
#
#       VERS    DATE            AUTHOR          COMMENTS
#       1.00    11/17/94        Greg Ercolano   Initial version
#       [..]
#       1.22    05/15/95        Greg Ercolano   Linux owner lookup
#       1.23    11/25/96        Greg Ercolano   Linux 2 support, yp
#       1.23a   11/27/96        Greg Ercolano   cat passwd & ypcat passwd
#       1.23b   04/28/96        Greg Ercolano   IRIX 64 bit support
#       1.24    02/06/98        Greg Ercolano   BSDI OS2 port, ypcat fix
#       1.25    11/20/01        Greg Ercolano   Mac OSX port
#       1.26    04/02/04        Greg Ercolano   OSX: '-o [keywords]', FreeBSD added
#       1.26a   04/10/04        Greg Ercolano   Added Linux 2 support
#       1.27    06/02/04        Mario van Gils  Added AIX support 
#

# LOAD UID->LOGNAME MAPPINGS
#    Give precedence to the yp database, if available
#
function LoadPasswd( \
	_passwdcmd, _junk)
{
    _passwdcmd = "(cat /etc/passwd; ypcat passwd )2> /dev/null"
    while ( _passwdcmd | getline )
    {
        split($0, _junk, ":");
        if (uidname[_junk[3]] == "" )
            uidname[_junk[3]] = _junk[1];
    }
    close(_passwdcmd);
}

# HOW MANY MORE CHILDREN DOES THIS PROCESS HAVE
function Children(i, cnt)
{
    cnt = 0;
    for (ttt=1; ttt<=total; ttt++)
        if (ppid[order[ttt]] == pid[i] && pflag[order[ttt]]==0)
            ++cnt;
    return(cnt);
}

# PRINT THIS PROCESS, AND ALL CHILD PROCESSES RECURSIVELY
function PrintChildren(i, level, prefix, t, cnt)
{
    if (! pflag[i] )
    {
        printf("%-5d  %-8s %s\n", pid[i], uid[i], cmd[i]);
        pflag[i] = 1;
        feed     = 0;
    }

    cnt = 0;
    for (t=1; t<=total; t++)
    {
        if (ppid[order[t]] == pid[i] && pflag[order[t]] == 0)
        {
            cnt++;
            printf("%s|--", level);
            if (Children(i,0) > 1)
                PrintChildren(order[t], level "|  ", 0);
            else
                PrintChildren(order[t], level "   " , 0);
        }
    }
    if (cnt && !feed) { printf("%s\n",level); feed = 1; }
}

# BASENAME FUNCTION ON FIRST WORD IN STRING
function Basename(cmd, _i, _s)
{
    if (_i = index(cmd, " ")) { _s = substr(cmd, _i); }
    else                      { _s = cmd; _i = 0; }
    gsub(".*/", "", _s);
    return(_s);
}

function IRIXLoad(pscommand, onlymatch)
{
    pscommand | getline header
    cmd_x = index(header, "COMD");   # find command column via header

    while ( pscommand | getline )
    {
        if (onlymatch != "" && ! match($0, onlymatch) ) continue;
        ++total;
        id           = $4;
        order[total] = id;
        uid[id]      = $3;
        pid[id]      = $4;
        ppid[id]     = $5;
        pflag[id]    = 0;
        cmd[id]      = Basename(substr($0, cmd_x));
    }
    close(pscommand);
}

#   F S      UID   PID  PPID  C PRI NI  P    SZ:RSS      WCHAN    STIME TTY     TIME CMD
#  b0 S     root     1     0  0  39 20  *    78:38    88247160   Jan 03 ?       0:05 /etc/init 
# --- ----- ----   ---  ----
# $1  $2    $3     $4   $5
#
function IRIX6Load(pscommand, onlymatch)
{
    pscommand | getline header
    cmd_x = index(header, "CMD");   # find command column via header

    while ( pscommand | getline )
    {
        if (onlymatch != "" && ! match($0, onlymatch) ) continue;
        ++total;
        id           = $4;
        order[total] = id;
        uid[id]      = $3;
        pid[id]      = $4;
        ppid[id]     = $5;
        pflag[id]    = 0;
        cmd[id]      = Basename(substr($0, cmd_x));
    }
    close(pscommand);
}

#  UID   PID  PPID  CP PRI  NI   VSZ  RSS WCHAN    S    TTY             TIME COMMAND
#    0     0     0   0  32 -12  133M 5.4M *        R <  ??           0:03.48 [kernel idle]
#    0     1     0   0  44   0  304K  64K pause    I    ??           0:00.26 /sbin/init -sa
#    0     3     1   0  44   0  968K 720K sv_msg_  I    ??           0:00.04 /sbin/kloadsrv -f
#    0    27     1   0  44   0  184K  32K pause    S    ??           0:00.75 /sbin/update

function OSFLoad(pscommand, onlymatch)
{
    # WE MUST DO UID->USERNAME LOOKUPS OURSELVES
    LoadPasswd();

    pscommand | getline header

    # USE HEADER TO FIND COLUMN POSITIONS
    uid_x  = index(header, "  UID");
    pid_x  = index(header, "  PID");
    ppid_x = index(header, " PPID");
    cmd_x  = index(header, "COMMAND");

    while ( pscommand | getline )
    {
        if (onlymatch != "" && ! match($0, onlymatch) ) continue;

        ++total;
        pflag[id]    = 0;
        id           = substr($0, pid_x, 5)+0;
        uidval       = substr($0, uid_x, 5)+0;
        order[total] = id;
        uid[id]      = (uidname[uidval] == "") ? uidval : uidname[uidval];
        pid[id]      = id;
        ppid[id]     = substr($0, ppid_x, 5)+0;
        cmd[id]      = Basename(substr($0, cmd_x));
    }
    close(pscommand);
}

function BSDLoad(pscommand, onlymatch)
{
    # WE MUST DO UID->USERNAME LOOKUPS OURSELVES
    LoadPasswd();

    pscommand | getline header

    # USE HEADER TO FIND COLUMN POSITIONS
    uid_x  = index(header, "  UID");
    pid_x  = index(header, "  PID");
    ppid_x = index(header, " PPID");
    cmd_x  = index(header, "COMMAND");

    while ( pscommand | getline )
    {
        if (onlymatch != "" && ! match($0, onlymatch) ) continue;

        ++total;
        pflag[id]    = 0;
        id           = substr($0, pid_x, 5)+0;
        uidval       = substr($0, uid_x, 5)+0;
        order[total] = id;
        uid[id]      = (uidname[uidval] == "") ? uidval : uidname[uidval];
        pid[id]      = id;
        ppid[id]     = substr($0, ppid_x, 5)+0;
        cmd[id]      = Basename(substr($0, cmd_x));
    }
    close(pscommand);
}

function Linux2Load(pscommand, onlymatch, \
                    _junk, _username)
{
    # WE MUST DO UID->USERNAME LOOKUPS OURSELVES
    LoadPasswd();

    pscommand | getline header
    offset = match(header, "COMMAND");
    while ( pscommand | getline )
    {
        _username = (uidname[$2]!="") ? uidname[$2] : $2;

        if (onlymatch != "" && \
            (!match($0, onlymatch) && !match(_username, onlymatch)))
                continue;

        ++total;
        id           = $3;
        order[total] = id;
        uid[id]      = _username;
        pid[id]      = $3;
        ppid[id]     = $4;
        pflag[id]    = 0;
        cmd[id]      = Basename(substr($0, offset));
    }
    close(pscommand);
}

function Linux1Load(pscommand, onlymatch, \
                    _junk, _username)
{
    # WE MUST DO UID->USERNAME LOOKUPS OURSELVES
    LoadPasswd();

    pscommand | getline header
    while ( pscommand | getline )
    {
        _username = (uidname[$2]!="") ? uidname[$2] : $2;

        if (onlymatch != "" && \
            (!match($0, onlymatch) && !match(_username, onlymatch)))
                continue;

        ++total;
        id           = $3;
        order[total] = id;
        uid[id]      = _username;
        pid[id]      = $3;
        ppid[id]     = $4;
        pflag[id]    = 0;
        cmd[id]      = Basename(substr($0, 67));
    }
    close(pscommand);
}

#      F S UID    PID   PPID   C PRI NI ADDR  SZ  RSS   WCHAN    TTY  TIME CMD
#    303 A   0      0      0 120  16 -- 1000  64   60              - 57:38 swapper
# 200003 A   0      1      0   0  60 20 1502a 872  144              -  4:34 /etc/init
#    303 A   0   8196      0 120 255 -- 5002  44   36              - 136200:13 wait
#    303 A   0  12294      0 120 255 -- 9004  44   44              - 134059:52 wait
#    303 A   0  16392      0 120 255 -- d006  44   44              - 134045:53 wait
#    303 A   0  20490      0 120 255 -- 11008  44   44              - 133056:00 wait
#    303 A   0  24588      0 120  17 -- 1500a  52   48              -  2:22 reaper
#    303 A   0  28686      0   0  16 -- 1900c  44   40              - 39:37 lrud

function AIXLoad(pscommand, onlymatch)
{
    # WE MUST DO UID->USERNAME LOOKUPS OURSELVES
    LoadPasswd();

    pscommand | getline header

    # USE HEADER TO FIND COLUMN POSITIONS
    uid_x  = index(header, "  UID");
    pid_x  = index(header, "  PID");
    ppid_x = index(header, " PPID");
    cmd_x  = index(header, "COMMAND");

    while ( pscommand | getline )
    {
        if (onlymatch != "" && ! match($0, onlymatch) ) continue;

        ++total;
        pflag[id]    = 0;
        id           = substr($0, pid_x, 5)+0;
        uidval       = substr($0, uid_x, 5)+0;
        order[total] = id;
        uid[id]      = (uidname[uidval] == "") ? uidval : uidname[uidval];
        pid[id]      = id;
        ppid[id]     = substr($0, ppid_x, 5)+0;
        cmd[id]      = Basename(substr($0, cmd_x));
    }
    close(pscommand);
}

# LOAD FIXED KNOWN COLUMNS
#    user,pid,ppid,state,command
#     $1   $2  $3   $4    $5 ..
function CustomLoad(pscommand, onlymatch)
{
    pscommand | getline header
    while ( pscommand | getline )
    {
        if (onlymatch != "" && ! match($0, onlymatch) ) continue;
        ++total;
        pflag[id]    = 0;
        id           = $2;	# pid
        order[total] = id;
        uid[id]      = $1;	# user
        pid[id]      = id;	# pid
        ppid[id]     = $3;	# ppid
        cmd[id]      = Basename($5)" "$6" "$7" "$8" "$9;
	if ( match($4, "Z") )
	    { cmd[id] = "(Zombie) "cmd[id]; }
    }
    close(pscommand);
}

BEGIN {
    if (ARGC == 2)
    {
        onlymatch = ARGV[1]; delete ARGV[1];

        if ( onlymatch == "-" || onlymatch == "-h" || onlymatch == "-help" )
        {
            printf("usage: piss [search]\n");
            exit(1);
        }
    }

    # FIGURE OUT WHICH OS WE'RE DEALING WITH
    {
        "uname -sr" | getline version; 
        gsub("\\..*", "", version);
        close("uname -sr");
    }

    # LOAD PROCESS INFORMATION
    if      ( version == "Linux 1" ) Linux1Load("ps -laxww", onlymatch);
    else if ( version == "Linux 2" ) Linux2Load("ps -laxww", onlymatch);
    else if ( version == "IRIX 4"  ) IRIXLoad("ps -fale", onlymatch);
    else if ( version == "IRIX 5"  ) IRIXLoad("ps -fale", onlymatch);
    else if ( version == "IRIX 6"  ) IRIX6Load("ps -fale", onlymatch);
    else if ( version == "IRIX64 6") IRIX6Load("ps -fale", onlymatch);
    else if ( version == "OSF1 V3" ) OSFLoad("ps laxww", onlymatch);
    else if ( version == "BSD/OS 2") BSDLoad("ps laxww", onlymatch);
    else if ( version == "BSD/OS 3") BSDLoad("ps laxww", onlymatch);
    else if ( version == "AIX 2"   ) AIXLoad("ps laxww", onlymatch);
    else if ( match(version,"FreeBSD .") ||	# test FreeBSD 4.8
              match(version,"Linux .")   || 	# Tested redhat 6.1, 9.0
              match(version,"Darwin .") ) 	# Tested 10.3.x
        { CustomLoad("ps -axwwwo user,pid,ppid,state,command", onlymatch); }
    else 
        { printf("piss: unimplemented for OS version %s\n", version); exit(1); }

    # SORT AND DISPLAY
    for (t=1; t<=total; t++)
        if ( ! pflag[order[t]] ) PrintChildren(order[t],"",0);

    exit(0);
}

