#!/bin/bash 

# Copyright 2018 The Trustees of Indiana University
# All rights reserved
# et cētera

# Actually, this really isn't ready for public consumption
# ...except for my co-workers beta testing it 

# V. 190604.01

# $1 is the name of the image to boot otherwise use the latest CentOS-7 image
# $2 is the name to give the running instance; default is the image name with a random string appended
# $3 is the instance flavor to create; default is to make it a tiny
# $4 is the cloud-init script; default is none

# user asking for help?
if [ "$1" == "-h" ]; then
  echo
  echo '    $1 is the name of the image to boot otherwise use the latest CentOS-7 image'
  echo '    $2 is the name to give the running instance; default is the image name with a random string appended'
  echo '    $3 is the instance flavor to create; default is to make it a tiny'
  echo '    $4 is the cloud-init script; default is none'
  echo
  exit
fi


set -o pipefail
ExitStatus=0

Step="checking credentials"
ExitStatus=$((ExitStatus+1))
if [ "$OS_PROJECT_NAME" == "" ] && [ "$OS_PROJECT_ID" == "" ] ; then
  echo "No OpenStack Project defined; have you sourced your openrc?"
  exit ${ExitStatus}
fi

# a simple function to watch for the instance to come up
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

# $1 is the name of the image to boot; otherwise, use the latest CentOS-7 image
# need better error exit - geo
Step="looking for image"
ExitStatus=$((ExitStatus+1))
if [ "$1" != "" ]; then
  if [ "$1" == "centos" ]; then
    IMAGENAME=`openstack image list | grep JS-API-Featured-CentOS7 | grep -v Intel | head -1 | awk '{print $4}' -` || exit ${ExitStatus}
  elif [ "$1" == "ubuntu" ]; then
    IMAGENAME=`openstack image list | grep JS-API-Featured-Ubuntu18 | grep -v Intel | head -1 | awk '{print $4}' -` || exit ${ExitStatus}
  else
    openstack image show $1 > /dev/null || exit ${ExitStatus}
    IMAGENAME="$1"
  fi
else
  IMAGENAME=`openstack image list | grep JS-API-Featured-CentOS7 | grep -v Intel | head -1 | awk '{print $4}' -` || exit ${ExitStatus}
fi
# pick a username to login as dependent upon the Image picked
if [[ ${IMAGENAME} == *"Featured-CentOS"* ]]; then
  USERNAME="centos"
elif [[ ${IMAGENAME} == *"Featured-Ubuntu"* ]]; then
  USERNAME="ubuntu"
else
  USERNAME="unknown-user-account"
fi;
RetVal=$?
if [ $RetVal -ne 0 ]; then
    echo "Error ${Step}; Exit Status = $RetVal"
    exit ${ExitStatus}
fi


# $2 is the name of the running instance; otherwise, create a name
# error checking is not correct - geo
Step="creating instance name"
ExitStatus=$((ExitStatus+1))
TMPFILE=`mktemp XXXXXX` || exit ${ExitStatus}
if [ "$2" != "" ]; then
  INSTANCENAME="$2"
  FILENAME=`echo "./$2-quickie-${TMPFILE}.txt" | tr '[:upper:]' '[:lower:]'`
else
  TMPFILE0=`echo "${TMPFILE}" | tr '[:upper:]' '[:lower:]'`
  INSTANCENAME="${OS_PROJECT_NAME}-${OS_USERNAME}-quickie-${TMPFILE0}"
  FILENAME=`echo "./${OS_PROJECT_NAME}-${OS_USERNAME}-quickie.${TMPFILE}.txt" | tr '[:upper:]' '[:lower:]'`
fi
mv ${TMPFILE} ${FILENAME}
RetVal=$?
if [ $RetVal -ne 0 ]; then
    echo "Error ${Step}; Exit Status = $RetVal"
    exit ${ExitStatus}
fi


# $3 is the flavor of instance to create; otherwise, make it a tiny
Step="setting the flavor"
ExitStatus=$((ExitStatus+1))
if [ "$3" != "" ]; then
  openstack flavor show $3 > /dev/null || exit ${ExitStatus}
  FLAVORSIZE="$3"
else
  FLAVORSIZE="m1.tiny"
fi
RetVal=$?
if [ $RetVal -ne 0 ]; then
    echo "Error ${Step}; Exit Status = $RetVal"
    exit ${ExitStatus}
fi

# $4 is the cloud-init script; default is none
Step="identifying cloud-init script"
ExitStatus=$((ExitStatus+1))
if [ "$4" != ""  ]; then
	if [ -f "$4" ]; then
		USERDATAFILE="  --user-data ${4}"
	else
		echo "cloud init file $4 does not exist"
 	 	echo "Error ${Step}; Exit Status = $RetVal"
		exit ${ExitStatus}	
	fi
