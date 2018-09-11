#mkpw() { openssl rand -base64 18 ; }

watch-migrate() 
{
  in=$1
  et=0
  st="$(date -u +%s)"
  echo
  mst=`openstack server show $in | grep " status " | awk '{print $4}' -`
  while [ "$mst" = "MIGRATING" ] ; do 
    nt="$(date -u +%s)"
    et="$(($nt-$st))"
    echo -ne "  MIGRATING $et sec\r"
    sleep 3
    mst=`openstack server show $in | grep " status " | awk '{print $4}' -`
  done ; 
  echo -e  "after $et sec, it's alive\041\041\041\007  :  nova resize-confirm <SREVER>\n"
}

watch-ip() 
{
  et=0
  st="$(date -u +%s)"
  echo
  while ( ! ping -q -t 1 -c 1 $1 > /dev/null 2>&1 ) ; do 
    nt="$(date -u +%s)"
    et="$(($nt-$st))"
    echo -ne "  no ping $et sec\r"
    sleep 4
  done ; 
  echo -e  "after $et sec, it's alive\041\041\041\007\n"
}

# for OpenStack stuff

# Set architecture flags
export ARCHFLAGS="-arch x86_64"

# Ensure user-installed binaries take precedence
export PATH=/usr/local/bin:$PATH

# added by Anaconda2 4.4.0 installer
export PATH="/Users/turnerg/anaconda/bin:$PATH"

export PATH=~/bin:$PATH

# old stuff from colossus
pbsexit ()  { echo $1 | perl -e '$c=<>; chomp $c; $s=$c&127; $e=$c>>8; print "code $c sig $s exit $e\n"'; }
alias scancolossus='netcat -v -w 1 -z colossus 1-1024'
alias vscancolossus='echo QUIT | netcat -v -w 1 colossus 1-1024'
alias bell='echo -ne "\007"'

alias osrc="printenv | grep OS | grep -v PASS"

