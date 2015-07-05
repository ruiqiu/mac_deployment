################################################################

# Interactive script to join Macs to Active Directory

# 

# Originally Written by Vaughn Miller

# Modified by Ray Qiu

# 06162015

# v1.2

################################################################




#!/bin/bash


echo “ *** Welcome to My Mac AD Tool *** “

RunAsRoot()

{

        ##  Pass in the full path to the executable as $1

        if [[ "${USER}" != "root" ]] ; then

                echo

                echo "***  This application must be run as root.  Please authenticate below.  ***"

                echo

                sudo "${1}" && exit 0

        fi

}




RunAsRoot "${0}"




# If machine is already bound, exit the script

check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`

if [ "${check4AD}" = "Active Directory" ]; then

	echo "Computer is already bound to Active Directory.. \n Exiting script... "; exit 1

fi





compou=“Which OU you want to put Macs in”


read -p "Enter computer name : " compName



# Bind the machine to AD

read -p "Enter account name  : " acctName

dsconfigad -add “your domain” -computer $compName -username $acctName -ou $compou




# If the machine is not bound to AD, then there's no purpose going any further. 

check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`

if [ "${check4AD}" != "Active Directory" ]; then

	echo "Bind to Active Directory failed! \n Exiting script... "; exit 1

fi




# set host names to match 

scutil --set HostName $compName

scutil --set ComputerName $compName

scutil --set LocalHostName $compName




# Configure login options

dsconfigad -mobile enable

dsconfigad -mobileconfirm disable

dsconfigad -useuncpath disable

# If running Lion, configure the search paths.
# The Search Paths show up different depending on what update is installed
majorSysver=`sw_vers -productVersion | cut -c 1-4`
minorSysver=`sw_vers -productVersion | cut -c 6`
if [ $majorSysver = 10.7 ]; then
   if [ $minorSysver -gt 1 ]; then
      dscl /Search -delete / CSPSearchPath "/Active Directory/COMPANY/All Domains"
      dscl /Search -append / CSPSearchPath "/Active Directory/COMPANY"
      dscl /Search -append / CSPSearchPath "/Active Directory/COMPANY/All Domains"
   else
      dscl /Search -delete / CSPSearchPath "/Active Directory/AD/All Domains"
      dscl /Search -append / CSPSearchPath "/Active Directory/AD"
      dscl /Search -append / CSPSearchPath "/Active Directory/AD/All Domains"
   fi
fi


