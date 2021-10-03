#!/bin/bash

# Build script for installing & running Python System Info program
# Author : Remy Kumar Arumugham
# Date : 01-Oct 2021

# Read me
# Go to the home directory of the user (like /home/remy), place the script there and execute the script like ./build.sh
# Run using your own user account (not root) from your home directory. Please make sure your account has sudo access to root.
# The script has been tested for Ubuntu, Red Hat & CentOS - Other Operating Systems could see some unwarranted errors.

echo -e "\nChecking if the script is in home directory of the user - /home/$USER \n"
sleep 1
if [[ `pwd` != /home/$USER ]]; then
 echo -e "\nNot running from home directory of user. Please place the script in the home directory of the user & execute.\n"
 exit
fi

echo -e "\nRunning from the current user's($USER) home directory.\n"
sleep 3
if [ $USER = root ]; then
 echo -e "!!!!Running with root user; existing script. Please run with your normal user account!!!!\n"
 echo -e "Also, Please make sure your user has sudo to root since we are installing softwares/packages via sudo.\n"
 exit
else
 echo -e "Switching to $USER home directory - /home/$USER\n"
 sleep 2
 cd /home/$USER
fi

# Software installation step - install git and the http server.
# The start the http server & enable it on reboot
echo -e "Installing git, python3, http server and starting the http server. Please note - will install only if it doesn't exist.\n"
sleep 3
if [[ ! -z `hostnamectl | egrep -i 'centos|red hat|oracle linux'` ]];then
 sudo yum install git -y
 sudo yum install httpd -y
 sudo yum install python3 -y
 sudo systemctl start httpd
 sudo systemctl enable httpd
fi

if [[ ! -z `hostnamectl | egrep -i 'Debian|Ubuntu'` ]]; then
 sudo apt-get update -y
 sudo apt install git -y
 sudo apt install apache2 -y
 sudo apt install python3
 sudo systemctl start apache2
 sudo systemctl enable apache2
fi

# Remove the old code directory and use git to download everytime
if [[ -d /home/$USER/system_info_devops ]]; then
 rm -rf /home/$USER/system_info_devops
fi

# Get the Python code from git
echo -e "Downloading/clone code from github and switching the directory to code directory - /home/$USER/system_info_devops\n"
git clone https://github.com/remykumar/system_info_devops.git/
cd system_info_devops
sleep 2

# Get the internal and external IP of the host machine
INT_IP=`hostname -I | awk '{print $1}'`
EXT_IP=`curl -s api.ipify.org`

# Make sure the existing instance of python instance (if running) is killed and new one is started
echo -en "\nBuilding the code ."
PID=`pgrep -f sysinfo.py`
if [ -z $PID ]; then
 nohup python3 sysinfo.py 2>/dev/null &
else
 kill -9 $PID
 nohup python3 sysinfo.py 2>/dev/null &
fi

for i in {1..4}
do
sleep 2
echo -n .
done

echo "Build Complete!"
echo "-------------------------------------------------------------------------"
sleep 3

# There are some sleep waits to make sure the html and associate files are moved to relevant location
# curl the External and Internal IP addresses to check the 200 success status. Use External first since this code is to be run on AWS EC2 instance
echo -en "\nDeploying the code on the http server ."
FINAL_URL=""
RESP=`curl -s -I http://$EXT_IP/systeminfo.html --connect-timeout 3 | grep HTTP | grep OK`

if [[ -z $RESP ]]; then
 RESP=`curl -s -I http://$INT_IP/systeminfo.html --connect-timeout 3 | grep HTTP | grep OK`
 if [[ -z $RESP ]]; then
  echo -e "\n!!! Deploy not successful - Site not reachable!!!!. \nPossible reasons could be :\n
         1. Http server is not running \n
         2. Internet is not working or network issues \n
         3. Firewall blocking port 80 \n"
  exit
 else
 FINAL_URL=http://$INT_IP/systeminfo.html
 fi
else
 FINAL_URL=http://$EXT_IP/systeminfo.html
fi

for i in {1..4}
do
sleep 2
echo -n .
done

echo "Deploy Complete!"
sleep 2
echo -e "-------------------------------------------------------------------------\n"
echo "Please access the System Stats (System Information) page here : "
echo -e "$FINAL_URL\n"