else
	USERDATAFILE=""
fi
RetVal=$?
if [ $RetVal -ne 0 ]; then
    echo "Error ${Step}; Exit Status = $RetVal"
    exit ${ExitStatus}
fi

echo  | tee -a ${FILENAME}
date  | tee -a ${FILENAME}
echo  | tee -a ${FILENAME}
echo -ne "Creating $INSTANCENAME from image $IMAGENAME" | tee -a ${FILENAME}
if [ "$USERDATAFILE" != "" ]; then
	echo " with ${USERDATAFILE}"
else
	echo
fi
echo  | tee -a ${FILENAME}
t1=`date +%s`

# geo has his non-global security groups
# from the tutorial one could use --security-group  ${OS_PROJECT_NAME}-${OS_USERNAME}-global-secgrp
Step="creating server"
ExitStatus=$((ExitStatus+1))
openstack server create ${INSTANCENAME} \
  --flavor ${FLAVORSIZE} \
  --image ${IMAGENAME} \
  --key-name ${OS_PROJECT_NAME}-${OS_USERNAME}-api-key \
  --security-group iub-secgrp \
  --security-group jetstream-iu-sysmgm-secgrp \
  --security-group geos-cabin-secgrp \
  --nic net-id=${OS_PROJECT_NAME}-${OS_USERNAME}-api-net \
  --wait \
  ${USERDATAFILE} \
  | tee -a ${FILENAME}
RetVal=$?
if [ $RetVal -ne 0 ]; then
    echo "Error ${Step}; Exit Status = $RetVal"
    exit ${ExitStatus}
fi

echo | tee -a ${FILENAME}

# not needed since adding --wait to create command
#sleep 3

Step="creating floating IP"
ExitStatus=$((ExitStatus+1))
openstack floating ip create public | tee -a ${FILENAME}
RetVal=$?
if [ $RetVal -ne 0 ]; then
    echo "Error ${Step}; Exit Status = $RetVal"
    exit ${ExitStatus}
fi

echo | tee -a ${FILENAME}

IP=`grep floating_ip_address ${FILENAME} | awk '{print $4}' -`
echo "New IP ${IP}" | tee -a ${FILENAME}
echo | tee -a ${FILENAME}

Step="adding floating IP to instance"
ExitStatus=$((ExitStatus+1))
openstack server add floating ip ${INSTANCENAME} ${IP}
RetVal=$?
if [ $RetVal -ne 0 ]; then
    echo "Error ${Step}; Exit Status = $RetVal"
    exit ${ExitStatus}
fi

sleep 1

echo | tee -a ${FILENAME}
echo "Assuming ${IP} becomes active, clean up commands are:" | tee -a ${FILENAME}
echo | tee -a ${FILENAME}
echo "    openstack server remove floating ip ${INSTANCENAME} ${IP}" | tee -a ${FILENAME}
echo "    openstack floating ip delete ${IP}" | tee -a ${FILENAME}
echo "    openstack server delete ${INSTANCENAME}" | tee -a ${FILENAME}
echo "    rm ${FILENAME}" | tee -a ${FILENAME}
echo | tee -a ${FILENAME}
echo "Watching for IP to become active" | tee -a ${FILENAME}
echo | tee -a ${FILENAME}


watch-ip ${IP}

t2=`date +%s`
dt=$((t2-t1))

echo | tee -a ${FILENAME}
echo "Instance is now answering ping; it will soon be available for logins" | tee -a ${FILENAME}
echo "    ssh -i ~/.ssh/${OS_PROJECT_NAME}-${OS_USERNAME}-api-key ${USERNAME}@${IP}" | tee -a ${FILENAME}
echo | tee -a ${FILENAME}
date | tee -a ${FILENAME}
echo "Seconds to start = $dt" | tee -a ${FILENAME}
echo | tee -a ${FILENAME}
echo | tee -a ${FILENAME}
echo "A file named Qenv.sh has been created ready to define the environment variables Qserver and Qip if needed" | tee -a ${FILENAME}
echo | tee -a ${FILENAME}
echo | tee -a ${FILENAME}

#echo qServer,Qip ${Qserver} ${Qip}
# need to explain & document this
Step="export environment state"
ExitStatus=$((ExitStatus+1))
TMPFILE2=`mktemp XXXXXX` || exit ${ExitStatus}
echo export Qserver="${INSTANCENAME}" > ${TMPFILE2}
echo export Qip="${IP}" >> ${TMPFILE2}
mv ${TMPFILE2} Qenv.sh

exit

# how to test if ssh is running (assuming you have telnet installed)
# echo -e "\035quit" | telnet 149.165.156.173 22

# openstack server add security group <server> <group>

